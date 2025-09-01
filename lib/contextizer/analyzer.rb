# frozen_string_literal: true

module Contextizer
  class Analyzer
    SPECIALISTS = Analyzers.constants.map do |const|
      Analyzers.const_get(const)
    end.select { |const| const.is_a?(Class) && const < Analyzers::Base }

    def self.call(target_path:)
      new(target_path: target_path).analyze
    end

    def initialize(target_path:)
      @target_path = target_path
    end

    def analyze
      results = SPECIALISTS.map do |specialist_class|
        specialist_class.call(target_path: @target_path)
      end.compact

      return { language: :unknown, framework: nil, scores: {} } if results.empty?

      best_result = results.max_by { |result| result[:score] }

      {
        language: best_result[:language],
        framework: best_result[:framework],
        scores: results.map { |r| [r[:language], r[:score]] }.to_h
      }
    end
  end
end
