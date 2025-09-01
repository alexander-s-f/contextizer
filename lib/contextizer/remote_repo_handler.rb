# frozen_string_literal: true

require "tmpdir"
require "fileutils"

module Contextizer
  class RemoteRepoHandler
    def self.handle(url)
      Dir.mktmpdir("contextizer-clone-") do |temp_path|
        puts "Cloning #{url} into temporary directory..."

        success = system("git clone --depth 1 #{url} #{temp_path}")

        if success
          puts "Cloning successful."
          yield(temp_path)
        else
          puts "Error: Failed to clone repository."
        end
      end
    end
  end
end
