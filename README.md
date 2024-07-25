# Fourth Strike

This is a web-app for tracking projects released by [Fourth Strike](https://fourth-strike.com/). It allows browsing the complete catalog and handles accounting and payouts to artists.

## Setup

```bash
# Install rbenv
sudo apt install rbenv # also update your .zshrc
#   brew install rbenv ruby-build openssl readline libyaml
# Install Ruby
rbenv install $(cat .ruby-version)
# Install system dependencies
sudo apt install sqlite3
#   brew install sqlite3
# Start postgres
# brew services start postgresql@14
# Install Ruby dependencies
gem install bundler -v '~> 2.5'
bundle install
# Install nvm
sudo apt install nvm # also update your .zshrc
  # brew install nvm
# Install Node:
nvm install 20 --lts
# Install JS dependencies
npm install
# Prepare database
rake db:create db:schema:load data:schema:load
```

## Run server

```bash
./bin/dev
```

## Testing

```bash
rspec # run ruby test suite
rubocop -a # ruby lint
brakeman # ruby SAST
yarn run jslint:fix # standard js linter
yarn run lint # lint and auto-fix everything
```

## Populating data from scratch

To load data up to the point of the switchover, the following was done.
To recreate requires several reports from the Drive to be placed in the `/exports` directory.

```bash
rake db:drop db:create db:migrate
# Load all album and track information from Bandcamp by crawling the website
rake bandcamp:load_releases fetch_credits=true
# Load all merch items from Bandcamp sale report
rake bandcamp:load_merch_items
# Attach ISRC/UPC data to albums and tracks, adding any tracks that were removed from Bandcamp as hidden tracks
rake distrokid:import_isrcs
# Load contributor splits from home sheet
rake home_sheet:load_splits
# Load sales data from bandcamp
rake bandcamp:load_report
# Load sales data from DistroKid
rake distrokid:load_report
# Load rendered services
rake home_sheet:load_rendered_services
# Load patreon sales
rake home_sheet:load_patreon
# Load internal merch orders
rake home_sheet:load_internal_merch_orders

# Load payouts
rake paypal:correct_paypal_accounts
rake paypal:load_payouts

# Album.where(artist_name: 'Sig Figs Collective').update_all(private: true)
# Merch.find_each { |m| Merch.reset_counters(m.id, :albums_count) }

# Grant appropriate users admin access
rails console # Admin.create!(discord_handle: ...)
```

This should not have to be redone, as the `.sqlite` file is saved to the drive. This is only for
record keeping purposes.

## Deployment

TODO
