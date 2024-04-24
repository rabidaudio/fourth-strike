# frozen_string_literal: true

# == Schema Information
#
# Table name: splits
#
#  id              :integer          not null, primary key
#  splittable_type :string           not null
#  value           :integer          not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  payee_id        :integer          not null
#  splittable_id   :integer          not null
#
# Indexes
#
#  index_splits_on_payee_id    (payee_id)
#  index_splits_on_splittable  (splittable_type,splittable_id)
#
# Foreign Keys
#
#  payee_id  (payee_id => payees.id)
#
require 'rails_helper'

RSpec.describe Split, type: :model do
  describe 'splittable' do
    [:album, :track].each do |model|
      context 'single payee' do
        let(:payee) { create(:payee) }
        let(:target) { create(model, :with_splits, distribution: { payee => 1 }) }

        it 'should distribute all the money to the one contributor' do
          expect(target.weighted_distribution.size).to eq 1
          expect(target.weighted_distribution[payee]).to eq 1

          expect(target.payout_amounts(9.99.to_money)[payee]).to eq 9.99.to_money
        end
      end

      context 'even splits' do
        let(:payees) { create_list(:payee, 3) }
        let(:target) { create(model, :with_splits, distribution: payees.index_with { |_p| 1 }) }

        it 'should distribute all the money to the one contributor' do
          expect(target.weighted_distribution.size).to eq 3

          payees.each do |payee|
            expect(target.weighted_distribution[payee]).to be_within(0.0001).of(0.3333)
            # always round up in contributor's favor
            expect(target.payout_amounts(10.01.to_money)[payee]).to eq 3.34.to_money
          end
        end
      end

      context 'proportional splits'  do
        let(:alice) { create(:payee) }
        let(:bob) { create(:payee) }
        let(:chad) { create(:payee) }

        let(:target) do
          create(model, :with_splits, distribution: {
                   alice => 4,
                   bob => 2,
                   chad => 1
                 })
        end

        it 'should distribute all the money to the one contributor' do
          expect(target.weighted_distribution.size).to eq 3

          expect(target.weighted_distribution[alice]).to be_within(0.0001).of(0.5714)
          expect(target.payout_amounts(10.01.to_money)[alice]).to eq 5.72.to_money

          expect(target.weighted_distribution[bob]).to be_within(0.0001).of(0.2857)
          expect(target.payout_amounts(10.01.to_money)[bob]).to eq 2.86.to_money

          expect(target.weighted_distribution[chad]).to be_within(0.0001).of(0.1429)
          expect(target.payout_amounts(10.01.to_money)[chad]).to eq 1.43.to_money
        end
      end

      context 'no splits' do
        let(:target) { create(model) }

        it 'should return an empty hash' do
          expect(target.splits.size).to eq 0

          expect(target.weighted_distribution).to be_a(Hash)
          expect(target.weighted_distribution).to be_empty

          expect(target.payout_amounts(9.99.to_money)).to be_a(Hash)
          expect(target.payout_amounts(9.99.to_money)).to be_empty
        end
      end
    end
  end
end
