# frozen_string_literal: true

class AlbumsController < ApplicationController
  # before_action :raise_unless_logged_in!, except: [:index, :show]

  def index
    @albums = Album.order(release_date: :desc)
    @albums = @albums.where(private: false) unless logged_in? # Hide private albums from public
    @albums = @albums.where('lower(artist_name) like ?', params[:artist].downcase) if params[:artist]
    @albums = @albums.paginate(page: params[:page] || 1, per_page: 200)
  end

  def show
    @album = Album.find(params[:id])
    raise_unless_logged_in! if @album.private?
  end

  def extract_bandcamp_details
    render json: {
      name: 'THE GARAGES SIGN OFF @ DESERT BUS 2024',
      artist_name: 'the garages',
      album_art_url: 'https://f4.bcbits.com/img/a0623417941_16.jpg',
      bandcamp_price: { cents: 666, currency: 'USD' },
      release_date: '2024-11-13',
      bandcamp_id: '827202132'
    }
  end

  def new
    #  id                      :integer          not null, primary key
    #  album_art_url           :string
    #  artist_name             :string           not null
    #  bandcamp_price_cents    :integer          default(0), not null
    #  bandcamp_price_currency :string           default("USD"), not null
    #  bandcamp_url            :string           not null
    #  catalog_number          :string
    #  name                    :string           not null
    #  private                 :boolean          default(FALSE), not null
    #  release_date            :date
    #  upcs                    :string
    #  created_at              :datetime         not null
    #  updated_at              :datetime         not null
    #  bandcamp_id             :string

    @album = Album.new(artist_name: 'the garages')
    # restore_changes!(@album)
    @props = {
      album: @album
    }
  end

  def create
    # data = HTTP.get('https://thegarages.bandcamp.com/album/the-garages-sign-off-desert-bus-2024')
    # body = Nokogiri::XML.parse(data.body.to_s)
    # album_art_url = body.css('a.popupImage').attr('href').value

    # metadata = JSON.parse(body.css('script[type="application/ld+json"]').text)
    # artist_name = metadata.name

    # metadata = JSON.parse(body.css("script[data-tralbum]").attr('data-tralbum').value)
    # private = !metadata['current']['private'].nil?
    # name = metadata['current']['title']
    # metadata['album_release_date']
    # metadata['current']['minimum_price'].to_money('USD')

    # metadata = JSON.parse(body.css('#pagedata').attr('data-blob').value)
    # bandcamp_id = metadata['album_id']
  end
end
