# frozen_string_literal: true

module Contextizer
  # A value object that holds all the collected information about a project.
  # This object is the result of the Collector phase and the input for the Renderer phase.
  Context = Struct.new(
    :project_name,
    :target_path,
    :timestamp,
    :command,
    :metadata,     # Hash for data from providers like Git, Gems, etc.
    :files,        # Array of file objects { path:, content: }
    keyword_init: true
  ) do
    def initialize(*)
      super
      self.metadata ||= {}
      self.files ||= []
      self.timestamp ||= Time.now.utc.strftime("%Y-%m-%dT%H:%M:%SZ")
    end
  end
end
