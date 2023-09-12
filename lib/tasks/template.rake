require "active_support"

namespace :template do
  desc "Reset the template as a new Rails app"
  task :reset do
    # Remove the .git directory
    puts "Removing .git directory to give you a fresh git repository..."
    system("rm -rf .git")
    puts "Initializing a new git repository..."
    system("git init")
    # Reset README
    # Rename App Module
    puts "Please enter the name of your application: Example Application, example_application, ExampleApplication"
    app_name = STDIN.gets.chomp
    app_module = ActiveSupport::Inflector.camelize(app_name)

    puts "Renaming application module to #{app_module}..."
    file_path = "config/application.rb"
    text = File.read(file_path)
    new_text = text.gsub("module Starter", "module #{app_module}")
    File.open(file_path, "w") { |file| file.puts new_text }
    puts "Application module renamed successfully."

    # Set the databases key in the yaml in config/database.yml for each environment
    puts "Setting the databases key in the yaml in config/database.yml for each environment..."
    db_config_path = "config/database.yml"
    db_config = YAML.load_file(db_config_path, aliases: true)
    db_name = ActiveSupport::Inflector.underscore(app_module.tr(" ", "_"))
    db_config["development"]["database"] = "#{db_name}_development"
    db_config["test"]["database"] = "#{db_name}_test"
    db_config["production"]["database"] = "#{db_name}_production"
    File.open(db_config_path, "w") { |file| file.puts db_config.to_yaml }
    puts "Databases key in the yaml in config/database.yml set successfully."

    # Ask if they want to generate a new README.md
    puts "Do you want to generate a new README.md? (yes/no)"
    README = <<~MD
      # #{app_name}

      ## Development

      run `./bin/dev` to start the development environment

    MD

    answer = STDIN.gets.chomp.downcase
    if answer == "yes"
      # Generate a new README.md based on the README heredoc above
      File.open("README.md", "w") do |file|
        file.puts README
      end
      puts "README.md generated successfully."
    else
      puts "Skipped generating README.md."
    end
  end

  desc "Drop database support in the existing project"
  task :remove_database_support => :environment do
    # Step 1: Remove ActiveRecord gem from Gemfile
    gsub_file 'Gemfile', /^gem ['"]pg['"].*$/, '# \0'
    gsub_file 'Gemfile', /^gem ['"]sqlite3['"].*$/, '# \0'

    # Step 2: Comment out ActiveRecord related configurations in environment files
    Dir.glob('config/environments/*.rb').each do |file|
      gsub_file file, /^  config.active_record.*$/, '# \0'
    end

    # Step 3: Remove ActiveRecord from application configuration
    gsub_file 'config/application.rb', /^require ['"]rails\/all['"]$/, <<-RUBY
require "action_controller/railtie"
require "action_view/railtie"
require "action_mailer/railtie"
require "active_job/railtie"
require "action_cable/engine"
require "rails/test_unit/railtie"
require "sprockets/railtie" if defined?(Sprockets)
    RUBY

    # Step 4: Comment out ActiveRecord related lines in cable, storage and database configurations
    %w[cable storage database].each do |config|
      File.readlines("config/#{config}.yml").each do |line|
        gsub_file "config/#{config}.yml", /^#{line.chomp}$/, '# \0'
      end
    end

    # Step 5: Comment out ActiveRecord related lines in application record and job
    gsub_file 'app/models/application_record.rb', /^class ApplicationRecord.*$/, '# \0'
    gsub_file 'app/jobs/application_job.rb', /^  retry_on ActiveRecord::Deadlocked$/, '# \0'

    # Step 6: Comment out ActiveRecord related lines in setup script
    gsub_file 'bin/setup', /^  system! "bin\/rails db:prepare"$/, '# \0'

    # Step 7: Remove db directory
    FileUtils.rm_rf('db')

    # Step 8: Comment out config.active_storage.service in environment files
    Dir.glob('config/environments/*.rb').each do |file|
      gsub_file file, /^  config.active_storage.service = :local$/, '# \0'
    end

    # Step 9: Comment out the Preparing database step in setup script
    gsub_file 'bin/setup', /^  puts "\n== Preparing database =="$\n  system! "bin\/rails db:prepare"$/, '# \0'
  end

end