# frozen_string_literal: true

module Contextizer
  module Analyzers
    class JavascriptAnalyzer < Base
      LANGUAGE = :javascript

      SIGNALS = [
        { type: :file, path: "package.json", weight: 3 },
        { type: :dir,  path: "node_modules", weight: 7 }
      ].freeze

      FRAMEWORK_SIGNALS = {
        # rails: [{ type: :file, path: "bin/rails", weight: 15 }]
      }.freeze

      def analyze
        SIGNALS.each { |signal| @score += signal[:weight] if check_signal(signal) }

        return nil if @score.zero?

        {
          language: LANGUAGE,
          framework: detect_framework,
          score: @score
        }
      end

      private

      def detect_framework
        (FRAMEWORK_SIGNALS || {}).each do |fw, signals|
          return fw if signals.any? { |signal| check_signal(signal) }
        end
        nil
      end
    end
  end
end
