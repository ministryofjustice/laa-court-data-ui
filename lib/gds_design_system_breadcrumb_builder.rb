# frozen_string_literal: true

# Custom BreadcrumbsOnRails::Breadcrumbs::Builder class
#
# see https://github.com/weppos/breadcrumbs_on_rails/blob/master/lib/breadcrumbs_on_rails/breadcrumbs.rb#L13-L20
#
class GdsDesignSystemBreadcrumbBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  def render
    @context.tag.div(class: 'govuk-breadcrumbs', role: "navigation", "aria-label": "Navigate Case") do
      @context.tag.ol(class: 'govuk-breadcrumbs__list') do
        @elements.collect.with_index do |element, idx|
          render_element(element, last: idx.eql?(@elements.size - 1))
        end.join.html_safe
      end
    end
  end

  def render_element(element, last: false)
    content = if element.path.nil?
                compute_name(element)
              else
                name = compute_name(element)
                path = compute_path(element)
                options = element.options.merge(class: 'govuk-breadcrumbs__link')
                is_current = @context.current_page?(path) || last
                @context.link_to_unless(is_current, name, path, options)
              end

    tag_options = {}
    tag_options[:class] = 'govuk-breadcrumbs__list-item'
    tag_options['aria-current'] = 'page' if is_current
    @context.tag.li(content, **tag_options)
  end
end
