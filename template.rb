
require 'fileutils'
require 'shellwords'

def add_template_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require 'tmpdir'
    source_paths.unshift(tempdir = Dir.mktmpdir('glowing-octo-broccoli'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git clone: [
      '--quiet',
      'https://github.com/jusondac/glowing-octo-broccoli.git',
      tempdir
    ].map(&:shellescape).join(' ')
    if (branch = __FILE__[%r{glowing-octo-broccoli/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git checkout: branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def rails_version
  @rails_version ||= Gem::Version.new(Rails::VERSION::STRING)
end

def add_gems
  gem 'cancancan'
  gem 'awesome_print'
  gem 'devise'
end

def set_application_name
  environment 'config.application_name = Rails.application.class.module_parent_name'
  puts 'You can change application name inside: ./config/application.rb'
end

def setup_users
  # Install Devise
  generate 'devise:install'
  # Configure Devise
  environment "config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }", env: 'development'
  # Generate Devise views via Bootstrap
  generate 'devise:views'
   # Create Devise User
  generate :devise, 'User', 'first_name', 'last_name', 'role_id:integer'
  if Gem::Requirement.new("> 5.2").satisfied_by? rails_version
    gsub_file 'config/initializers/devise.rb',
      /  # config.secret_key = .+/,
      '  config.secret_key = Rails.application.credentials.secret_key_base'
  end
  rails_command 'db:migrate'
end

def setup_table
  generate :model, 'Role', 'name:string'
  rails_command 'db:migrate'
end

def add_home_page
  generate(:controller, "home index")
  route "root to:'home#index'"
end

def copy_template
  remove_file 'app/assets/stylesheets/application.css'
  directory 'app', force: true
end

# Main setup
add_template_to_source_path
add_gems

after_bundle do
  rails_command 'db:create'
  rails_command 'db:migrate'
  set_application_name
  
  setup_users
  setup_table
  copy_template
  add_home_page

  puts ""
  puts "Your app finnaly done create!! \u{1f355} 🎉 \n"
  puts "cd #{app_name} - Switch to your new app's directory."
  puts "then type 'rails s'"
end
