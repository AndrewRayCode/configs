require 'rubygems'
require 'irb/completion'
#require 'bond'; require 'bond/completion'

IRB.conf[:AUTO_INDENT] = true
IRB.conf[:PROMPT_MODE] = :SIMPLE
IRB.conf[:AUTO_INDENT_MODE] = false

def ri(*names)
    system(%{ri #{names.map {|name| name.to_s}.join(' ')}})
end
