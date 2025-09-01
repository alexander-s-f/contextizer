# frozen_string_literal: true

module Contextizer
  class Collector
    BASE_PROVIDERS = [
      Providers::Base::ProjectName,
      Providers::Base::Git,
      Providers::Base::FileSystem
    ].freeze

    LANGUAGE_MODULES = {
      ruby: Providers::Ruby,
      javascript: Providers::JavaScript
    }.freeze

    def self.call(config:, target_path:, command:)
      new(config: config, target_path: target_path, command: command).call
    end

    def initialize(config:, target_path:, command:)
      @config = config
      @target_path = target_path
      @command = command
      @context = Context.new(
        target_path: target_path,
        command: @command
      )
    end

    def call
      stack = Analyzer.call(target_path: @target_path)
      @context.metadata[:stack] = stack

      BASE_PROVIDERS.each do |provider_class|
        provider_class.call(context: @context, config: @config)
      end

      language_module = LANGUAGE_MODULES[stack[:language]]
      run_language_providers(language_module) if language_module

      puts "Collector: Collection complete. Found #{@context.files.count} files."
      @context
    end

    private

    def run_language_providers(language_module)
      puts "Collector: Running '#{language_module.name.split('::').last}' providers..."
      language_module.constants.each do |const_name|
        provider_class = language_module.const_get(const_name)
        if provider_class.is_a?(Class) && provider_class < Providers::BaseProvider
          provider_class.call(context: @context, config: @config)
        end
      end
    end
  end
end
