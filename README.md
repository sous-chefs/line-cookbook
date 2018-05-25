# line cookbook
[![Build Status](https://www.travis-ci.org/sous-chefs/line-cookbook.svg?branch=master)](https://www.travis-ci.org/sous-chefs/line-cookbook)

# Motivation
Quite often, the need arises to do line editing instead of managing an
entire file with a template resource. This cookbook supplies various 
resources that will help you do this.

# Limitations
- The line resources processes the entire target file in memory. Trying to edit large files may fail.
- The eol processing was only tested using \n and \r\n. Using other line endings very well may not work.
- The end of line string used needs to match the actual end of line used in the file.  \n and \r\n are used as the defaults but if they don't match the actual end of line used in the file the results will be weird.
- Adding a line implies there is a seperator on the previous line.  Adding a line differs from appending characters.
- Missing file processing is the way it is by intention
  *  add_to_list -> do nothing, list not found so there is nothing to add to.
  *  append_if_no_line.rb -> create file, add the line.
  *  delete_from_list.rb -> do nothing, the list was not found which implies there is nothing to delete
  *  delete_lines.rb -> do nothing, the line isn’t there which implies there is nothing to delete
  *  replace_or_add.rb -> create file, add the line

# Usage
Add "depends 'line'" to your cookbook's metadata.rb to gain access to
the resoures.

```ruby
append_if_no_line "make sure a line is in some file" do
  path "/some/file"
  line "HI THERE I AM STRING"
end

replace_or_add "why hello" do
  path "/some/file"
  pattern "Why hello there.*"
  line "Why hello there, you beautiful person, you."
end

delete_lines "remove hash-comments from /some/file" do
  path "/some/file"
  pattern "^#.*"
end

delete_lines "remove hash-comments from /some/file with a regexp" do
  path "/some/file"
  pattern /^#.*/
end

replace_or_add "change the love, don't add more" do
  path "/some/file"
  pattern "Why hello there.*"
  line "Why hello there, you beautiful person, you."
  replace_only true
end

add_to_list "add entry to a list" do
  path "/some/file"
  pattern "People to call: "
  delim [","]
  entry "Bobby"
end

delete_from_list "delete entry from a list" do
  path "/some/file"
  pattern "People to call: "
  delim [","]
  entry "Bobby"
end

delete_lines 'remove from nonexisting' do
  path '/tmp/doesnotexist'
  pattern /^#/
  ignore_missing true
end
```

# Resource Notes
So far, the only resources implemented are 

```ruby
append_if_no_line
replace_or_add
delete_lines
add_to_list
delete_from_list
```

## Resource: append_if_no_line
### Actions
Action | Description 
-------|------------
edit | Append a line if it is missing.

### Properties
Properties | Description | Type | Values and Default
----------|-------------|--------|--------
path | File to update | String | Required, no default
line | Line contents |  String | Required, no default
ignore_missing | Don't fail if the file is missing  |  true or false | Default is true
eol | Alternate line end characters |  String | default \n on unix, \r\n on windows
backup | Backup before changing |  Boolean | default false

### Notes
This resource is intended to match the whole line __exactly__. That means
if the file contains ```this is my line ``` (trailing whitespace) and you've
specified `line "this is my line"`, another line will be added. You may
want to use `replace_or_add` instead, depending on your use case.

## Resource: replace_or_add
### Actions
Action | Description 
-------|------------
edit | Replace lines that match the pattern. Append the line unless a source line matches the pattern.

### Properties
Properties | Description | Type | Values and Default
----------|-------------|--------|--------
path | File to update | String | Required, no default
pattern | Regular expression to select lines | Regular expression or String | Required, no default
line | Line contents |  String | Required, no default
replace_only | Don't append only replace matching lines |  true or false | Required, no default
ignore_missing | Don't fail if the file is missing  |  true or false | Default is true
eol | Alternate line end characters |  String | default \n on unix, \r\n on windows
backup | Backup before changing |  Boolean | default false

## Resource: delete_lines
### Actions
Action | Description 
-------|------------
edit | Delete lines that match the pattern.

### Properties
Properties | Description | Type | Values and Default
----------|-------------|--------|--------
path | File to update | String | Required, no default
pattern | Regular expression to select lines | Regular expression or String | Required, no default
ignore_missing | Don't fail if the file is missing  |  true or false | Default is true
eol | Alternate line end characters |  String | default \n on unix, \r\n on windows
backup | Backup before changing |  Boolean | default false

### Notes
Removes lines based on a string or regex.

## Resource: add_to_list
### Actions
Action | Description 
-------|------------
edit | Add an item to a list

### Properties
Properties | Description | Type | Values and Default
----------|-------------|--------|--------
path | File to update |  String | Required, no default
pattern | Regular expression to select lines | Regular expression or String | Required, no default
delim | Delimiter entries | Array | Array of 1, 2 or 3 multi-character elements
entry | Value to add | String | Required, No default
ends_with | List ending |  String | No default
ignore_missing | Don't fail if the file is missing  |  true or false | Default is true
eol | Alternate line end characters |  String | default \n on unix, \r\n on windows
backup | Backup before changing |  Boolean | default false

### Notes
If one delimiter is given, it is assumed that either the delimiter or the given search pattern will proceed each entry and
each entry will be followed by either the delimeter or a new line character:
People to call: Joe, Bobby
delim [","]
entry 'Karen'
People to call: Joe, Bobby, Karen

If two delimiters are given, the first is used as the list element delimiter and the second as entry delimiters:
my @net1918 = ("10.0.0.0/8", "172.16.0.0/12");
delim [", ", "\""]
entry "192.168.0.0/16"
my @net1918 = ("10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16");
    
if three delimiters are given, the first is used as the list element delimiter, the second as the leading entry delimiter and the third as the trailing delimiter:
multi = ([310], [818])
delim [", ", "[", "]"]
entry "425"
multi = ([310], [818], [425])

end_with is an optional property. If specified a list is expected to end with the given string.
    
## Resource: delete_from_list
### Actions
Action | Description 
-------|------------
edit | Delete an item from a list

### Properties
Properties | Description | Type | Values and Default
----------|-------------|--------|--------
path | File to update |  String | Required, no default
pattern | Regular expression to select lines | Regular expression or String | Required, no default
delim | Delimiter entries | Array | Array of 1, 2 or 3 multi-character elements
entry | Value to delete | String | Required, No default
ends_with | List ending |  String | No default
ignore_missing | Don't fail if the file is missing  |  true or false | Default is true
eol | Alternate line end characters |  String | default \n on unix, \r\n on windows
backup | Backup before changing |  Boolean | default false

### Notes
Delimeters works exactly the same way as `add_to_list`, see above.


# Author
Author: Sean OMeara (<sean@sean.io>)  
Contributor: Antek S. Baranski (<antek.baranski@gmail.com>)
