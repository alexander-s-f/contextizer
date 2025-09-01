# frozen_string_literal: true
require "json"

module Contextizer
  module Providers
    module JavaScript
      class Packages < BaseProvider
        def self.call(context:, config:)
          package_json_path = File.join(context.target_path, "package.json")
          return unless File.exist?(package_json_path)

          context.metadata[:packages] = parse_packages(package_json_path)
        end

        private

        def self.parse_packages(path)
          begin
            file = File.read(path)
            data = JSON.parse(file)
            {
              dependencies: data["dependencies"] || {},
              dev_dependencies: data["devDependencies"] || {}
            }
          rescue JSON::ParserError => e
            puts "Warning: Could not parse package.json: #{e.message}"
            {}
          end
        end
      end
    end
  end
end
