# Fourth Strike

[This is a web-app](https://app.fourth-strike.com) for tracking projects released by [Fourth Strike](https://fourth-strike.com/). It allows browsing the complete catalog and handles accounting and payouts to artists.

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
To recreate requires several reports from the Drive to be placed in the `/storage/exports` directory.

```bash
rake db:drop db:create db:migrate
# Load all album and track information from Bandcamp by crawling the website
rake bandcamp:load_releases fetch_credits=true
# Load all merch items from Bandcamp sale report
rake bandcamp:load_merch_items
# Load additional merch items that aren't on bandcamp
rake home_sheet:load_merch_items
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

rails console
# Basic cleanup
# Merch.find_each { |m| Merch.reset_counters(m.id, :albums_count) }

# Grant appropriate users admin access
# Admin.create!(discord_handle: ...)
```

This should not have to be redone, as the `.sqlite` file is saved to the drive. This is only for
record keeping purposes.

Normally it's good to use a "real" database in production rather than sqlite, but here we're trying
to keep costs low, and the size, performance, and concurrency requirements are very low. It also
keeps backups/record keeping incredibly simple.

## Deployment

App is hosted on a DigitalOcean droplet, inside of docker compose, accessed via SSH.
A volume is mounted for persistent storage for portability and backup purposes. An
nginx container acts as SSL termination and certificates are provided by Let'sEncrypt.

If loading a lot of data into production, it can help to scale up to a larger instance for a bit
and then scale back down when finished.

## Initial Deployment

```bash
# Mount the external volume
mkdir -p /mnt/volume_nyc3_01
mount -o discard,defaults,noatime /dev/disk/by-id/scsi-0DO_Volume_volume-nyc3-01 /mnt/volume_nyc3_01
mkdir -p /mnt/volume_nyc3_01/storage
# Make it auto-mount
echo '/dev/disk/by-id/scsi-0DO_Volume_volume-nyc3-01 /mnt/volume_nyc3_01 ext4 defaults,nofail,discard 0 0' | sudo tee -a /etc/fstab
# Create a persistent docker volume for it
docker volume create --opt type=none --opt o=bind --opt device=/mnt/volume_nyc3_01/storage storage
# Load code
git clone https://github.com/rabidaudio/fourth-strike
cd fourth-strike
docker compose run app DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bin/rake db:schema:load
docker compose start
```

## Updates

```bash
cd fourth-strike
# pull latest code
git pull
# Build latest docker images
docker compose build
# Restart containers
docker compose restart
# Run any pending migrations
docker compose run app rake db:migrate
```
