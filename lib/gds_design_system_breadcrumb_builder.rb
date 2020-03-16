# frozen_string_literal: true

# Custom BreadcrumbsOnRails::Breadcrumbs::Builder class
#
# see https://github.com/weppos/breadcrumbs_on_rails/blob/master/lib/breadcrumbs_on_rails/breadcrumbs.rb#L13-L20
#
class GdsDesignSystemBreadcrumbBuilder < BreadcrumbsOnRails::Breadcrumbs::Builder
  def render
    @context.content_tag(:div, class: 'govuk-breadcrumbs') do
      @context.content_tag(:ol, class: 'govuk-breadcrumbs__list') do
        @elements.collect do |element|
          render_element(element)
        end.join('').html_safe
      end
    end
  end

  def render_element(element)
    content = if element.path.nil?
                compute_name(element)
              else
                @context.link_to_unless_current(
                  compute_name(element),
                  compute_path(element),
                  element.options.merge(class: 'govuk-breadcrumbs__link')
                )
              end

    tag_options = {}
    tag_options[:class] = 'govuk-breadcrumbs__list-item'
    tag_options['aria-current'] = 'page' if @context.current_page?(compute_path(element))
    @context.content_tag(:li, content, tag_options)
  end
end
