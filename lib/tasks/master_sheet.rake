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
        payee = Payee.create_with(name: name).find_or_create_by!(fsn: fsn)
        if fsn.in?(Rails.application.config.app_config[:master_sheet][:payees][:charities])
          payee.update!(is_charity: true)
        end
      end

      # Add their paypal info

      xlsx.sheet('ROYALTIES').parse(name: 'NAME', paypal: 'PAYPAL')[2..].each do |row|
        next unless row[:name]
        next unless row[:paypal]

        _, fsn = row[:name].split(' / ')[-2..]
        next if fsn == 'FS-000' # org TODO

        payee = Payee.find_by(fsn: fsn)
        raise StandardError, "Payee not found: #{row[:name]}" unless payee

        payee.update!(paypal_account: row[:paypal])
      end

      # Album splits
      xlsx.sheet('ALBUM SALES').each_row_streaming(offset: 2, pad_cells: true) do |row|
        next if row[0].value.blank?

        if row[0].value.in?(Rails.application.config.app_config[:master_sheet][:splits][:skip_albums])
          puts("skipping #{row[0].value}")
          next
        end

        album = Album.find_by(name: row[0].value)

        # overrides
        if album.nil? && Rails.application.config.app_config[:master_sheet][:splits][:album_mappings].key?(row[0].value)
          true_url = Rails.application.config.app_config[:master_sheet][:splits][:album_mappings][row[0].value]
          album = Album.find_by(bandcamp_url: true_url)
        end

        # safe to skip any missing albums that don't have any splits either
        if album.nil? && row[10..].all?(&:empty?)
          puts("skipping #{row[0].value}")
          next
        end

        raise StandardError, "Album not found: #{row[0].value}" unless album

        album.splits.destroy_all

        overrides = Rails.application.config.app_config[:master_sheet][:splits][:overrides]
        if overrides.key?(album.bandcamp_url)
          overrides[album.bandcamp_url].each do |fsn, value|
            Split.create!(product: album, payee: Payee.find_by!(fsn: fsn), value: value)
          end
        else
          row[10..].map { |cell| cell&.value }.each_slice(2) do |payee_name, split|
            next if payee_name.blank?

            _name, fsn = payee_name.split(' / ')[-2..]
            payee = Payee.find_by!(fsn: fsn)

            Split.create!(product: album, payee: payee, value: split.to_i)
          end
        end
      end

      # Track splits
      xlsx.sheet('STREAMING (IND)').each_row_streaming(offset: 2, pad_cells: true) do |row|
        next if row[1].value.blank?

        next if row[1].value.in?(Rails.application.config.app_config[:master_sheet][:splits][:skip_tracks])

        track = Track.find_by(isrc: row[1].value)
        raise StandardError, "Unable to find track #{row[0].value} (#{row[1].value})" if track.nil?

        payees = []
        row[7..].map { |cell| cell&.value }.each_slice(2) do |payee_name, split|
          next if payee_name.blank?

          _name, fsn = payee_name.split(' / ')[-2..]
          next if fsn == 'FS-000' # org TODO

          payee = Payee.find_by(fsn: fsn)
          if payee.nil?
            puts("Skipping #{row[0].value} (#{row[1].value}): unable to find payee: #{payee_name}")
            payees = []
            break
          end
          payees << [payee, split.to_i]
        end

        payees.each do |payee, value|
          Split.create!(product: track, payee: payee, value: value)
        end
      end
    end

    xlsx.close
  end
end
