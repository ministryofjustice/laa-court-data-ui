Tilt::GovukMarkdownTemplate = Tilt::StaticTemplate.subclass do
  GovukMarkdown.render(@data.force_encoding("UTF-8")).html_safe
end
