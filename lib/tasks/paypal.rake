# frozen_string_literal: true

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
      settings = YAML.load_file(Rails.root.join('storage/exports/corrected_paypal_accounts.yml'))

      settings['corrected_paypal_accounts'].each do |fsn, address|
        Payee.find_by!(fsn: fsn).update!(paypal_account: address)
      end
    end
  end
end
