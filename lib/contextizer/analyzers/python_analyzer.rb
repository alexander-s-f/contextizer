# frozen_string_literal: true

module Contextizer
  module Analyzers
    class PythonAnalyzer < Base
      LANGUAGE = :python

      SIGNALS = [
        { type: :file, path: "requirements.txt", weight: 10 },
        { type: :file, path: "pyproject.toml", weight: 10 },
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
