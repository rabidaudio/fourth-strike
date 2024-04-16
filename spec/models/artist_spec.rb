# frozen_string_literal: true

# == Schema Information
#
# Table name: artists
#
#  id             :integer          not null, primary key
#  aliases        :text             not null
#  bio            :text
#  contact_info   :string
#  credit         :string
#  discord_handle :string           not null
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  payee_id       :integer
#
# Indexes
#
#  index_artists_on_discord_handle  (discord_handle) UNIQUE
#  index_artists_on_payee_id        (payee_id)
#
# Foreign Keys
#
#  payee_id  (payee_id => payees.id)
#
require 'rails_helper'

RSpec.describe Artist, type: :model do
  describe 'aliases' do
    context 'many' do
      it 'should access as an array but store as json' do
        artist = create(:artist, aliases: ['bruce', 'Springsteen', 'The Boss', 'e-street'])

        expect(artist.aliases).to be_an(Array)
        expect(artist.aliases).to eq(['bruce', 'Springsteen', 'The Boss', 'e-street'])
        expect(artist.attributes['aliases']).to eq('["bruce","Springsteen","The Boss","e-street"]')
      end
    end

    context 'one' do
      it 'should access as an array but store as json' do
        artist = create(:artist, aliases: ['mike'])

        expect(artist.aliases).to be_an(Array)
        expect(artist.aliases).to eq(['mike'])
        expect(artist.attributes['aliases']).to eq('["mike"]')
      end
    end

    context 'none' do
      it 'should return an empty array' do
        artist = create(:artist, aliases: nil)

        expect(artist.aliases).to be_an(Array)
        expect(artist.aliases).to be_empty
      end
    end
  end
end
