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
      album: {
        name: 'THE GARAGES SIGN OFF @ DESERT BUS 2024',
        artist_name: 'the garages',
        album_art_url: 'https://f4.bcbits.com/img/a0623417941_16.jpg',
        bandcamp_price: { cents: 666, currency: 'USD' },
        release_date: '2024-11-13',
        bandcamp_id: '827202132'
      },
      tracks: [
        {
          bandcamp_url: 'https://thegarages.bandcamp.com/track/bones-to-ohio-anyone-else-live-db2024',
          bandcamp_id: '3812987682',
          name: 'bones to ohio (anyone else) [live @ db2024]',
          track_number: 1,
          lyrics: <<~LYRICS,
            i wanna be anyone
            i wanna be anyone anyone else
            anyone else but me

            give it up for a thicker shell
            i wanna be anyone anyone else
            so what’s it gonna be?

            don’t care if it hurts like hell
            i just wanna tear away every sticky cell
            that feels anything anything anything like myself

            don’t need anybody’s help
            i’m gonna be anyone anyone else

            yeah the shell is strong but the body’s weak
            you gotta learn how to yell before you learn how to speak
            it’s all bitter work with your face in the dirt
            do you think it’ll sting do you think it’ll hurt
            i want the burning taste of infinity
            put the scales in my eyes where everybody can see
            i just wanna be ok
            and i don’t wanna be myself today

            nothing left to call home
            half a season to be alone, be alone again
            what’s it take to leave

            my skin keeps getting tight
            i need someone to dig me out dig me out tonight
            and learn how to breathe

            nothing left in this desert town
            gonna burn it all burn it all burn it all down
            so what’s it gonna be?

            calling out for a god to help
            i’m gonna be anyone anyone else

            yeah the shell is strong but the body’s weak
            you gotta learn how to yell before you learn how to speak
            it’s all bitter work with your face in the dirt
            do you think it’ll sting do you think it’ll hurt
            i want the burning taste of infinity
            put the scales in my eyes where everybody can see
            i just wanna be ok
            i just wanna be ok

            i left a decent life for a step outside
            when it all comes down, will we be alright
            (hold on to me, darling, hold on to me)
            i swear i’m on a knife’s edge waiting to fall for anything
            i don’t care what the future brings
            i just gotta get away from the rest of me
            (hold on to me, darling, hold on to me)
            i don’t wanna be dead, i just wanna be free
            i don’t wanna be dead, i just wanna be free

            yeah the shell is strong but the body’s weak
            you gotta learn how to yell before you learn how to speak
            it’s all bitter work with your face in the dirt
            do you think it’ll sting do you think it’ll hurt
            i want the burning taste of infinity
            put the scales in my eyes where everybody can see
            i’m getting sick and tired of the shape i’m in
            do you think it’ll fail, do you think it’s a sin
            as i disappear in the hole in the sky
            was it worth all the pain? was it all just a lie?
            my body's getting sore
            and i'm not gonna be myself anymore
          LYRICS
          credits: <<~CREDITS
            written by max (noise-land.bandcamp.com)
            originally on short circuit 02
            lead vocals by riley (yuppiesupper.bandcamp.com, @thwackamabob on tumblr and twitter)
            backing vocals by vigilant baker (vigilantbaker.bandcamp.com)
            lead guitar by max (noise-land.bandcamp.com)
            rhythm guitar by rolo (jenandrolo.bandcamp.com) and raph (apha.bandcamp.com, twitter.com/aphamusic)
            drums by hibi (hibi.bandcamp.com, twitter.com/hibiscuitss)
            bass by jennifer cat (jenandrolo.bandcamp.com)
            sax by rosie (thornsband.bandcamp.com, @rosie.drown on instagram)
            gang vocals by em (vigilanceandgrace.bandcamp.com), pitch (imperfectpitch.bandcamp.com), cliff, astrid, ras (ebhband.bandcamp.com), and tegan (tonalchroma.bandcamp.com)#{' '}
          CREDITS
        }
      ]
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
      album: @album,
      tracks: []
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
