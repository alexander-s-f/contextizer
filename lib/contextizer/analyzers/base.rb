# frozen_string_literal: true

module Contextizer
  module Analyzers
    class Base
      def self.call(target_path:)
        new(target_path: target_path).analyze
      end

      def initialize(target_path:)
        @target_path = Pathname.new(target_path)
        @score = 0
      end

      def analyze
        raise NotImplementedError, "#{self.class.name} must implement #analyze"
      end

      protected

      def check_signal(signal)
        path = @target_path.join(signal[:path])
        case signal[:type]
        when :file
          @target_path.glob(signal[:path]).any?
        when :dir
          path.directory?
        else
          false
        end
      end
    end
  end
end
