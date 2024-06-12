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

  let(:producer) { create(:payee) }

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

    (0...12).each do |m|
      create(:distrokid_sale, product: single_ladies,
                              quantity: 7_823_220,
                              earnings_usd: (0.00318 * 7_823_220),
                              sale_period: Time.zone.local(2023, 1, 1) + m.months)
    end
  end

  describe RoyaltyCalculator do
    # bandcamp_revenue
    # distrokid_revenue
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

    describe 'bandcamp_revenue' do
      it 'should compute album sale revenue' do
        expect(described_class.new(single_ladies).bandcamp_revenue).to eq 603.90.to_money
      end
    end

    describe 'distrokid' do
      it 'should compute streaming revenue' do
        expect(described_class.new(single_ladies).distrokid_revenue).to eq 298_534.08.to_money

        expect(described_class.new(single_ladies).royalties_owed).to eq({
                                                                          bey => (0.85 * (603.90 + 298_534.08)).to_money
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

    describe 'services rendered' do
      context 'for project' do
        before do
          create(:rendered_service, :fixed, compensation: 50.to_money, album: the_fame, description: 'Artwork')
          create(:rendered_service, :hourly, hours: 2, album: the_fame, description: 'Mastering', payee: producer)
        end

        it 'should exclude project costs before computing distribution' do
          expect(described_class.new(the_fame).upfront_costs).to eq (50 + 30).to_money
          expect(described_class.new(the_fame).royalties_owed).to eq({
                                                                       gaga => ((169.83 - 80) * 0.85).to_money
                                                                     })
        end

        context 'negative revenue' do
          before do
            create(:rendered_service, :hourly, hours: 10, album: the_fame, description: 'Additional Mastering',
                                               payee: producer)
          end

          it 'should report $0 royalties and a loss for org' do
            expect(described_class.new(the_fame).upfront_costs).to eq (50 + 30 + 150).to_money

            expect(described_class.new(the_fame).organization_income).to eq (169.83 - 230).to_money
            expect(described_class.new(the_fame).royalties_owed_to(gaga)).to eq 0.to_money
          end
        end
      end

      context 'administrative' do
        before do
          create(:rendered_service, description: 'Merch fulfillment', album: nil)
        end

        it 'should not be included in royalty payments' do
          expect(described_class.new(the_fame).upfront_costs).to eq 0.to_money
          expect(described_class.new(the_fame).royalties_owed).to eq({
                                                                       gaga => (169.83 * 0.85).to_money
                                                                     })
        end
      end
    end

    describe 'merch' do
      let(:fame_cassette) do
        create(:merch, :cassette, :with_splits, album: the_fame, list_price: 25.00.to_money, distribution: {
                 gaga => 1
               })
      end

      let!(:merch_orders) do
        create_list(:bandcamp_sale, 100, :merch, product: fame_cassette, net_revenue_amount: 21.10.to_money)
      end

      context 'fulfilled' do
        before do
          merch_orders.each do |order|
            create(:merch_fulfillment, bandcamp_sale: order, production_cost: 5.50.to_money)
          end
        end

        it 'should compute the royalties owed for the merch, removing the cost of goods' do
          expect(described_class.new(fame_cassette).cost_of_goods).to eq(550.to_money)

          expect(described_class.new(fame_cassette).bandcamp_revenue).to eq (
            (100 * 21.10) - # merch sales
            (100 * 5.50) # cost of goods
          ).to_money

          expect(described_class.new(fame_cassette).royalties_owed_to(gaga)).to be_within(0.01.to_money).of(
            (1560.0 * 0.85).to_money
          )
        end
      end

      context 'unfulfilled' do
        it 'should not pay out any royalties for unfulfulled orders' do
          expect(described_class.new(fame_cassette).bandcamp_revenue).to eq 0.to_money
        end
      end
    end
  end

  describe PayoutCalculator do
    describe 'total_owed' do
      before do
        create(:rendered_service, :fixed, compensation: 50.to_money, album: the_fame, description: 'Artwork')
        create(:rendered_service, :hourly, hours: 2, album: the_fame, description: 'Mastering', payee: producer)
        CalculatorCache::Manager.recompute_all!
      end

      it 'should compute the amount owed' do
        expect(described_class.new(tay).total_owed).to be_within(0.01.to_money).of(
          0.85 * ((200 * 30) + (0.20 * (25 * 5.55))).to_money
        )

        expect(described_class.new(bey).total_owed).to be_within(0.01.to_money).of(
          0.85 * ((610 * 0.99) + 298_534.08 + (0.60 * (25 * 5.55))).to_money
        )

        expect(described_class.new(gaga).total_owed).to be_within(0.01.to_money).of(
          0.85 * ((17 * 9.99) + ((0.20 * (25 * 5.55)) - 50 - 30)).to_money
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
          0.85 * ((0 * 0.99) + 298_534.08 + (0.60 * (25 * 5.55))).to_money
        )
        expect(described_class.new(gaga, from: from).total_owed).to be_within(0.01.to_money).of(
          0.85 * ((0 * 9.99) + (0.20 * (25 * 5.55))).to_money
        )
      end
    end
  end
end
