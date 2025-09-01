# frozen_string_literal: true

module Contextizer
  module Providers
    module Ruby
      class Gems < BaseProvider
        def self.call(context:, config:)
          key_gems = config.settings.dig("gems", "key_gems")
          return if key_gems.nil? || key_gems.empty?

          gemfile_lock = File.join(context.target_path, "Gemfile.lock")
          return unless File.exist?(gemfile_lock)

          context.metadata[:gems] = parse_gemfile_lock(gemfile_lock, key_gems)
        end

        def self.parse_gemfile_lock(path, key_gems)
          found_gems = {}
          content = File.read(path)
          key_gems.each do |gem_name|
            match = content.match(/^\s{4}#{gem_name}\s\((.+?)\)/)
            found_gems[gem_name] = match[1] if match
          end
          found_gems
        end
      end
    end
  end
end
