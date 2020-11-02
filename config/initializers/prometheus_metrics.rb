# frozen_string_literal: true

unless Rails.env.test?
  require 'prometheus_exporter/instrumentation'
  require 'prometheus_exporter/middleware'

  PrometheusExporter::Client.default = PrometheusExporter::Client.new(
    host: 'laa-court-data-ui-metrics-service'
  )

  PrometheusExporter::Instrumentation::Process.start(type: 'master')
  Rails.application.middleware.unshift PrometheusExporter::Middleware
end
