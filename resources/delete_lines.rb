property :path, String
property :pattern, [String, Regexp]
property :ignore_missing, [true, false], default: false
property :eol, String, default: Line::OS.unix? ? "\n" : "\r\n"
property :discrete, [true, false], default: true
property :backup, [true, false], default: false

resource_name :delete_lines

action :edit do
  return if !::File.exist?(new_resource.path) && new_resource.ignore_missing
  raise "File #{new_resource.path} not found" unless ::File.exist?(new_resource.path)

  eol = new_resource.eol
  regex = new_resource.pattern.is_a?(String) ? /#{new_resource.pattern}/ : new_resource.pattern
  current = ::File.binread(new_resource.path).split(eol)
  new = current.reject { |l| l =~ regex }
  new[-1] += eol unless new[-1].to_s.empty?

  file new_resource.path do
    content new.join(eol)
    backup new_resource.backup
    sensitive new_resource.discrete
    not_if { new == current }
  end
end
