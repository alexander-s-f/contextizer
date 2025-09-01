# frozen_string_literal: true

require "pathname"

module Contextizer
  module Providers
    module Base
      class FileSystem < BaseProvider
        def self.call(context:, config:)
          new(context: context, config: config).collect_files
        end

        def initialize(context:, config:)
          @context = context
          @config = config.settings["filesystem"]
          @target_path = Pathname.new(context.target_path)
        end

        def collect_files
          file_paths = find_matching_files

          file_paths.each do |path|
            content = read_file_content(path)
            next unless content

            @context.files << {
              path: path.relative_path_from(@target_path).to_s,
              content: content
            }
          end
        end

        private

        def find_matching_files
          patterns = @config["components"].values.flatten.map do |pattern|
            (@target_path / pattern).to_s
          end

          all_files = Dir.glob(patterns)

          exclude_patterns = @config["exclude"].map do |pattern|
            (@target_path / pattern).to_s
          end

          all_files.reject do |file|
            exclude_patterns.any? { |pattern| File.fnmatch?(pattern, file) }
          end.map { |file| Pathname.new(file) }
        end

        def read_file_content(path)
          path.read
        rescue Errno::ENOENT, IOError => e
          warn "Warning: Could not read file #{path}: #{e.message}"
          nil
        end
      end
    end
  end
end
