property :path, String
property :pattern, String
property :delim, Array
property :entry, String
property :ends_with, String
property :eol, String, default: Line::OS.unix? ? "\n" : "\r\n"
property :discrete, [true, false], default: true
property :backup, [true, false], default: false

resource_name :add_to_list

action :edit do
  raise "File #{new_resource.path} not found" unless ::File.exist?(new_resource.path)

  eol = new_resource.eol
  current = ::File.binread(new_resource.path).split(eol)
  new = insert_list_entry(current)
  new[-1] += eol unless new[-1].to_s.empty?

  file new_resource.path do
    content new.join(eol)
    backup new_resource.backup
    sensitive new_resource.discrete
    not_if { new == current }
  end
end

action_class do
  def insert_list_entry(current)
    new = []
    ends_with = new_resource.ends_with ? Regexp.escape(new_resource.ends_with) : ''
    regex = /#{new_resource.pattern}.*#{ends_with}/
    current.each do |line|
      new << line
      line = line.dup
      next unless line =~ regex
      if new_resource.ends_with
        list_end = line.rindex(new_resource.ends_with)
        seperator = line =~ /#{new_resource.pattern}.*\S.*#{ends_with}/ ? new_resource.delim[0] : ''
        case new_resource.delim.count
        when 1
          next if line =~ /(#{regexdelim[0]}|#{new_resource.pattern})\s*#{new_resource.entry}\s*(#regexdelim[0]|#{ends_with})/
          line = line.insert(list_end, "#{seperator}#{new_resource.entry}")
        when 2
          next if line =~ /#{regexdelim[1]}#{new_resource.entry}\s*#{regexdelim[1]}/
          line = line.insert(list_end, "#{seperator}#{new_resource.delim[1]}#{new_resource.entry}#{new_resource.delim[1]}")
        when 3
          next if line =~ /#{regexdelim[1]}#{new_resource.entry}\s*#{regexdelim[2]}/
          line = line.insert(list_end, "#{seperator}#{new_resource.delim[1]}#{new_resource.entry}#{new_resource.delim[2]}")
        end
      else
        seperator = line =~ /#{new_resource.pattern}.*\S.*$/ ? new_resource.delim[0] : ''
        case new_resource.delim.count
        when 1
          next if line =~ /((#{regexdelim[0]})*|#{new_resource.pattern})\s*#{new_resource.entry}(#{regexdelim[0]}|\n)/
          line += "#{seperator}#{new_resource.entry}"
        when 2
          next if line =~ /#{regexdelim[1]}#{new_resource.entry}#{regexdelim[1]}/
          line += "#{seperator}#{new_resource.delim[1]}#{new_resource.entry}#{new_resource.delim[1]}"
        when 3
          next if line =~ /#{regexdelim[1]}#{new_resource.entry}#{regexdelim[2]}/
          line += "#{seperator}#{new_resource.delim[1]}#{new_resource.entry}#{new_resource.delim[2]}"
        end
      end
      Chef::Log.error("New line: #{line}")
      new[-1] = line
    end
    new
  end

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
