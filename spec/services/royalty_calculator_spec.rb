# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Payout calculations' do
  let!(:tay) { create(:payee) }
  let!(:bey) { create(:payee) }
  let!(:gaga) { create(:payee) }

  let!(:comp) do
    create(:album, :with_splits, distribution: {
             tay => 1,
             bey => 3,
             gaga => 1
           })
  end

  let!(:the_fame) do
    create(:album, :with_splits, distribution: {
             gaga => 1
           })
  end

  let!(:folklore) do
    create(:album, :with_splits, distribution: {
             tay => 1
           })
  end

  let(:single_ladies) do
    create(:track, :with_splits, distribution: {
             bey => 1
           })
  end

  before do
    create_list(:bandcamp_sale, 17, :album, product: the_fame,
                                            net_revenue_amount: 9.99.to_money,
                                            purchased_at: Time.zone.local(2008, 8, 19, 12, 0))

    create_list(:bandcamp_sale, 200, :album, product: folklore,
                                             net_revenue_amount: 30.to_money,
                                             purchased_at: Time.zone.local(2020, 6, 24, 12, 0))

    create_list(:bandcamp_sale, 610, :track, product: single_ladies,
                                             net_revenue_amount: 0.99.to_money,
                                             purchased_at: Time.zone.local(2008, 10, 8, 12, 0))

    create_list(:bandcamp_sale, 25, :album, product: comp,
                                            net_revenue_amount: 5.55.to_money,
                                            purchased_at: Time.zone.local(2024, 1, 1, 12, 0))
  end

  describe RoyaltyCalculator do
    # upfront_costs
    # bandcamp_revenue
    # distrokid_revenue
    # merchandise_revenue
    # net_income
    # organization_cut
    # donated_royalites
    # organization_income

    describe 'royalties_owed' do
      it 'should compute the amount owed' do
        expect(described_class.new(comp).royalties_owed).to eq({
                                                                 tay => (0.85 * 0.20 * (25 * 5.55)).to_money,
                                                                 bey => (0.85 * 0.60 * (25 * 5.55)).to_money,
                                                                 gaga => (0.85 * 0.20 * (25 * 5.55)).to_money
                                                               })
      end
    end

    context 'for time period' do
      let(:from) { Time.zone.local(2020, 1, 1) }

      describe 'bandcamp_sale_payouts' do
        it 'should compute the amount owed' do
          expect(described_class.new(folklore, from: from).royalties_owed).to eq({
                                                                                   tay => (0.85 * 200 * 30).to_money
                                                                                 })

          expect(described_class.new(the_fame, from: from).royalties_owed).to eq({
                                                                                   gaga => 0.to_money
                                                                                 })
        end
      end
    end
  end

  describe PayoutCalculator do
    describe 'total_owed' do
      it 'should compute the amount owed' do
        expect(described_class.new(tay).total_owed).to be_within(0.01.to_money).of(
          0.85 * ((200 * 30) + (0.20 * (25 * 5.55))).to_money
        )

        expect(described_class.new(bey).total_owed).to be_within(0.01.to_money).of(
          0.85 * ((610 * 0.99) + (0.60 * (25 * 5.55))).to_money
        )

        expect(described_class.new(gaga).total_owed).to be_within(0.01.to_money).of(
          0.85 * ((17 * 9.99) + (0.20 * (25 * 5.55))).to_money
        )
      end
    end

    context 'for time period' do
      let(:from) { Time.zone.local(2020, 1, 1) }

      it 'should compute the amount owed' do
        expect(described_class.new(tay, from: from).total_owed).to be_within(0.01.to_money).of(
          0.85 * ((200 * 30) + (0.20 * (25 * 5.55))).to_money
        )
        expect(described_class.new(bey, from: from).total_owed).to be_within(0.01.to_money).of(
          0.85 * ((0 * 0.99) + (0.60 * (25 * 5.55))).to_money
        )
        expect(described_class.new(gaga, from: from).total_owed).to be_within(0.01.to_money).of(
          0.85 * ((0 * 9.99) + (0.20 * (25 * 5.55))).to_money
        )
      end
    end
  end
end
