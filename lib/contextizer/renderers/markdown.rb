# frozen_string_literal: true

module Contextizer
  module Renderers
    class Markdown < Base
      def self.call(context:)
        new(context: context).render
      end

      def initialize(context:)
        @context = context
      end

      def render
        [
          render_header,
          render_file_tree,
          render_files
        ].join("\n---\n")
      end

      private

      def render_header
        project_info = @context.metadata[:project] || {}
        git_info = @context.metadata[:git] || {}
        gem_info = (@context.metadata[:gems] || {}).map { |n, v| "- **#{n}:** #{v}" }.join("\n")

        <<~HEADER
          # Contextizer Report

          ## Meta Context
          - **Project:** #{@context.project_name}
          - **Type:** #{project_info[:type]}
          - **Version:** #{project_info[:version]}
          - **Extracted At:** #{@context.timestamp}

          ### Git Info
          - **Branch:** `#{git_info[:branch]}`
          - **Commit:** `#{git_info[:commit]}`

          ### Key Dependencies
          #{gem_info.empty? ? "Not found." : gem_info}
        HEADER
      end

      def render_file_tree
        paths = @context.files.map { |f| f[:path] }
        tree_hash = build_path_hash(paths)
        tree_string = format_tree_node(tree_hash).join("\n")

        <<~TREE
          ### File Structure
          <details>
          <summary>Click to view file tree</summary>

          ```text
          #{@context.project_name}/
          #{tree_string}
          ```

          </details>
        TREE
      end

      def build_path_hash(paths)
        paths.each_with_object({}) do |path, hash|
          path.split("/").reduce(hash) do |level, part|
            level[part] ||= {}
          end
        end
      end

      def format_tree_node(node, prefix = "")
        output = []
        children = node.keys.sort
        children.each_with_index do |key, index|
          is_last = (index == children.length - 1)
          connector = is_last ? "└── " : "├── "
          output << "#{prefix}#{connector}#{key}"

          if node[key].any?
            new_prefix = prefix + (is_last ? "    " : "│   ")
            output.concat(format_tree_node(node[key], new_prefix))
          end
        end
        output
      end

      def render_files
        @context.files.map do |file|
          lang = File.extname(file[:path]).delete(".")
          lang = "ruby" if lang == "rb"
          lang = "ruby" if lang == "gemspec"
          lang = "javascript" if lang == "js"

          <<~FILE_BLOCK
            #### File: `#{file[:path]}`
            ```#{lang}
            #{file[:content]}
            ```
          FILE_BLOCK
        end.join("\n---\n")
      end
    end
  end
end
