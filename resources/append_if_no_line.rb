property :backup, [true, false], default: false
property :eol, String
property :ignore_missing, [true, false], default: true
property :line, String
property :path, String

resource_name :append_if_no_line

action :edit do
  raise_not_found
  sensitive_default
  eol = default_eol
  string = Regexp.escape(new_resource.line)
  regex = /^#{string}$/
  current = target_current_lines

  file new_resource.path do
    content((current + [new_resource.line + eol]).join(eol))
    backup new_resource.backup
    sensitive new_resource.sensitive
    not_if { ::File.exist?(new_resource.path) && !current.grep(regex).empty? }
  end
end

action_class do
  include Line::Helper
end
