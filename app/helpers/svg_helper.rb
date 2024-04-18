# frozen_string_literal: true

# Render a vector image inline in html
module SvgHelper
  def render_svg(path, scale: 1)
    data = Rails.root.join('app/assets/images/', path).read
    if scale != 1
      doc = Nokogiri.parse(data)
      doc.css('svg').first['style'] = "scale: #{scale};"
      data = doc.to_s
    end
    render(inline: data) # rubocop:disable Rails/RenderInline
  end
end
