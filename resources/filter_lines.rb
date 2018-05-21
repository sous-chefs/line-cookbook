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

property :backup, [true, false], default: false
property :eol, String, default: Line::OS.unix? ? "\n" : "\r\n"
property :filter, [Method, Proc, Array]
property :filter_args, Array
property :path, String

resource_name :filter_lines

action :edit do
  new_resource.sensitive = true unless property_is_set?(:sensitive)
  eol = new_resource.eol
  new = []

  current = ::File.exist?(new_resource.path) ? ::File.binread(new_resource.path).split(eol) : []

  # Proc or Method
  if new_resource.filter.is_a?(Method) || new_resource.filter.is_a?(Proc)
    new = new_resource.filter.call(current.dup, new_resource.filter_args)
  end

  # Last line terminator
  new[-1] += eol unless new[-1].to_s.empty?

  file new_resource.path do
    content new.join(eol)
    backup new_resource.backup
    sensitive new_resource.sensitive
    not_if { new == current }
  end
end
