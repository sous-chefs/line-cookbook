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
property :delim, Array
property :entry, String
property :ignore_missing, [true, false], default: false
property :eol, String, default: Line::OS.unix? ? "\n" : "\r\n"
property :backup, [true, false], default: false

resource_name :delete_from_list

action :edit do
  return if !::File.exist?(new_resource.path) && new_resource.ignore_missing
  raise "File #{new_resource.path} not found" unless ::File.exist?(new_resource.path)

  new_resource.sensitive = true unless property_is_set?(:sensitive)
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
    sensitive new_resource.sensitive
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
