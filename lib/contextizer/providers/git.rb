# frozen_string_literal: true

module Contextizer
  module Providers
    class Git < Base
      def self.call(context:, config:)
        context.metadata[:git] = fetch_git_info
      end

      private

      def self.fetch_git_info
        {
          branch: `git rev-parse --abbrev-ref HEAD`.strip,
          commit: `git rev-parse HEAD`.strip[0, 8]
        }
      rescue StandardError
        { branch: "N/A", commit: "N/A" }
      end
    end
  end
end
