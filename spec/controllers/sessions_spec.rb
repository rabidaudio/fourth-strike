# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let(:id) { Faker::Number.number(digits: 18).to_s }
  let(:username) { Faker::Internet.username }

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:discord] =
      OmniAuth::AuthHash.new({
                               provider: 'discord',
                               uid: id,
                               info: {
                                 name: 'Discord User',
                                 email: nil,
                                 image: 'https://cdn.discordapp.com/avatars/727726489818103859/5ba1aec93ca5caa13193908a7ac02718'
                               },
                               credentials: {
                                 token: Faker::Crypto.md5,
                                 refresh_token: Faker::Crypto.md5,
                                 expires_at: 5.days.from_now.to_i,
                                 expires: true
                               },
                               extra: { raw_info: {
                                 id: id,
                                 username: username,
                                 avatar: '5ba1aec93ca5caa13193908a7ac02718',
                                 discriminator: '0',
                                 public_flags: 0,
                                 flags: 0,
                                 banner: nil,
                                 accent_color: 1_096_261,
                                 global_name: 'Discord User',
                                 avatar_decoration_data: nil,
                                 banner_color: '#10BA45',
                                 clan: nil,
                                 mfa_enabled: false,
                                 locale: 'en-US',
                                 premium_type: 0
                               } }
                             })
  end

  context 'logged out' do
    describe 'create' do
      before do
        request.env['omniauth.auth'] = OmniAuth.config.mock_auth[:discord]
      end

      let!(:artist) { create(:artist, discord_handle: username) }

      it 'should set the current user' do
        get :create, params: { provider: 'discord' }

        expect(controller.current_user).to be_a(User)
        expect(controller.current_user.username).to eq username
        expect(controller.current_user).not_to be_expired
        expect(controller.current_user).to be_artist
        expect(controller.current_user.artist).to eq artist
      end

      it 'should redirect to the root path' do
        get :create, params: { provider: 'discord' }

        expect(response).to redirect_to('/')
      end

      context 'with a redirect url' do
        before do
          request.env['omniauth.origin'] = artist_path(artist.id)
        end

        it 'should redirect to the original destination' do
          get :create, params: { provider: 'discord' }

          expect(controller.current_user).to be_a(User)
          expect(response).to redirect_to("/artists/#{artist.id}")
        end
      end

      context 'with admin' do
        before do
          create(:admin, discord_handle: username)
        end

        it 'should set the current user' do
          get :create, params: { provider: 'discord' }

          expect(controller.current_user).to be_a(User)
          expect(controller.current_user.username).to eq username
          expect(controller.current_user).not_to be_expired
          expect(controller.current_user).to be_admin
        end
      end

      context 'not an artist or admin' do
        before do
          artist.update!(discord_handle: '_a_different_handle')
        end

        it 'should flash a warning and not log in' do
          get :create, params: { provider: 'discord' }

          expect(controller.current_user).to be_nil
          expect(controller.flash[:warning]).to match(/No profile exists for discord user/)
          expect(response).to redirect_to('/')
        end
      end
    end
  end

  context 'logged in' do
    before do
      create(:artist, discord_handle: username)
      controller.session['user'] = OmniAuth.config.mock_auth[:discord].to_h
    end

    describe 'visit a page' do
      controller do
        # just a dummy endpoint, representative of any controller endpoint
        def index
          render plain: 'OK'
        end
      end

      context 'valid' do
        it 'should report the current user' do
          get :index

          expect(controller.current_user).to be_a(User)
          expect(controller.current_user.expires_at).to be > 2.days.from_now
          expect(controller.current_user).not_to be_expired
          expect(controller.current_user).not_to be_expires_soon
        end
      end

      context 'about to expire' do
        before do
          controller.session['user'] =
            OmniAuth.config.mock_auth[:discord].to_h
                    .deep_merge({
                                  'credentials' => { 'expires_at' => 4.hours.from_now.to_i }
                                })

          stub_request(:post, /discord\.com/).to_return(body: {
            access_token: '6qrZcUqja7812RVdnEKjpzOL4CvHBFG',
            token_type: 'Bearer',
            expires_in: 604_800,
            refresh_token: 'D43f5y0ahjqew82jZ4NViEr2YafMKhue',
            scope: 'identify'
          }.to_json, headers: { 'Content-Type' => 'application/json' })
        end

        it 'should refresh the token' do
          get :index

          expect(controller.current_user).not_to be_expires_soon
          expect(controller.current_user.refresh_token).to eq 'D43f5y0ahjqew82jZ4NViEr2YafMKhue'
          expect(controller.current_user.expires_at).to be_within(1.second).of(604_800.seconds.from_now)
        end

        context 'refresh failure' do
          before do
            stub_request(:post, /discord\.com/).to_return(status: 501)
          end

          it 'should keep you logged in until expiry' do
            get :index

            expect(controller.current_user).not_to be_nil
            expect(controller.current_user).to be_expires_soon
          end
        end

        context 'discord down' do
          before do
            stub_request(:post, /discord\.com/).to_timeout
          end

          it 'should keep you logged in until expiry' do
            get :index

            expect(controller.current_user).not_to be_nil
            expect(controller.current_user).to be_expires_soon
          end
        end
      end
    end

    describe 'destroy' do
      it 'should log you out' do
        delete :destroy

        expect(controller.current_user).to be_nil
        expect(controller.session['user']).to be_nil
      end
    end
  end
end
