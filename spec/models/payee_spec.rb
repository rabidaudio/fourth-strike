# frozen_string_literal: true

# == Schema Information
#
# Table name: payees
#
#  id             :integer          not null, primary key
#  fsn            :string           not null
#  name           :string           not null
#  paypal_account :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_payees_on_fsn             (fsn) UNIQUE
#  index_payees_on_paypal_account  (paypal_account) UNIQUE
#
require 'rails_helper'

RSpec.describe Payee, type: :model do
  describe 'paid_out' do
    let(:payee) { create(:payee) }

    let!(:payouts) do
      [
        { amount: 2.55.to_money, payee: payee, paid_at: Time.zone.local(2020, 2, 1) },
        { amount: 3.50.to_money, payee: payee, paid_at: Time.zone.local(2021, 4, 1) },
        { amount: 50.25.to_money, payee: payee, paid_at: Time.zone.local(2023, 7, 1) },
        # A separate payout to a different user
        { amount: 100.to_money, payee: create(:payee), paid_at: Time.zone.local(2023, 11, 1) }
      ].map { |args| create(:payout, **args) }
    end

    context 'all time' do
      it 'should sum the total amount paid out' do
        expect(payee.paid_out).to eq 56.30.to_money
      end
    end

    context 'since' do
      it 'should sum the total amount paid out' do
        expect(payee.paid_out(since: Time.zone.local(2023, 1, 1))).to eq 50.25.to_money
      end
    end

    context 'empty' do
      it 'should return 0' do
        expect(create(:payee).paid_out).to eq 0.to_money
      end
    end

    context 'mixed currencies' do
      it 'should raise an error' do
        # force change the currency, ignoring validation rules
        payouts[0].update_attribute(:amount_currency, 'EUR') # rubocop:disable Rails/SkipsModelValidations

        expect { payee.paid_out }.to raise_error(StandardError, 'Cannot sum payouts in differenct currencies')
      end
    end
  end
end
