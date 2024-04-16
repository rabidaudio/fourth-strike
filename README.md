# Fourth Strike

This is a web-app for tracking projects released by [Fourth Strike](https://fourth-strike.com/). It allows browsing the complete catalog and handles accounting and payouts to artists.

## Setup

```bash
# Install rbenv
sudo apt install rbenv # also update your .zshrc
#   brew install rbenv ruby-build openssl readline libyaml
# Install Ruby
$ rbenv install $(cat .ruby-version)
# Install system dependencies
$ sudo apt install sqlite3
#   brew install sqlite3
# Start postgres
# brew services start postgresql@14
# Install Ruby dependencies
$ gem install bundler -v '~> 2.5'
$ bundle install
# Install nvm
brew install nvm # also update your .zshrc
# Install Node:
$ nvm install 20 --lts
# Install JS dependencies
$ npm install
# Prepare database
$ rake db:create db:schema:load data:schema:load db:seed
```

### Run migrations

```bash
rake db:migrate:with_data && rake db:seed
```

## Testing

```bash
rubocop -a # ruby lint
brakeman # ruby SAST
yarn run jslint:fix # standard js linter
yarn run lint # lint and auto-fix everything
```

## Deployment

TODO