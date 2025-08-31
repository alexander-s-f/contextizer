# frozen_string_literal: true

require "fileutils"

module Contextizer
  class Writer
    def self.call(content:, destination:)
      path = Pathname.new(destination)
      puts "Writer: Saving report to #{path}..."

      FileUtils.mkdir_p(path.dirname)
      File.write(path, content)

      puts "Writer: Report saved successfully."
    end
  end
end
