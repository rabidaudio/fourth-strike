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

swift = FactoryBot.create(:artist,
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

bey = FactoryBot.create(:artist,
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

gaga = FactoryBot.create(:artist,
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

pop = FactoryBot.create(:album,
                        :with_splits,
                        name: 'The Garages Go Pop',
                        artist_name: 'The Garages',
                        distribution: {
                          swift.payee => 1,
                          gaga.payee => 1,
                          bey.payee => 1
                        })

FactoryBot.create(:track,
                  :with_splits,
                  name: 'Blank Space',
                  album: pop,
                  track_number: 1,
                  credits: 'By Taylor Swift, Max Martin, and Shellback.',
                  distribution: {
                    swift.payee => 1
                  },
                  lyrics: <<~LYRICS
                    Nice to meet you, where you been?\nI could show you incredible things\nMagic, madness, heaven, sin\nSaw you there and I thought\n"Oh, my God, look at that face\nYou look like my next mistake\nLove's a game, wanna play?" Ay\nNew money, suit and tie\nI can read you like a magazine\nAin't it funny? Rumors fly\nAnd I know you heard about me\nSo hey, let's be friends\nI'm dying to see how this one ends\nGrab your passport and my hand\nI can make the bad guys good for a weekend\nSo it's gonna be forever\nOr it's gonna go down in flames\nYou can tell me when it's over, mm\nIf the high was worth the pain\nGot a long list of ex-lovers\nThey'll tell you I'm insane\n'Cause you know I love the players\nAnd you love the game\n'Cause we're young, and we're reckless\nWe'll take this way too far\nIt'll leave you breathless, mm\nOr with a nasty scar\nGot a long list of ex-lovers\nThey'll tell you I'm insane\nBut I've got a blank space, baby\nAnd I'll write your name\nCherry lips, crystal skies\nI could show you incredible things\nStolen kisses, pretty lies\nYou're the King, baby, I'm your Queen\nFind out what you want\nBe that girl for a month\nWait, the worst is yet to come, oh, no\nScreaming, crying, perfect storms\nI can make all the tables turn\nRose garden filled with thorns\nKeep you second guessing like\n"Oh, my God, who is she?"\nI get drunk on jealousy\nBut you'll come back each time you leave\n'Cause, darling, I'm a nightmare dressed like a daydream\nSo it's gonna be forever\nOr it's gonna go down in flames\nYou can tell me when it's over, mm\nIf the high was worth the pain\nGot a long list of ex-lovers\nThey'll tell you I'm insane\n'Cause you know I love the players\nAnd you love the game\n'Cause we're young, and we're reckless (oh)\nWe'll take this way too far\nIt'll leave you breathless, mm (oh)\nOr with a nasty scar\nGot a long list of ex-lovers\nThey'll tell you I'm insane (insane)\nBut I've got a blank space, baby\nAnd I'll write your name\nBoys only want love if it's torture\nDon't say I didn't, say I didn't warn ya\nBoys only want love if it's torture\nDon't say I didn't, say I didn't warn ya\nSo it's gonna be forever\nOr it's gonna go down in flames\nYou can tell me when it's over (over)\nIf the high was worth the pain\nGot a long list of ex-lovers\nThey'll tell you I'm insane (I'm insane)\n'Cause you know I love the players\nAnd you love the game\n'Cause we're young, and we're reckless\nWe'll take this way too far (ooh)\nIt'll leave you breathless, mm\nOr with a nasty scar (leave a nasty scar)\nGot a long list of ex-lovers\nThey'll tell you I'm insane\nBut I've got a blank space, baby\nAnd I'll write your name
                  LYRICS
                 )

FactoryBot.create(:track,
                  :with_splits,
                  name: 'Telephone',
                  album: pop,
                  track_number: 2,
                  credits: 'By Stefani Germanotta. Featured vocals by Beyoncé Knowles-Carter.',
                  distribution: {
                    gaga.payee => 2,
                    bey.payee => 1
                  },
                  lyrics: <<~LYRICS
                    Hello, hello, baby\nYou called, I can't hear a thing\nI have got no service in the club, you see, see\nWha-wha-what did you say, oh\nYou're breaking up on me\nSorry, I cannot hear you, I'm kinda busy\nK-kinda busy, k-kinda busy\nSorry, I cannot hear you, I'm kinda busy\nJust a second\nIt's my favorite song they're gonna play\nAnd I cannot text you with a drink in my hand, eh?\nYou should've made some plans with me\nYou knew that I was free\nAnd now you won't stop calling me, I'm kinda busy\nStop calling, stop calling\nI don't wanna think anymore\nI got my head and my heart on the dance floor\nStop calling, stop calling\nI don't wanna talk anymore\nI got my head and my heart on the dance floor\nEh, eh, eh, eh, eh, eh, eh, eh, eh, eh, eh\nStop telephoning me\nEh, eh, eh, eh, eh, eh, eh, eh, eh, eh\nI'm busy\nEh, eh, eh, eh, eh, eh, eh, eh, eh, eh\nStop telephoning me\nEh, eh, eh, eh, eh, eh, eh, eh, eh, eh, eh\nCan call all you want, but there's no one home\nAnd you're not gonna reach my Telephone\nOut in the club, and I'm sipping that bubb\nAnd you're not gonna reach my Telephone\nCall all you want, but there's no one home\nAnd you're not gonna reach my Telephone\nOut in the club, and I'm sipping that bubb\nAnd you're not gonna reach my Telephone\nBoy, the way you blowing up my phone\nWon't make me leave no faster\nPut my coat on faster\nLeave my girls no faster\nI should've left my phone at home\n'Cause this is a disaster\nCalling like a collector\nSorry, I cannot answer\nNot that I don't like you, I'm just at a party\nAnd I am sick and tired of my phone r-ringing\nSometimes I feel like I live in Grand Central Station\nTonight I'm not taking no calls, 'cause I'll be dancing\n'Cause I'll be dancing, 'cause I'll be dancing\nTonight I'm not taking no calls, 'cause I'll be dancing\nStop calling, stop calling\nI don't wanna think anymore\nI got my head and my heart on the dance floor\nStop calling, stop calling\nI don't wanna talk anymore\nI got my head and my heart on the dance floor\nStop calling, stop calling\nI don't wanna think anymore\nI got my head and my heart on the dance floor\nStop calling, stop calling\nI don't wanna talk anymore\nI got my head and my heart on the dance floor\nEh, eh, eh, eh, eh, eh, eh, eh, eh, eh, eh\nStop telephoning me\nEh, eh, eh, eh, eh, eh, eh, eh, eh, eh\nI'm busy\nEh, eh, eh, eh, eh, eh, eh, eh, eh, eh\nStop telephoning me\nEh, eh, eh, eh, eh, eh, eh, eh, eh, eh, eh\nCan call all you want, but there's no one home\nAnd you're not gonna reach my Telephone\n'Cause I'm out in the club, and I'm sipping that bubb\nAnd you're not gonna reach my Telephone\nCall all you want, but there's no one home\nAnd you're not gonna reach my Telephone\n'Cause I'm out in the club, and I'm sipping that bubb\nAnd you're not gonna reach my Telephone\nMy Telephone, m-m-my Telephone\n'Cause I'm out in the club, and I'm sipping that bubb\nAnd you're not gonna reach my Telephone\nMy Telephone, m-m-my Telephone\n'Cause I'm out in the club, and I'm sipping that bubb\nAnd you're not gonna reach my Telephone\nWe're sorry (we're sorry)\nThe number you have reached is not in service at this time\nPlease check the number, or try your call again
                  LYRICS
                 )

FactoryBot.create(:track,
                  :with_splits,
                  name: 'Single Ladies (Put a Ring on It)',
                  album: pop,
                  track_number: 3,
                  credits: 'By Beyoncé Knowles, Christopher "Tricky" Stewart, and Terius "The-Dream" Nash.',
                  distribution: {
                    bey.payee => 1
                  },
                  lyrics: <<~LYRICS
                    All the single ladies, all the single ladies\nAll the single ladies, all the single ladies\nAll the single ladies, all the single ladies\nAll the single ladies\nNow put your hands up\nUp in the club, we just broke up\nI'm doing my own little thing\nDecided to dip and now you wanna trip\nCause another brother noticed me\nI'm up on him, he up on me\nDon't pay him any attention\nJust cried my tears, for three good years\nYa can't be mad at me\nCause if you liked it then you should have put a ring on it\nIf you liked it then you shoulda put a ring on it\nDon't be mad once you see that he want it\nIf you liked it then you shoulda put a ring on it\nOh, oh, oh, oh, oh, oh, oh, o-ohh\nOh, oh, oh, oh, oh, oh, oh, o-ohh\nIf you liked it then you should have put a ring on it\nIf you liked it then you shoulda put a ring on it\nDon't be mad once you see that he want it\nIf you liked it then you shoulda put a ring on it\nI got gloss on my lips, a man on my hips\nGot me tighter in my Dereon jeans\nActing up, drink in my cup\nI can care less what you think\nI need no permission, did I mention\nDon't pay him any attention\nCause you had your turn and now you gonna learn\nWhat it really feels like to miss me\nCause if you liked it then you should have put a ring on it\nIf you liked it then you shoulda put a ring on it\nDon't be mad once you see that he want it\nIf you liked it then you shoulda put a ring on it\nOh, oh, oh, oh, oh, oh, oh\nOh, oh, oh, oh, oh, oh, oh\nIf you liked it then you should have put a ring on it\nIf you liked it then you shoulda put a ring on it\nDon't be mad once you see that he want it\nIf you liked it then you shoulda put a ring on it\nOh, oh, oh, oh, oh, oh, oh, oh\nOh, oh, oh, oh, oh, oh, oh\nDon't treat me to the things of the world\nI'm not that kind of girl\nYour love is what I prefer, what I deserve\nHere's a man that makes me then takes me\nAnd delivers me to a destiny, to infinity and beyond\nPull me into your arms, say I'm the one you want\nIf you don't, you'll be alone\nAnd like a ghost I'll be gone\nAll the single ladies, all the single ladies\nAll the single ladies, all the single ladies\nAll the single ladies, all the single ladies\nAll the single ladies\nNow put your hands up, oh, oh, oh, oh, oh, oh, oh\nOh, oh, oh, oh, oh, oh, oh\nCause if you liked it then you should have put a ring on it\nIf you liked it then you shoulda put a ring on it\nDon't be mad once you see that he want it\nIf you liked it then you shoulda put a ring on it\nOh, oh, oh\nIf you liked it then you should have put a ring on it\nIf you liked it then you shoulda put a ring on it\nDon't be mad once you see that he want it\nIf you liked it then you shoulda put a ring on it\nOh, oh, oh
                  LYRICS
                 )
