# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LocalizedDatetimeHelper do
  let(:service) do
    Class.new do
      include LocalizedDatetimeHelper

      attr_reader :controller

      def initialize(region)
        @controller = OpenStruct.new(region: region) # rubocop:disable Style/OpenStructUse
      end
    end
  end

  before do
    travel_to Time.zone.local(2024, 4, 29, 19, 45)
  end

  describe 'localized_date' do
    ['US', 'CA'].each do |region|
      context(region) do
        it 'should format dates' do
          expect(service.new(region).localized_date(Time.zone.today)).to eq('April 29, 2024')
        end
      end
    end

    ['GB', 'AU'].each do |region|
      context(region) do
        it 'should format dates' do
          expect(service.new(region).localized_date(Time.zone.today)).to eq('29 April 2024')
        end
      end
    end

    context 'other' do
      it 'should use a default' do
        expect(service.new('ES').localized_date(Time.zone.today)).to eq('2024-04-29')
      end
    end

    context 'unspecified' do
      it 'should use US' do
        expect(service.new(nil).localized_date(Time.zone.today)).to eq('April 29, 2024')
      end
    end
  end

  context 'localized_time' do
    ['US', 'AU'].each do |region|
      context(region) do
        it 'should format times' do
          expect(service.new(region).localized_time(Time.zone.now)).to eq('7:45 pm')
        end
      end
    end

    ['CA', 'GB'].each do |region|
      context(region) do
        it 'should format times' do
          expect(service.new(region).localized_time(Time.zone.now)).to eq('19:45')
        end
      end
    end

    context 'other' do
      it 'should use a default' do
        expect(service.new('ES').localized_time(Time.zone.now)).to eq('19:45')
      end
    end

    context 'unspecified' do
      it 'should use US' do
        expect(service.new(nil).localized_time(Time.zone.now)).to eq('7:45 pm')
      end
    end
  end
end
