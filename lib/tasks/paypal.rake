# frozen_string_literal: true

# rubocop:disable Rails/SkipsModelValidations
namespace :paypal do
  # The home sheet had some non-email addresses for paypal accounts. This script corrects those to be email addresses
  task :correct_paypal_accounts => :environment do
    ActiveRecord::Base.transaction do
      # downcase all addresses, remove any that are not emails
      Payee.where.not(paypal_account: nil).find_each do |payee|
        if payee.paypal_account.match(/.+@.+/)
          payee.update!(paypal_account: payee.paypal_account.downcase)
        else
          payee.update!(paypal_account: nil)
        end
      end

      # set corrected addresses
      settings = YAML.load_file(Rails.root.join('exports/corrected_paypal_accounts.yml'))

      settings['corrected_paypal_accounts'].each do |fsn, address|
        Payee.find_by!(fsn: fsn).update!(paypal_account: address)
      end
    end
  end

  desc 'Loads payout data from Paypal transactions'
  task :load_payouts => :environment do
    require 'csv'

    settings = YAML.load_file(Rails.root.join('exports/corrected_paypal_accounts.yml'))

    strip = ->(v) { v&.strip }
    gbp_conversion_rates = CSV.read(Rails.root.join('exports/GBP_USD_HistoricalPrices.csv'),
                                    headers: true,
                                    liberal_parsing: true,
                                    converters: strip,
                                    header_converters: strip).each.to_a

    path = Rails.root.glob('exports/FS_PaypalTrans_*.csv').first
    payouts_count = 0
    ActiveRecord::Base.transaction do
      # because we need to scan other rows for currency conversions, we load the entire sheet into memory first
      rows = CSV.read(path, headers: true, liberal_parsing: true).each.to_a

      rows.each do |row|
        email = row['To Email Address'].downcase
        txid = row['Transaction ID']

        next unless row['Type'] == 'General Payment'
        next unless row['Status'] == 'Completed'

        next if email.in?(Rails.application.config.app_config[:paypal][:incoming_addresses])

        gross = row['Gross'].to_money(row['Currency'])

        raise StandardError, "Non-negative payout: #{txid}" unless gross.negative?

        date = row[0] # row['\"Date\"']
        paid_at = DateTime.parse("#{date} #{row['Time']} #{row['Time zone']}")

        payee = Payee.find_by(paypal_account: email)
        payee = Payee.find_by!(fsn: settings['remapped_addresses'][email]) if settings['remapped_addresses'].key?(email)

        if payee.blank?
          puts("Skipping [#{txid}] #{paid_at} #{gross.format} payout to #{row['Name']} (#{email}): payee not found")
          next
        end

        # convert payouts to USD by finding the transaction that does currency conversion
        if gross.currency.iso_code != 'USD'
          # we can't just use the USD row value because it includes fees
          in_conversion_row = rows.find { |r| r['Reference Txn ID'] == txid && r['Currency'] == 'USD' }
          out_conversion_row = rows.find { |r| r['Reference Txn ID'] == txid && r['Currency'] == row['Currency'] }

          if in_conversion_row.present? && out_conversion_row.present?
            conversion_rate = in_conversion_row['Gross'].to_f.abs / out_conversion_row['Gross'].to_f.abs

            gross = (gross.amount * conversion_rate).to_money('USD')
          elsif row['Currency'] == 'GBP'
            conversion_rate = gbp_conversion_rates.find do |r|
                                Date.strptime(r['Date'], '%m/%d/%y') <= paid_at
                              end['Close'].to_f

            gross = (gross.amount * conversion_rate).to_money('USD')
          else
            raise StandardError, "No conversion row found: #{txid}"
          end
        end

        paid = -1 * gross

        Payout.upsert({
                        amount_cents: paid.cents,
                        amount_currency: paid.currency.iso_code,
                        paid_at: paid_at,
                        payee_id: payee.id,
                        paypal_transaction_id: txid
                      }, unique_by: [:paypal_transaction_id])

        payouts_count += 1
      end
    end

    CalculatorCache::Manager.recompute_all!
    puts("Loaded #{payouts_count} payouts")
  end
end
# rubocop:enable Rails/SkipsModelValidations
