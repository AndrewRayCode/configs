require 'irb/completion'

def ri(*names)
    system(%{ri #{names.map {|name| name.to_s}.join(' ')}})
end
