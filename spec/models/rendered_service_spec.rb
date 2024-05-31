# frozen_string_literal: true

# == Schema Information
#
# Table name: rendered_services
#
#  id                    :integer          not null, primary key
#  artist_name           :string
#  compensation_cents    :integer          default(0), not null
#  compensation_currency :string           default("USD"), not null
#  description           :text
#  hours                 :decimal(6, 2)
#  rendered_at           :date
#  type                  :integer
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  album_id              :integer
#  payee_id              :integer          not null
#
# Indexes
#
#  index_rendered_services_on_album_id  (album_id)
#  index_rendered_services_on_payee_id  (payee_id)
#
# Foreign Keys
#
#  album_id  (album_id => albums.id)
#  payee_id  (payee_id => payees.id)
#
require 'rails_helper'

RSpec.describe RenderedService, type: :model do
  describe 'type' do
    context 'hourly' do
      it 'should require hours' do
        s = build(:rendered_service, :hourly, hours: nil, compensation: 5.to_money)
        expect(s).not_to be_valid
        expect(s.errors.full_messages_for(:hours)).to include("Hours can't be blank")
      end

      it 'should compute compensation if not provided' do
        s = build(:rendered_service, :hourly, hours: 1.5, compensation: 0)
        s.save!
        expect(s.compensation).to eq 22.50.to_money
      end
    end

    context 'fixed' do
      it 'should require no hours' do
        s = build(:rendered_service, :fixed, hours: 5)
        expect(s).not_to be_valid
        expect(s.errors.full_messages_for(:hours)).to include('Hours must be blank')
      end
    end
  end
end
