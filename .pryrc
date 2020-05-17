# =============================================================================
# Setup
# =============================================================================

puts "#{'✨ Initializing'.green} #{'pry ✨'.cyan}"

# Disabe paging in pry, to avoid having to keep hitting j/space on big output
# on small screens
# On second thought I want this on because printing a huge object is not
# cancellable
# Pry.config.pager = false

# -----------------------------------------------------------------------------
# Rails app spits out lots of startup garbage, separate this
def notice_me(msg)
  puts "☠ #{'❌' * 30} ☠"
  puts "❌ #{msg}"
  puts
end

# -----------------------------------------------------------------------------
# Required for all the other functions: The 'colorize' gem, which lets you
# colorize text output to the console. Since it's not in the Jarvis Gemfile,
# we have to go find it manually. To find yours, do something like `bundle show # httparty`,
# get the base gems/ path, and find colorize in there
begin
    colorize_init_file = "#{Dir.home}/.gem/ruby/2.5.1/gems/colorize-0.8.1/lib/colorize.rb"
    require colorize_init_file
    puts "✅ #{'require'.light_red} #{"'colorize'".cyan}"
rescue Exception => ex # Did you know LoadError inherits from Exception, not StandardError?
    notice_me "Warning: colorize gem not found, make sure you:\n - Installed colorize locally (gem install colorize)\n - This path exists: #{colorize_init_file}\n#{ex.message}"
end

# -----------------------------------------------------------------------------
# Load the route helpers in the terminal so you can generate page URLs
# admin_stark_user_path / admin_stark_user_url
begin
    include Rails.application.routes.url_helpers
    puts "✅ #{'include'.light_yellow} #{'Rails.application.routes.url_helpers'.cyan}"
rescue LoadError
    puts "Warning: couldn't load route helpers"
end

# -----------------------------------------------------------------------------
# Enables FactoryBot in a pry session
begin
    require 'factory_bot_rails'
    puts "✅ #{'require'.light_red} #{"'factory_bot_rails'".cyan}"
rescue Exception => ex
    notice_me "Warning: factory_bot_rails gem not found, #{ex}"
end

# -----------------------------------------------------------------------------
# Required to create a covered_member patient, apparently?
begin
    require './spec/support/anna_spec_helper'
    puts "✅ #{'require'.light_red} #{"'./spec/support/anna_spec_helper'".cyan}"
rescue StandardError
    notice_me "Warning: ./spec/support/anna_spec_helper not found"
end

# =============================================================================
# Helper functions (not meant to be run directly)
# =============================================================================

def globRequire(path)
  successes = []
  failures = []
  Dir.glob(path).each do |file|
    begin
        require file
        successes << file
    rescue Exception => e
        failures << "Warning: Could not require #{file}? #{e.message}"
    end
  end
  if successes.count > 0
      puts "✅ #{'require {'.light_red}#{successes.join(', ').cyan}#{'}'.light_red}"
  end
  notice_me failures if failures.present?
end

# -----------------------------------------------------------------------------
# Enables a lot more factories which need our custom Faker plugins. I'm too
# lazy to make the method a separate file and require it so that I can call
# this method above the definitino
globRequire('./spec/support/faker_*.rb')

# -----------------------------------------------------------------------------
# Print a full stack trace with colorized output for easier
def colorized_stack_trace( stack, base_dir )
  separator = File::SEPARATOR
  longest = stack.max_by(&:length).length
  number_of_colors = 5
  color_length = 5
  column_width = longest + number_of_colors * color_length

  stack.each do |line|
    # Example stack trace line for reference:
    # /path/to/file/file.rb:10000:in `some_function_name'
    file_path, line_number, location = line.split(':')
    pn = Pathname.new(file_path)
    path = pn.dirname.to_s.sub( base_dir, '' )
    file = pn.basename.to_s

    printf "    %-#{column_width}s %s\n",
      "#{path.light_red}#{separator.light_red}#{file.light_magenta}#{':'.green}#{line_number.cyan}",
      location
  end
end

def filtered_stack_trace( stack, filter )
  filtered = stack.grep( filter )
  if filtered.empty?
    puts "#{'The current stack trace does not contain any lines matching'.red} #{filter.to_s.light_red}#{'.'.red}"
    puts 'Type `sa` to see a full colorized stack trace, or `caller` to see the vanilla ruby full stack trace.'.red
    return
  end
  colorized_stack_trace( filtered, filter )
end

# =============================================================================
# Pry commands (meant to be run directly)
# =============================================================================

# -----------------------------------------------------------------------------
# Print out the stack *only* including the current application's directory,
# for example stack trace lines *only* matching /jarvis/ to remove noisy Gem
# stack traces
Pry::Commands.block_command "s", "Application stack trace" do
  separator = File::SEPARATOR
  pwd = Dir.pwd
  dir = /#{Regexp.escape( pwd )}#{Regexp.escape(separator)}?/
  filtered_stack_trace( caller, dir )
end

Pry::Commands.block_command "sa", "Application stack trace" do
  filtered_stack_trace( caller, /./ )
end

# =============================================================================
# Utiltiy functions (meant to be run directly)
# =============================================================================

# -----------------------------------------------------------------------------
# Copy some text to the clipboard
def cpy(input)
  _max_display_string_length = 50
  str = input.to_s
  IO.popen('pbcopy', 'w') { |f| f << str }
  truncated = str.length > _max_display_string_length ? str[0.._max_display_string_length] + '…' : str
  puts "✅ Copied \"#{truncated}\" to system clipboard!".green;
end

# -----------------------------------------------------------------------------
# Write some text to an HTML file and open it for quick inspection. Opens with
# browser by default
def r_o(input)
  f = Tempfile.new(['foo', '.html'])
  f.write(input)
  f.close
  `open #{f.path}`
end

# -----------------------------------------------------------------------------
# When debugging an rspec test, this will attempt to load the current page
# body and display it to you in your web browser
def showme
  r_o( defined?(page) ? page.body : dom.to_s )
end

# =============================================================================
# ✨
# =============================================================================
puts "\n#{'✨ Pry'.yellow} #{'console'.cyan} #{'initialized'.light_red} #{'succesfully! ✨'.green}"
