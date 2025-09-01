# frozen_string_literal: true

module Contextizer
  module Providers
    module Ruby
      class ProjectInfo < BaseProvider
        def self.call(context:, config:)
          project_info = detect_project_info(context.target_path)
          context.metadata[:project] = project_info
        end


        def self.detect_project_info(path)
          if Dir.glob(File.join(path, "*.gemspec")).any?
            return { type: "Gem", version: detect_gem_version(path) }
          end

          if File.exist?(File.join(path, "bin", "rails"))
            return { type: "Rails", version: detect_rails_version(path) }
          end

          { type: "Directory", version: "N/A" }
        end

        def self.detect_gem_version(path)
          version_file = Dir.glob(File.join(path, "lib", "**", "version.rb")).first
          return "N/A" unless version_file

          content = File.read(version_file)
          match = content.match(/VERSION\s*=\s*["'](.+?)["']/)
          match ? match[1] : "N/A"
        end

        def self.detect_rails_version(path)
          gemfile_lock = File.join(path, "Gemfile.lock")
          return "N/A" unless File.exist?(gemfile_lock)

          content = File.read(gemfile_lock)
          match = content.match(/^\s{4}rails\s\((.+?)\)/)
          match ? match[1] : "N/A"
        end
      end
    end
  end
end
