# frozen_string_literal: true

require "zeitwerk"
loader = Zeitwerk::Loader.for_gem
loader.setup

require_relative "contextizer/version"

module Contextizer
  class Error < StandardError; end
  # ...
end

loader.eager_load
