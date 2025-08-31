# frozen_string_literal: true

module Contextizer
  module Renderers
    class Base
      # @param context [Contextizer::Context] The context object to be rendered.
      def self.call(context:)
        raise NotImplementedError, "#{self.name} must implement the .call method"
      end
    end
  end
end
