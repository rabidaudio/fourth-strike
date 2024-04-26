# frozen_string_literal: true

# Creates a bulma pagniation widget from an ActiveRecord query result where will_paginate
# has been applied. Uses the _pagination partial.
module PaginationHelper
  def render_pagination(resource, page_buttons: 5, always_show: false)
    return if resource.total_pages == 1 && !always_show

    current = resource.current_page
    total = resource.total_pages
    page_buttons = [page_buttons, total].min

    render partial: 'pagination', locals: {
      prev_page: current == 1 ? nil : current_path_with_page(current - 1),
      next_page: current == resource.total_pages ? nil : current_path_with_page(current + 1),
      pages: compute_pages_to_show(current, total, page_buttons)
        .map { |p| p == :ellipsis ? p : { num: p, path: current_path_with_page(p), current: p == current } }
    }
  end

  private

  def compute_pages_to_show(current, total, page_buttons)
    page_nums = case
                when current <= page_buttons / 2 then (1..page_buttons)
                when current + (page_buttons / 2) >= total then ((total - page_buttons + 1)..total)
                else ((current - (page_buttons / 2))..(current + (page_buttons / 2)))
                end.to_a

    # always show first and last page buttons
    page_nums = [1] + page_nums[1..] if page_nums[0] != 1
    page_nums = page_nums[..-2] + [total] if page_nums[-1] != total

    pages = []
    page_nums.each_with_index do |num, i|
      pages.push(:ellipsis) if i != 0 && page_nums[i - 1] != num - 1
      pages.push(num)
    end
    pages
  end

  def current_path_with_page(page)
    URI(request.fullpath).tap do |uri|
      existing_query_params = Rack::Utils.parse_nested_query(uri.query)
      existing_query_params['page'] = page.to_s
      # ensure query parameter order is well defined (for testing mostly)
      existing_query_params = existing_query_params.sort.to_h
      uri.query = Rack::Utils.build_nested_query(existing_query_params)
    end.to_s
  end
end
