property :path, String
property :line, String
property :ignore_missing, [true, false], default: false
property :eol, String, default: Line::OS.unix? ? "\n" : "\r\n"
property :discrete, [true, false], default: true
property :backup, [true, false], default: false

resource_name :append_if_no_line

action :edit do
  file_exist = ::File.exist?(new_resource.path)
  raise "File #{new_resource.path} not found" unless file_exist || new_resource.ignore_missing

  eol = new_resource.eol
  string = Regexp.escape(new_resource.line)
  regex = /^#{string}$/
  current = file_exist ? ::File.binread(new_resource.path).split(eol) : []

  file new_resource.path do
    content((current + [new_resource.line + eol]).join(eol))
    backup new_resource.backup
    sensitive new_resource.discrete
    not_if { ::File.exist?(new_resource.path) && !current.grep(regex).empty? }
  end
end
