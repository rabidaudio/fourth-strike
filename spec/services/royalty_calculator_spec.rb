# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RoyaltyCalculator do
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

  context 'everything' do
    let(:service) { described_class.new }

    describe 'bandcamp_sale_payouts' do
      it 'should compute the amount owed' do
        expect(service.bandcamp_sale_payouts).to eq({
                                                      tay => ((200 * 30) + (0.20 * (25 * 5.55))).to_money,
                                                      bey => ((610 * 0.99) + (0.60 * (25 * 5.55))).to_money,
                                                      gaga => ((17 * 9.99) + (0.20 * (25 * 5.55))).to_money
                                                    })
      end
    end
  end

  context 'for user' do
    describe 'bandcamp_sale_payouts' do
      it 'should compute the amount owed' do
        expect(described_class.new(for_payee: tay).bandcamp_sale_payouts).to eq(
          { tay => ((200 * 30) + (0.20 * (25 * 5.55))).to_money }
        )

        expect(described_class.new(for_payee: bey).bandcamp_sale_payouts).to eq(
          { bey => ((610 * 0.99) + (0.60 * (25 * 5.55))).to_money }
        )

        expect(described_class.new(for_payee: gaga).bandcamp_sale_payouts).to eq(
          { gaga => ((17 * 9.99) + (0.20 * (25 * 5.55))).to_money }
        )
      end
    end
  end

  context 'for time period' do
    let(:service) { described_class.new(from: Time.zone.local(2020, 1, 1)) }

    describe 'bandcamp_sale_payouts' do
      it 'should compute the amount owed' do
        expect(service.bandcamp_sale_payouts).to eq({
                                                      tay => ((200 * 30) + (0.20 * (25 * 5.55))).to_money,
                                                      bey => ((0 * 0.99) + (0.60 * (25 * 5.55))).to_money,
                                                      gaga => ((0 * 9.99) + (0.20 * (25 * 5.55))).to_money
                                                    })
      end
    end
  end
end
