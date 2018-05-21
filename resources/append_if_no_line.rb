#
# Copyright 2017, Sous Chefs
#
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

property :path, String
property :line, String
property :ignore_missing, [true, false], default: false
property :eol, String, default: Line::OS.unix? ? "\n" : "\r\n"
property :backup, [true, false], default: false

resource_name :append_if_no_line

action :edit do
  file_exist = ::File.exist?(new_resource.path)
  raise "File #{new_resource.path} not found" unless file_exist || new_resource.ignore_missing

  new_resource.sensitive = true unless property_is_set?(:sensitive)
  eol = new_resource.eol
  string = Regexp.escape(new_resource.line)
  regex = /^#{string}$/
  current = file_exist ? ::File.binread(new_resource.path).split(eol) : []

  file new_resource.path do
    content((current + [new_resource.line + eol]).join(eol))
    backup new_resource.backup
    sensitive new_resource.sensitive
    not_if { ::File.exist?(new_resource.path) && !current.grep(regex).empty? }
  end
end
