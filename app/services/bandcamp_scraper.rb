# frozen_string_literal: true

# Extract album data from the Bandcamp website
module BandcampScraper
  extend self

  def extract_album_info(bandcamp_url) # rubocop:disable Metrics/AbcSize
    data = HTTP.get(bandcamp_url)
    body = Nokogiri::XML.parse(data.body.to_s)

    metadata = JSON.parse(body.css('script[type="application/ld+json"]').text)
    name = metadata['name']
    artist_name = metadata['byArtist']['name']
    album_art_url = metadata['image']
    release_date = Date.parse(metadata['datePublished'])

    release = metadata['albumRelease'].find { |r| r['@id'] == bandcamp_url }

    bandcamp_id = release['additionalProperty'].find { |p| p['name'] == 'item_id' }['value'].to_s
    bandcamp_price = release['offers']['price'].to_money(release['offers']['priceCurrency'])

    tracks = metadata['track']['itemListElement'].map do |track|
      {
        track_number: track['position'],
        bandcamp_id: track['item']['additionalProperty'].find { |p| p['name'] == 'track_id' }['value'].to_s,
        bandcamp_url: track['item']['@id'],
        name: track['item']['name'],
        lyrics: track.dig('item', 'recordingOf', 'lyrics', 'text')
      }
    end

    {
      name: name,
      artist_name: artist_name,
      album_art_url: album_art_url,
      release_date: release_date,
      bandcamp_id: bandcamp_id,
      bandcamp_price: bandcamp_price,
      tracks: tracks
    }
  end
end
