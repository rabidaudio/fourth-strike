# frozen_string_literal: true

# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# Test data for local development purposes

FactoryBot.create(:artist,
                  name: 'Taylor Swift',
                  aliases: ['T. Swift', 'Swifty', 'Blondie', 'Taylor Alison Swift'],
                  paypal_account: 'tswift@example.com',
                  discord_handle: 'swifty5',
                  bio: <<~MARKDOWN
                    **Taylor Alison Swift** (born December 13, 1989) is an American singer-songwriter.
                    A [subject of widespread public interest](https://en.wikipedia.org/wiki/Public_image_of_Taylor_Swift),
                    she has [influenced the music industry and popular culture](https://en.wikipedia.org/wiki/Cultural_impact_of_Taylor_Swift)
                    through her artistry, especially in songwriting, and entrepreneurship. She is an advocate of artists'
                    rights and women's empowerment.
                  MARKDOWN
                 )

FactoryBot.create(:artist,
                  name: 'Beyoncé',
                  aliases: ['Queen Bey', 'Beyoncé Giselle Knowles-Carter'],
                  paypal_account: 'bey@example.com',
                  discord_handle: 'queen_bey',
                  bio: <<~MARKDOWN
                    **Beyoncé Giselle Knowles-Carter** (born September 4, 1981) is an American singer, songwriter and
                    businesswoman. Dubbed as "[Queen Bey](https://en.wikipedia.org/wiki/Honorific_nicknames_in_popular_music#Beyonc%C3%A9)"
                    and a prominent [cultural figure](https://en.wikipedia.org/wiki/Cultural_impact_of_Beyonc%C3%A9)
                    of the 21st century, she has been recognized for her artistry and performances, with
                    [Rolling Stone](https://en.wikipedia.org/wiki/Rolling_Stone) naming her one of the greatest
                    vocalists of all time.
                  MARKDOWN
                 )

FactoryBot.create(:artist,
                  name: 'Lady Gaga',
                  aliases: ['Gaga', 'Stefani Joanne Angelina Germanotta', 'Mother Monster'],
                  paypal_account: 'gaga@example.com',
                  discord_handle: 'mother_monster',
                  bio: <<~MARKDOWN
                    **Stefani Joanne Angelina Germanotta** (born March 28, 1986), known professionally as Lady Gaga, is an
                    American singer-songwriter and actress. She is known for reinventing her image and showcasing versatility
                    in entertainment. Gaga started performing as a teenager by singing at [open mic](https://en.wikipedia.org/wiki/Open_mic)
                    nights and acting in school plays. She studied [Collaborative Arts Project 21](https://en.wikipedia.org/wiki/Collaborative_Arts_Project_21)
                    before leaving to pursue a music career. After a contract cancellation by [Def Jam Recordings](https://en.wikipedia.org/wiki/Def_Jam_Recordings),
                    Gaga worked as a songwriter for [Sony/ATV Music Publishing](https://en.wikipedia.org/wiki/Sony/ATV_Music_Publishing).
                    In 2007, she signed with [Interscope Records](https://en.wikipedia.org/wiki/Interscope_Records) and
                    [KonLive Distribution](https://en.wikipedia.org/wiki/KonLive_Distribution). Her breakthrough came the
                    following year with her debut studio album, [The Fame](https://en.wikipedia.org/wiki/The_Fame), and its
                    singles "Just Dance" and "Poker Face". The album was later reissued along with The Fame Monster (2009),
                    which yielded the successful singles "Bad Romance", "Alejandro" and "Telephone".
                  MARKDOWN
                 )
