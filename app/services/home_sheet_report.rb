# frozen_string_literal: true

# Helper class for parsing content from the home sheet excel doc
# rubocop:disable Rails/Output,Metrics/ClassLength
class HomeSheetReport
  attr_reader :xlsx

  def initialize(path)
    require 'roo'
    @xlsx = Roo::Spreadsheet.open(path.to_s)
  end

  def self.parse_payee(payee_name_and_fsn)
    name, fsn = payee_name_and_fsn.split(' / ')[-2..]
    [name, fsn]
  end

  def load_all!
    CalculatorCache::Manager.defer_recompute do
      ActiveRecord::Base.transaction do
        load_payees!
        load_album_splits!
        load_track_splits!
        load_merch_splits!
      end
    end

    close
  end

  def load_payees!
    # skip header and Fourth Strike / FS-000
    xlsx.sheet('LOOKUP').column(2)[2..].each do |payee|
      name, fsn = payee.split(' / ')[-2..]
      payee = Payee.create_with(name: name).find_or_create_by!(fsn: fsn)
      payee.update!(is_charity: true) if fsn.in?(charities)
    end

    # Add their paypal info
    xlsx.sheet('ROYALTIES').parse(name: 'NAME', paypal: 'PAYPAL')[2..].each do |row|
      next unless row[:name]
      next unless row[:paypal]

      _, fsn = HomeSheetReport.parse_payee(row[:name])
      next if fsn == 'FS-000' # org TODO

      payee = Payee.find_by(fsn: fsn)
      raise StandardError, "Payee not found: #{row[:name]}" unless payee

      payee.update!(paypal_account: row[:paypal])
    end
  end

  def load_album_splits!
    xlsx.sheet('ALBUM SALES').each_row_streaming(offset: 2, pad_cells: true) do |row|
      next if row[0].blank?
      next if row[10].blank?

      if row[0].value.in?(skip_albums)
        puts("skipping #{row[0].value}")
        next
      end

      album = find_album(row[0].value)

      # safe to skip any missing albums that don't have any splits either
      if album.nil? && row[10..].all?(&:empty?)
        puts("skipping #{row[0].value}")
        next
      end

      raise StandardError, "Album not found: #{row[0].value}" unless album

      create_splits!(row, 10, album)
    end
  end

  def load_track_splits!
    xlsx.sheet('STREAMING (IND)').each_row_streaming(offset: 2, pad_cells: true) do |row|
      next if row[1].blank?
      next if row[7].blank?

      if row[1].value.in?(skip_tracks)
        puts("skipping #{row[1].value}")
        next
      end

      track = Track.find_by(isrc: row[1].value)
      raise StandardError, "Unable to find track #{row[0].value} (#{row[1].value})" if track.nil?

      create_splits!(row, 7, track)
    end
  end

  def load_merch_splits!
    xlsx.sheet('MERCH').each_row_streaming(offset: 2, pad_cells: true) do |row|
      next if row[0].blank?
      next if row[5].blank?

      if row[0].value.in?(skip_merch)
        puts("skipping #{row[0].value}")
        next
      end

      merch = Merch.find_by(sku: row[0].value)
      raise StandardError, "Unable to find merch #{row[0].value}" if merch.nil?

      create_splits!(row, 5, merch)
    end
  end

  delegate :close, to: :xlsx

  private

  def create_splits!(row, first_index, product) # rubocop:disable Metrics/MethodLength
    product.splits.destroy_all

    if overrides.key?(product.bandcamp_url)
      overrides[product.bandcamp_url].each do |fsn, value|
        Split.create!(product: product, payee: Payee.find_by!(fsn: fsn), value: value)
      end
      return
    end

    payees = []
    row[first_index..].map { |cell| cell&.value }.each_slice(2) do |payee_name, split|
      next if payee_name.blank?

      _name, fsn = HomeSheetReport.parse_payee(payee_name)
      if fsn == 'FS-000' # org TODO
        puts("Skipping #{product.name}: splits contains org")
        payees = []
        break
      end

      payee = Payee.find_by(fsn: fsn)
      if payee.nil?
        puts("Skipping #{product.name}: unable to find payee: #{payee_name}")
        payees = []
        break
      end
      if split.blank?
        puts("Skipping #{product.name}: no value assigned for #{payee_name}")
        payees = []
        break
      end
      payees << [payee, split.to_i]
    end

    payees.each do |payee, value|
      Split.create!(product: product, payee: payee, value: value)
    end
  end

  def find_album(name)
    album = Album.find_by(name: name)

    # overrides
    if album.nil? && album_mappings.key?(name)
      true_url = album_mappings[name]
      album = Album.find_by(bandcamp_url: true_url)
    end
    album
  end

  def config
    Rails.application.config.app_config[:home_sheet]
  end

  def album_mappings
    config[:splits][:album_mappings]
  end

  def overrides
    config[:splits][:overrides]
  end

  def skip_albums
    config[:splits][:skip_albums]
  end

  def skip_tracks
    config[:splits][:skip_tracks]
  end

  def skip_merch
    config[:splits][:skip_merch]
  end

  def charities
    config[:payees][:charities]
  end
end
# rubocop:enable Rails/Output,Metrics/ClassLength
