# frozen_string_literal: true

# Render arbitrary markdown text to html. Limits allowed styles to avoid injection vulnerabilities.
module MarkdownHelper
  def markdown_renderer
    @markdown_renderer ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(
                                                     filter_html: true,
                                                     no_styles: true,
                                                     safe_links_only: true
                                                   ))
  end

  def render_markdown(text)
    markdown_renderer.render(text)
  end
end
