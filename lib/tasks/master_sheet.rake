# frozen_string_literal: true

namespace :master_sheet do
  desc 'Populate payees and splits from master spreadsheet'
  task :load_splits => :environment do
    require 'roo'
    xlsx = Roo::Spreadsheet.open(Rails.root.join('exports/home sheet copy for fox.xlsx').to_s)

    ActiveRecord::Base.transaction do
      # Load all the known payees

      # skip header and Fourth Strike / FS-000
      xlsx.sheet('LOOKUP').column(2)[2..].each do |payee|
        name, fsn = payee.split(' / ')[-2..]
        Payee.create_with(name: name).find_or_create_by!(fsn: fsn)
      end

      # Add their paypal info

      xlsx.sheet('ROYALTIES').each.with_index do |row, i|
        next if i.zero?
        next unless row[:name]
        next unless row[:paypal]

        _, fsn = row[:name].split(' / ')[-2..]
        payee = Payee.find_by(fsn: fsn)
        unless payee
          puts("Payee not found: #{row[:name]}")
          next
        end
        payee.update!(paypal_account: row[:paypal])
      end

      # Album splits
      xlsx.sheet('ALBUM SALES').each_row_streaming(offset: 2, pad_cells: true) do |row|
        next if row[0].value.blank?

        album = Album.find_by(name: row[0].value)
        unless album
          puts("Album not found: #{row[0].value}")
          next
        end

        album.splits.destroy_all

        if album.bandcamp_url == 'https://thegarages.bandcamp.com/album/the-garages-vs-desert-bus-2021'
          # Hard-code split for child's play
          Split.create!(product: album, payee: Payee.find_by!(fsn: 'FS-032'), value: 1)
        else
          row[10..].map { |cell| cell&.value }.each_slice(2) do |payee_name, split|
            next if payee_name.blank?

            _name, fsn = payee_name.split(' / ')[-2..]
            payee = Payee.find_by!(fsn: fsn)

            Split.create!(product: album, payee: payee, value: split.to_i)
          end
        end
      end

      # TODO: track splits
    end

    xlsx.close
  end
end
