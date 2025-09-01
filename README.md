# Contextizer

**Contextizer** is a versatile command-line tool for extracting, analyzing, and packaging the context of any software project. It scans a codebase, gathers key metadata (language, framework, dependencies, git status), and aggregates the source code into a single, easy-to-digest Markdown report.

It's the perfect tool for:
-   Preparing context for analysis by Large Language Models (LLMs).
-   Quickly onboarding a new developer to a project.
-   Archiving a project snapshot for a code review.
-   Creating comprehensive bug reports.

---

## Key Features

* **Polyglot by Design:** Automatically detects a project's primary language and framework (Ruby/Rails, JavaScript, etc.) using a smart "signals and weights" system.
* **Plug-and-Play Architecture:** Easily extendable to support new languages and frameworks by adding new "Analyzers" and "Providers".
* **Rich Metadata Collection:** Extracts Git information (branch, commit), key dependencies (`Gemfile`, `package.json`), and the project's structure.
* **Remote Repository Analysis:** Can clone and analyze any public Git repository directly from a URL, no manual cloning required.
* **Flexible Configuration:** Controlled via a simple YAML file (`.contextizer.yml`) in your project's root, allowing you to fine-tune the data collection process.
* **Clean & Readable Reports:** Generates a single Markdown file with a visual file tree, project metadata, and syntax-highlighted source code.

---

## Installation

### Standalone (Recommended)

Install the gem globally to use it in any project on your system:

```bash
gem install contextizer
```

### As a Project Dependency (Bundler)

Add it to your project's `Gemfile` within the `:development` group:

```ruby
# Gemfile
group :development do
  gem 'contextizer'
end
```

Then, execute:

```bash
bundle install
```

---

## Usage

### Analyzing a Local Project

Navigate to your project's root directory and run:

```bash
contextizer extract
```

The report will be saved in the current directory by default.

### Analyzing a Remote Git Repository

Use the `--git-url` option to analyze any public repository:

```bash
contextizer extract --git-url https://github.com/rails/rails
```

### Common Options

- `[TARGET_PATH]`: (Optional) The path to the directory to analyze. Defaults to the current directory.
- `--git-url URL`: The URL of a remote Git repository to analyze.
- `-o, --output PATH`: The destination path for the final report file.
- `-f, --format FORMAT`: The output format (currently supports `markdown`).

---

## ⚙️ Configuration

To customize Contextizer for your project, create a `.contextizer.yml` file in its root directory.

The tool uses a three-tiered configuration system with the following priority:

CLI Options > .contextizer.yml > Gem Defaults

### Example `.contextizer.yml`

YAML

```
# .contextizer.yml

# Path to save the report.
# Available placeholders: {project_name}, {timestamp}
output: "docs/context/{project_name}_{timestamp}.md"

# Settings for specific providers
settings:
  # Settings for the Ruby gems provider
  gems:
    key_gems: # List your project's most important gems here
      - rails
      - devise
      - sidekiq
      - rspec-rails
      - pg
      - pundit

  # Settings for the filesystem provider
  filesystem:
    # Specify which files and directories to include in the report
    components:
      models: "app/models/**/*.rb"
      controllers: "app/controllers/**/*.rb"
      services: "app/services/**/*.rb"
      javascript: "app/javascript/**/*.js"
      config:
        - "config/routes.rb"
        - "config/application.rb"
      documentation:
        - "README.md"
        - "CONTRIBUTING.md"

    # Global exclusion patterns
    exclude:
      - "tmp/**/*"
      - "log/**/*"
      - "node_modules/**/*"
      - ".git/**/*"
      - "vendor/**/*"
```

---

## Extensibility (Adding a New Language)

Thanks to the plug-and-play architecture, adding support for a new language is straightforward:

1. **Create a Specialist Analyzer**: Add a new file in `lib/contextizer/analyzers/` that detects the language based on its characteristic files and directories.
2. **Create Providers**: Add a new directory in `lib/contextizer/providers/` with providers that extract language-specific information (e.g., dependencies from a `pom.xml` file for Java).

The main `Analyzer` and `Collector` will automatically discover and use your new components.

---

## Contributing

1. Fork the repository.
2. Create your feature branch (`git checkout -b my-new-feature`).
3. Commit your changes (`git commit -am 'Add some feature'`).
4. Push to the branch (`git push origin my-new-feature`).
5. Create a new Pull Request.


---

## License

This project is released under the MIT License.
