property :backup, [true, false], default: false
property :eol, String, default: Line::OS.unix? ? "\n" : "\r\n"
property :ignore_missing, [true, false], default: true
property :path, String
property :pattern, [String, Regexp]

resource_name :delete_lines

action :edit do
  return if !target_file_exist? && new_resource.ignore_missing
  raise_not_found
  sensitive_default
  eol = new_resource.eol
  regex = new_resource.pattern.is_a?(String) ? /#{new_resource.pattern}/ : new_resource.pattern
  current = target_current_lines

  # remove lines
  new = current.reject { |l| l =~ regex }

  # Last line terminator
  new[-1] += eol unless new[-1].to_s.empty?

  file new_resource.path do
    content new.join(eol)
    backup new_resource.backup
    sensitive new_resource.sensitive
    not_if { new == current }
  end
end

action_class do
  include Line::Helper
end
