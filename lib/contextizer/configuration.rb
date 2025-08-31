# frozen_string_literal: true

require "yaml"
require "pathname"

module Contextizer
  class Configuration
    # CLI options > Project Config > Default Config
    def self.load(cli_options = {})
      default_config_path = Pathname.new(__dir__).join("../../config/default.yml")
      default_config = YAML.load_file(default_config_path)

      project_config_path = find_project_config
      project_config = project_config_path ? YAML.load_file(project_config_path) : {}

      merged_config = deep_merge(default_config, project_config)
      merged_config = deep_merge(merged_config, cli_options)

      new(merged_config)
    end

    def initialize(options)
      @options = options
    end

    def method_missing(name, *args, &block)
      key = name.to_s
      if @options.key?(key)
        @options[key]
      else
        super
      end
    end

    def respond_to_missing?(name, include_private = false)
      @options.key?(name.to_s) || super
    end

    def self.find_project_config(path = Dir.pwd)
      path = Pathname.new(path)
      loop do
        config_file = path.join(".contextizer.yml")
        return config_file if config_file.exist?
        break if path.root?

        path = path.parent
      end
      nil
    end

    def self.deep_merge(hash1, hash2)
      hash1.merge(hash2) do |key, old_val, new_val|
        if old_val.is_a?(Hash) && new_val.is_a?(Hash)
          deep_merge(old_val, new_val)
        else
          new_val
        end
      end
    end
  end
end
