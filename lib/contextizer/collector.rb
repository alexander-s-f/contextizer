# frozen_string_literal: true

module Contextizer
  class Collector
    PROVIDER_MAPPING = {
      "project_info" => Providers::ProjectInfo,
      "git" => Providers::Git,
      "gems" => Providers::Gems,
      "filesystem" => Providers::FileSystem
    }.freeze

    def self.call(config:, target_path:)
      new(config: config, target_path: target_path).call
    end

    def initialize(config:, target_path:)
      @config = config
      @target_path = target_path
      @context = Context.new(
        project_name: File.basename(Dir.getwd),
        target_path: target_path
      )
    end

    def call
      enabled_providers.each do |provider_class|
        provider_class.call(context: @context, config: @config)
      end

      puts "Collector: Collection complete. Found #{@context.files.count} files."

      @context
    end

    private

    def enabled_providers
      @config.providers.map do |key, enabled|
        PROVIDER_MAPPING[key] if enabled == true
      end.compact
    end
  end
end
