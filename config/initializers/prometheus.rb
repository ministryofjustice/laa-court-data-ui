# frozen_string_literal: true

if ENV.fetch('EXPORT_TO_PROMETHEUS', 'disabled') == 'enabled'
  require 'prometheus_exporter/instrumentation'
  require 'prometheus_exporter/middleware'

  PrometheusExporter::Instrumentation::Process.start(type: 'master')
  Rails.application.middleware.unshift PrometheusExporter::Middleware
end
