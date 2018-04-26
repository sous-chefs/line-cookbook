property :path, String
property :pattern, [String, Regexp]
property :line, String
property :replace_only, [true, false]
property :eol, String, default: Line::OS.unix? ? "\n" : "\r\n"
property :discrete, [true, false], default: true
property :backup, [true, false], default: false

resource_name :replace_or_add

action :edit do
  regex = new_resource.pattern.is_a?(String) ? /#{new_resource.pattern}/ : new_resource.pattern

  eol = new_resource.eol
  new = []

  if ::File.exist?(new_resource.path)
    current = ::File.binread(new_resource.path).split(eol)
    found = false
  else
    current = []
    unless new_resource.replace_only
      found = true
      new << new_resource.line
    end
  end

  # replace
  current.each do |line|
    line = line.dup
    if line =~ regex || line == new_resource.line
      found = true
      line = new_resource.line unless line == new_resource.line
    end
    new << line
  end

  # add
  new << new_resource.line unless found || new_resource.replace_only

  new[-1] += eol unless new[-1].to_s.empty?

  file new_resource.path do
    content new.join(eol)
    backup new_resource.backup
    sensitive new_resource.discrete
    not_if { new == current }
  end
end
