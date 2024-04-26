# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'PaginationHelper', type: :controller do
  controller do
    include PaginationHelper

    def index
      FactoryBot.create_list(:album, params[:total_items].to_i)
      render_pagination(Album.all.paginate(page: params[:page], per_page: 1), always_show: true)
    end
  end

  render_views

  describe 'render_pagination' do
    context 'first page' do
      it 'should render appropriate html' do
        get :index, params: { total_items: 9, page: 1 }

        body = Nokogiri.parse(response.body)
        expect(body.at_css('nav').attr('role')).to eq('navigation')
        expect(body.at_css('.pagination-previous').classes).to include('is-disabled')
        expect(body.at_css('.pagination-next').classes).not_to include('is-disabled')
        expect(body.at_css('.pagination-next').attr('href')).to include('page=2')

        expect(body.at_css('.pagination-link.is-current')).not_to be_nil
        expect(body.css('ul.pagination-list li a').count).to eq 5
        expect(body.css('ul.pagination-list li .pagination-ellipsis').count).to eq 1
      end
    end

    context 'middle page' do
      context 'many pages' do
        it 'should render appropriate html' do
          get :index, params: { total_items: 9, page: 5 }

          body = Nokogiri.parse(response.body)
          expect(body.at_css('nav').attr('role')).to eq('navigation')
          expect(body.at_css('.pagination-previous').classes).not_to include('is-disabled')
          expect(body.at_css('.pagination-previous').attr('href')).to include('page=4')
          expect(body.at_css('.pagination-next').classes).not_to include('is-disabled')
          expect(body.at_css('.pagination-next').attr('href')).to include('page=6')

          expect(body.at_css('.pagination-link.is-current')).not_to be_nil
          expect(body.css('ul.pagination-list li a').count).to eq 5
          expect(body.css('ul.pagination-list li .pagination-ellipsis').count).to eq 2
        end
      end

      context 'few pages' do
        it 'should render appropriate html' do
          get :index, params: { total_items: 4, page: 2 }

          body = Nokogiri.parse(response.body)
          expect(body.at_css('nav').attr('role')).to eq('navigation')
          expect(body.at_css('.pagination-previous').classes).not_to include('is-disabled')
          expect(body.at_css('.pagination-previous').attr('href')).to include('page=1')
          expect(body.at_css('.pagination-next').classes).not_to include('is-disabled')
          expect(body.at_css('.pagination-next').attr('href')).to include('page=3')

          expect(body.at_css('.pagination-link.is-current')).not_to be_nil
          expect(body.css('ul.pagination-list li a').count).to eq 4
          expect(body.css('ul.pagination-list li .pagination-ellipsis').count).to eq 0
        end
      end
    end

    context 'last page' do
      it 'should render appropriate html' do
        get :index, params: { total_items: 9, page: 9 }

        body = Nokogiri.parse(response.body)
        expect(body.at_css('nav').attr('role')).to eq('navigation')

        expect(body.at_css('.pagination-previous').classes).not_to include('is-disabled')
        expect(body.at_css('.pagination-previous').attr('href')).to include('page=8')
        expect(body.at_css('.pagination-next').classes).to include('is-disabled')

        expect(body.at_css('.pagination-link.is-current')).not_to be_nil
        expect(body.css('ul.pagination-list li a').count).to eq 5
        expect(body.css('ul.pagination-list li .pagination-ellipsis').count).to eq 1
      end
    end

    context 'with additional query string parameters' do
      it 'should not disrupt existing query parameters' do
        get :index, params: { total_items: 4, page: 2, foo: 'bar', obj: { key: 'value' }, array: [1, 2, 3] }

        body = Nokogiri.parse(response.body)
        expect(body.at_css('.pagination-previous').attr('href')).to include(
          '?array%5B%5D=1&array%5B%5D=2&array%5B%5D=3&foo=bar&obj%5Bkey%5D=value&page=1&total_items=4'
        )
        expect(body.at_css('.pagination-next').attr('href')).to include(
          '?array%5B%5D=1&array%5B%5D=2&array%5B%5D=3&foo=bar&obj%5Bkey%5D=value&page=3&total_items=4'
        )
      end
    end

    context 'one page' do
      # unfortunately we can't easily test this case thanks to the way the test is structured
      # it 'should do nothing'

      context 'always show' do
        it 'should render pagination' do
          get :index, params: { total_items: 1, page: 1 }

          body = Nokogiri.parse(response.body)
          expect(body.at_css('nav').attr('role')).to eq('navigation')
          expect(body.at_css('.pagination-previous').classes).to include('is-disabled')
          expect(body.at_css('.pagination-next').classes).to include('is-disabled')

          expect(body.at_css('.pagination-link.is-current')).not_to be_nil
          expect(body.css('ul.pagination-list li a').count).to eq 1
          expect(body.css('ul.pagination-list li .pagination-ellipsis').count).to eq 0
        end
      end
    end
  end

  # This unit tests a specific internal method that is rather complicated
  describe 'compute_pages_to_show' do
    let(:helper) do
      Class.new { extend PaginationHelper }
    end

    it 'should show [page_buttons] buttons around current, including the first and last, with ellipses at skips' do
      # [1] 2  3  4..9
      #  1 [2] 3  4..9
      #  1  2 [3] 4..9
      #  1..3 [4] 5..9
      #  1..4 [5] 6..9
      #  1..5 [6] 7..9
      #  1..6 [7] 8  9
      #  1..6  7 [8] 9
      #  1..6  7  8 [9]
      expect(helper.send(:compute_pages_to_show, 1, 9, 5)).to eq([1, 2, 3, 4, :ellipsis, 9])
      expect(helper.send(:compute_pages_to_show, 2, 9, 5)).to eq([1, 2, 3, 4, :ellipsis, 9])
      expect(helper.send(:compute_pages_to_show, 3, 9, 5)).to eq([1, 2, 3, 4, :ellipsis, 9])
      expect(helper.send(:compute_pages_to_show, 4, 9, 5)).to eq([1, :ellipsis, 3, 4, 5, :ellipsis, 9])
      expect(helper.send(:compute_pages_to_show, 5, 9, 5)).to eq([1, :ellipsis, 4, 5, 6, :ellipsis, 9])
      expect(helper.send(:compute_pages_to_show, 6, 9, 5)).to eq([1, :ellipsis, 5, 6, 7, :ellipsis, 9])
      expect(helper.send(:compute_pages_to_show, 7, 9, 5)).to eq([1, :ellipsis, 6, 7, 8, 9])
      expect(helper.send(:compute_pages_to_show, 8, 9, 5)).to eq([1, :ellipsis, 6, 7, 8, 9])
      expect(helper.send(:compute_pages_to_show, 9, 9, 5)).to eq([1, :ellipsis, 6, 7, 8, 9])
    end
  end
end
