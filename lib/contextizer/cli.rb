# frozen_string_literal: true

require "thor"
require "yaml"

module Contextizer
  class CLI < Thor
    desc "extract [TARGET_PATH]", "Extracts project context into a single file."
    option :output,
           aliases: "-o",
           type: :string,
           desc: "Output file path (overrides config)."
    option :format,
           aliases: "-f",
           type: :string,
           desc: "Output format (e.g., markdown, json)."

    RENDERER_MAPPING = {
      "markdown" => Renderers::Markdown
    }.freeze

    def extract(target_path = ".")
      cli_options = options.transform_keys(&:to_s).compact
      config = Configuration.load(cli_options)

      context = Collector.call(config: config, target_path: target_path)

      renderer = RENDERER_MAPPING[config.format]
      unless renderer
        raise Error, "Unsupported format: '#{config.format}'. Supported formats: #{RENDERER_MAPPING.keys.join(', ')}"
      end

      rendered_output = renderer.call(context: context)

      destination_path = resolve_output_path(config.output, context)
      Writer.call(content: rendered_output, destination: destination_path)

      puts "\nContextizer: Extraction complete! ✨"
    end

    private

    def resolve_output_path(path_template, context)
      timestamp = Time.now.strftime("%Y-%m-%d_%H%M")
      project_name = context.metadata.dig(:project, :type) == "Gem" ? context.project_name : "project"


      path_template
        .gsub("{profile}", "default")
        .gsub("{timestamp}", timestamp)
        .gsub("{project_name}", project_name)
    end
  end
end