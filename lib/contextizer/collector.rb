# frozen_string_literal: true

module Contextizer
  class Collector
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
      puts "[Contextizer] Collector: Starting data collection..."

      stack = Analyzer.call(target_path: @target_path)
      @context.metadata[:stack] = stack

      run_providers_from(:base)
      run_providers_from(stack[:language]) if stack[:language] != :unknown

      @context
    end

    private

    def run_providers_from(strategy_name)
      strategy_module_name = strategy_name.to_s.capitalize

      begin
        strategy_module = Providers.const_get(strategy_module_name)
        strategy_module.constants.each do |const_name|
          provider_class = strategy_module.const_get(const_name)
          if provider_class.is_a?(Class) && provider_class < Contextizer::Providers::BaseProvider
            provider_class.call(context: @context, config: @config)
          end
        end
      rescue NameError => e
        puts "[Contextizer] Warning: No providers found for strategy '#{strategy_name}'. #{e.message}"
      end
    end
  end
end
