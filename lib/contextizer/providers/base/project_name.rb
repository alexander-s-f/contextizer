# frozen_string_literal: true

module Contextizer
  module Providers
    module Base
      class ProjectName < BaseProvider
        def self.call(context:, config:)
          context.project_name = detect_project_name(context.target_path)
        end

        private

        def self.detect_project_name(path)
          git_name = name_from_git_remote(path)
          return git_name if git_name

          File.basename(path)
        end

        def self.name_from_git_remote(path)
          return nil unless Dir.exist?(File.join(path, ".git"))

          Dir.chdir(path) do
            remote_url = `git remote get-url origin`.strip
            remote_url.split("/").last.sub(/\.git$/, "")
          end
        rescue StandardError
          nil
        end
      end
    end
  end
end
