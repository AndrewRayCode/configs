#require 'awesome_print' # Removing because bad colors and can't configure
#AwesomePrint.pry!

begin
    require 'colorize'
    puts "#{'require'.light_red} #{"'colorize'".cyan}"
rescue LoadError
    puts "Warning: colorize gem not found"
end

begin
    require 'factory_girl_console'
    puts "#{'require'.light_red} #{"'factory_girl_console'".cyan}"
rescue LoadError
    puts "Warning: factory_girl_console gem not found"
end

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
    puts "#{'The current stack trace doesn\'t contain any lines matching'.red} #{filter.to_s.light_red}#{'.'.red}"
    puts 'Type `sa` to see a full colorized stack trace, or `caller` to see the vanilla ruby full stack trace.'.red
    return
  end
  colorized_stack_trace( filtered, filter )
end

Pry::Commands.block_command "s", "Application stack trace" do
  separator = File::SEPARATOR
  pwd = Dir.pwd
  dir = /#{Regexp.escape( pwd )}#{Regexp.escape(separator)}?/
  filtered_stack_trace( caller, dir )
end

Pry::Commands.block_command "sa", "Application stack trace" do
  filtered_stack_trace( caller, /./ )
end

_max_display_string_length = 50
def pbcopy(input)
  str = input.to_s
  IO.popen('pbcopy', 'w') { |f| f << str }
  truncated = str.length > _max_display_string_length ? str[0.._max_display_string_length] + '...' : str
  puts "Copied \"#{truncated}\" to system clipboard!"
end

def h_o(input)
  f = Tempfile.new(['foo', '.html'])
  f.write(input)
  f.close
  `open #{f.path}`
end

def showme
  h_o( defined?(page) ? page.body : dom.to_s )
end

# Disabe paging in pry
Pry.config.pager = false

