# frozen_string_literal: true

require 'rails_helper'

# rubocop:disable Rails/I18nLocaleAssignment
RSpec.describe LocalizedDatetimeHelper do
  let(:service) { Class.new { extend LocalizedDatetimeHelper } }

  before do
    travel_to Time.zone.local(2024, 4, 29, 19, 45)
  end

  describe 'localized_date' do
    ['US', 'CA'].each do |region|
      context(region) do
        before { I18n.locale = "en-#{region}" }

        it 'should format dates' do
          expect(service.localized_date(Time.zone.today)).to eq('April 29, 2024')
        end
      end
    end

    ['GB', 'AU'].each do |region|
      context(region) do
        before { I18n.locale = "en-#{region}" }

        it 'should format dates' do
          expect(service.localized_date(Time.zone.today)).to eq('29 April 2024')
        end
      end
    end

    context 'other' do
      before { I18n.locale = 'es-ES' }

      it 'should use a default' do
        expect(service.localized_date(Time.zone.today)).to eq('2024-04-29')
      end
    end

    context 'unspecified' do
      it 'should use US' do
        I18n.locale = nil
        expect(service.localized_date(Time.zone.today)).to eq('April 29, 2024')
      end
    end
  end

  context 'localized_time' do
    ['US', 'AU'].each do |region|
      context(region) do
        before { I18n.locale = "en-#{region}" }

        it 'should format times' do
          expect(service.localized_time(Time.zone.now)).to eq('7:45 pm')
        end
      end
    end

    ['CA', 'GB'].each do |region|
      context(region) do
        before { I18n.locale = "en-#{region}" }

        it 'should format times' do
          expect(service.localized_time(Time.zone.now)).to eq('19:45')
        end
      end
    end

    context 'other' do
      before { I18n.locale = 'es-ES' }

      it 'should use a default' do
        expect(service.localized_time(Time.zone.now)).to eq('19:45')
      end
    end

    context 'unspecified' do
      it 'should use US' do
        I18n.locale = nil
        expect(service.localized_time(Time.zone.now)).to eq('7:45 pm')
      end
    end
  end
end
# rubocop:enable Rails/I18nLocaleAssignment
