property :path, String
property :pattern, [String, Regexp]
property :delim, Array
property :entry, String
property :ignore_missing, [true, false], default: false
property :eol, String, default: Line::OS.unix? ? "\n" : "\r\n"
property :discrete, [true, false], default: true
property :backup, [true, false], default: false

resource_name :delete_from_list

action :edit do
  return if !::File.exist?(new_resource.path) && new_resource.ignore_missing
  raise "File #{new_resource.path} not found" unless ::File.exist?(new_resource.path)
  regex = new_resource.pattern.is_a?(String) ? /#{new_resource.pattern}/ : new_resource.pattern

  eol = new_resource.eol
  new = []
  current = ::File.binread(new_resource.path).split(eol)

  current.each do |line|
    line = line.dup
    new << line
    next unless line =~ regex

    case new_resource.delim.count
    when 1
      case line
      when /#{regexdelim[0]}\s*#{new_resource.entry}/
        # remove the entry
        line = line.sub(/(#{regexdelim[0]})*\s*#{new_resource.entry}(#{regexdelim[0]})*/, new_resource.delim[0])
        # delete any trailing delimeters
        line = line.sub(/\s*(#{regexdelim[0]})*\s*$/, '')
      when /#{new_resource.entry}\s*#{regexdelim[0]}/
        line = line.sub(/#{new_resource.entry}(#{regexdelim[0]})*/, '')
      end
    when 2
      case line
      when /#{regexdelim[1]}#{new_resource.entry}#{regexdelim[1]}/
        line = line.sub(/(#{regexdelim[0]})*\s*#{regexdelim[1]}#{new_resource.entry}#{regexdelim[1]}(#{regexdelim[0]})*/, '')
      end
    when 3
      case line
      when /#{regexdelim[1]}#{new_resource.entry}#{regexdelim[2]}/
        line = line.sub(/(#{regexdelim[0]})*\s*#{regexdelim[1]}#{new_resource.entry}#{regexdelim[2]}(#{regexdelim[0]})*/, '')
      end
    end

    new[-1] = line
    Chef::Log.info("New line: #{line}")
  end

  new[-1] += eol unless new[-1].to_s.empty?
  file new_resource.path do
    content new.join(eol)
    backup new_resource.backup
    sensitive new_resource.discrete
    not_if { new == current }
  end
end

action_class.class_eval do
  def regexdelim
    @regexdelim || escape_delims
  end

  def escape_delims
    # Search for escaped delimeters. Add the raw delimiters to the lines.
    @regexdelim = []
    new_resource.delim.each do |delim|
      @regexdelim << Regexp.escape(delim)
    end
    @regexdelim
  end
end
