# frozen_string_literal: true

require "thor"
require "yaml"

module Contextizer
  class CLI < Thor
    desc "extract [TARGET_PATH]", "Extracts project context into a single file."
    option :git_url,
           type: :string,
           desc: "URL of a remote git repository to analyze instead of a local path."
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
      if options[:git_url]
        RemoteRepoHandler.handle(options[:git_url]) do |remote_path|
          run_extraction(remote_path)
        end
      else
        run_extraction(target_path)
      end
    end

    private

    def run_extraction(path)
      cli_options = options.transform_keys(&:to_s).compact
      config = Configuration.load(cli_options)

      command_string = "contextizer #{ARGV.join(" ")}"
      context = Collector.call(
        config: config,
        target_path: path,
        command: command_string
      )

      renderer = RENDERER_MAPPING[config.format]
      raise Error, "Unsupported format: '#{config.format}'" unless renderer

      rendered_output = renderer.call(context: context)

      destination_path = resolve_output_path(config.output, context)
      Writer.call(content: rendered_output, destination: destination_path)

      puts "\nContextizer: Extraction complete! ✨"
    end

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