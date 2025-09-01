# frozen_string_literal: true

module Contextizer
  module Providers
    module Base
      class Git < BaseProvider
        def self.call(context:, config:)
          context.metadata[:git] = fetch_git_info(context.target_path)
          @config = config
        end

        def self.fetch_git_info(path)
          Dir.chdir(path) do
            {
              branch: `git rev-parse --abbrev-ref HEAD`.strip,
              commit: `git rev-parse HEAD`.strip[0, 8]
            }
          end
        rescue StandardError
          { branch: "N/A", commit: "N/A" }
        end
      end
    end
  end
end
