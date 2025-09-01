# frozen_string_literal: true

module Contextizer
  module Analyzers
    class JavaScriptAnalyzer < Base
      LANGUAGE = :javascript

      SIGNALS = [
        { type: :file, path: "package.json", weight: 5 },
        { type: :dir,  path: "node_modules", weight: 10 },
        { type: :file, path: "webpack.config.js", weight: 5 },
        { type: :file, path: "vite.config.js", weight: 5 }
      ].freeze

      FRAMEWORK_SIGNALS = {}.freeze

      def analyze
        SIGNALS.each { |signal| @score += signal[:weight] if check_signal(signal) }

        return nil if @score.zero?

        {
          language: LANGUAGE,
          framework: nil,
          score: @score
        }
      end
    end
  end
end
