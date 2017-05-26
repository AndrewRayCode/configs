require 'colorize'

Pry::Commands.block_command "s", "Application stack trace" do
  separator = File::SEPARATOR
  dir = /#{Regexp.escape( Dir.pwd )}#{Regexp.escape(separator)}?/
  caller.grep( dir ).each do |line|
    # /path/to/file/file.rb:10000:in `some_function_name'
    file_path, line_number, location = line.split(':')
    pn = Pathname.new(file_path)
    path = pn.dirname.to_s.sub( dir, '' )
    file = pn.basename.to_s

    printf "    %-110s %s\n", "#{path.light_red}#{separator}#{file.light_magenta}#{':'.green}#{line_number.cyan}", location
  end
end
