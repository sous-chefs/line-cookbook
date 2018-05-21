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
property :pattern, [String, Regexp]
property :line, String
property :replace_only, [true, false]
property :eol, String, default: Line::OS.unix? ? "\n" : "\r\n"
property :backup, [true, false], default: false

resource_name :replace_or_add

action :edit do
  new_resource.sensitive = true unless property_is_set?(:sensitive)
  regex = new_resource.pattern.is_a?(String) ? /#{new_resource.pattern}/ : new_resource.pattern
  eol = new_resource.eol
  new = []
  found = false

  current = ::File.exist?(new_resource.path) ? ::File.binread(new_resource.path).split(eol) : []

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

  # Last line terminator
  new[-1] += eol unless new[-1].to_s.empty?

  file new_resource.path do
    content new.join(eol)
    backup new_resource.backup
    sensitive new_resource.sensitive
    not_if { new == current }
  end
end
