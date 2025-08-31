# frozen_string_literal: true

module Contextizer
  module Providers
    class Base
      # @param context [Contextizer::Context] The context object to be populated.
      # @param config [Contextizer::Configuration] The overall configuration.
      def self.call(context:, config:)
        raise NotImplementedError, "#{self.name} must implement the .call method"
      end
    end
  end
end
