# line cookbook

[![Build Status](https://www.travis-ci.org/sous-chefs/line-cookbook.svg?branch=master)](https://www.travis-ci.org/sous-chefs/line-cookbook)

# Motivation

Quite often, the need arises to do line editing instead of managing an entire file with a template resource. This cookbook supplies various resources that will help you do this.

# Limitations

- The line resources processes the entire target file in memory. Trying to edit large files may fail.
- The end of line processing was only tested using`\n` and `\r\n`. Using other line endings very well may not work.
- The end of line string used needs to match the actual end of line used in the file `\n` and `\r\n` are used as the defaults but if they don't match the actual end of line used in the file the results will be weird.
- Adding a line implies there is a separator on the previous line. Adding a line differs from appending characters.
- Lines to be added should not contain EOL characters. The providers do not do multiline regex checks.
- Missing file processing is the way it is by intention

  - `add_to_list` do nothing, list not found so there is nothing to add to.
  - `append_if_no_line` create file, add the line.
  - `delete_from_list` do nothing, the list was not found which implies there is nothing to delete
  - `delete_lines` do nothing, the line isn't there which implies there is nothing to delete
  - `replace_or_add` create file, add the line
- Chef client version 13 or greater is expected. Some limited testing on Chef client 12 has been done and the cookbook seems to work. PRs for chef 12 support will be considered.
 Chef 12 support is incomplete, some testing of of line version 2 on chef client 12 has been done and the resources pass the integration tests.  One known feature that does not
 work is the chef spec matchers.  The matchers were removed because they are automatically generated in chef 13.

# Usage

Add "depends 'line'" to your cookbook's metadata.rb to gain access to the resoures.

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


filter_lines 'Shift lines to at least 8 leading spaces' do
  path '/some/file'
  filter proc { |current| current.map(|line| line =~ /^ {8}/ ? line : "       #{line}") }
end

insert_lines = %w(line1 line2 line3)
match_pattern = /^COMMENT ME|^HELLO/
filter_lines 'Insert lines after match' do
  path '/some/file'
  filter after: [match_pattern, insert_lines]
end

filter_lines 'Built in example filters' do
  path '/tmp/multiple_filters'
  sensitive false
  filters(
    [
    # insert lines after the last match
      { after:  [match_pattern, insert_lines, :last] },
    ]
  )
end
```
# Resource Notes

The resources implemented are:

```ruby
append_if_no_line - Add a missing line
replace_or_add    - Replace a line that matches a pattern or add a missing line
delete_lines      - Delete an item from a list
add_to_list       - Add an item to a list
delete_from_list  - Delete lines that match a pattern
filter_lines      - Supply a proc or use a sample filter
  Sample filters:
    after          - Insert lines before a match

```

## Resource: append_if_no_line

### Actions

Action | Description
------ | -------------------------------
edit   | Append a line if it is missing.

### Properties

Properties     | Description                       | Type          | Values and Default
-------------- | --------------------------------- | ------------- | ---------------------------------------
path           | File to update                    | String        | Required, no default
line           | Line contents                     | String        | Required, no default
ignore_missing | Don't fail if the file is missing | true or false | Default is true
eol            | Alternate line end characters     | String        | default `\n` on unix, `\r\n` on windows
backup         | Backup before changing            | Boolean       | default false

### Notes

This resource is intended to match the whole line **exactly**. That means if the file contains `this is my line` (trailing whitespace) and you've specified `line "this is my line"`, another line will be added. You may want to use `replace_or_add` instead, depending on your use case.

## Resource: replace_or_add

### Actions

Action | Description
------ | -----------------------------------------------------------------------------------------------
edit   | Replace lines that match the pattern. Append the line unless a source line matches the pattern.

### Properties

Properties     | Description                              | Type                         | Values and Default
-------------- | ---------------------------------------- | ---------------------------- | ---------------------------------------
path           | File to update                           | String                       | Required, no default
pattern        | Regular expression to select lines       | Regular expression or String | Required, no default
line           | Line contents                            | String                       | Required, no default
replace_only   | Don't append only replace matching lines | true or false                | Required, no default
ignore_missing | Don't fail if the file is missing        | true or false                | Default is true
eol            | Alternate line end characters            | String                       | default `\n` on unix, `\r\n` on windows
backup         | Backup before changing                   | Boolean                      | default false

## Resource: delete_lines

### Actions

Action | Description
------ | ------------------------------------
edit   | Delete lines that match the pattern.

### Properties

Properties     | Description                        | Type                         | Values and Default
-------------- | ---------------------------------- | ---------------------------- | ---------------------------------------
path           | File to update                     | String                       | Required, no default
pattern        | Regular expression to select lines | Regular expression or String | Required, no default
ignore_missing | Don't fail if the file is missing  | true or false                | Default is true
eol            | Alternate line end characters      | String                       | default `\n` on unix, `\r\n` on windows
backup         | Backup before changing             | Boolean                      | default false

### Notes

Removes lines based on a string or regex.

## Resource: add_to_list

### Actions

Action | Description
------ | ---------------------
edit   | Add an item to a list

### Properties

Properties     | Description                        | Type                         | Values and Default
-------------- | ---------------------------------- | ---------------------------- | -------------------------------------------
path           | File to update                     | String                       | Required, no default
pattern        | Regular expression to select lines | Regular expression or String | Required, no default
delim          | Delimiter entries                  | Array                        | Array of 1, 2 or 3 multi-character elements
entry          | Value to add                       | String                       | Required, No default
ends_with      | List ending                        | String                       | No default
ignore_missing | Don't fail if the file is missing  | true or false                | Default is true
eol            | Alternate line end characters      | String                       | default `\n` on unix, `\r\n` on windows
backup         | Backup before changing             | Boolean                      | default false

### Notes

If one delimiter is given, it is assumed that either the delimiter or the given search pattern will proceed each entry and each entry will be followed by either the delimiter or a new line character: People to call: Joe, Bobby delim [","] entry 'Karen' People to call: Joe, Bobby, Karen

If two delimiters are given, the first is used as the list element delimiter and the second as entry delimiters: my @net1918 = ("10.0.0.0/8", "172.16.0.0/12"); delim [", ", "\""] entry "192.168.0.0/16" my @net1918 = ("10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16");

if three delimiters are given, the first is used as the list element delimiter, the second as the leading entry delimiter and the third as the trailing delimiter: multi = ([310], [818]) delim [", ", "[", "]"] entry "425" multi = ([310], [818], [425])

end_with is an optional property. If specified a list is expected to end with the given string.

## Resource: delete_from_list

### Actions

Action | Description
------ | --------------------------
edit   | Delete an item from a list

### Properties

Properties     | Description                        | Type                         | Values and Default
-------------- | ---------------------------------- | ---------------------------- | -------------------------------------------
path           | File to update                     | String                       | Required, no default
pattern        | Regular expression to select lines | Regular expression or String | Required, no default
delim          | Delimiter entries                  | Array                        | Array of 1, 2 or 3 multi-character elements
entry          | Value to delete                    | String                       | Required, No default
ends_with      | List ending                        | String                       | No default
ignore_missing | Don't fail if the file is missing  | true or false                | Default is true
eol            | Alternate line end characters      | String                       | default `\n` on unix, `\r\n` on windows
backup         | Backup before changing             | Boolean                      | default false

### Notes

Delimiters works exactly the same way as `add_to_list`, see above.


## Resource: filter_lines
### Actions
Action | Description
-------|------------
edit | Use a proc

### Properties
Properties | Description | Type | Values and Default
---------------|-------------|--------|--------
path           | String |  Path to file | Required, no default
filters        | Array of filters, Proc, Method |  See the filter grammar | Required, no default
ignore_missing | Don't fail if the file is missing  |  true or false | Default is true
eol            | Alternate line end characters |  String | default \n on unix, \r\n on windows
backup         | Backup before changing |  Boolean | default false

### Notes
The filter_lines resource passes the contents of the path file in an array of lines to a Proc or Method
filter. The filter should return an array of lines. The output array will be written to the file or passed to the next filter.
The built in filters are usable examples of what can be done with a filter, please write your own when you have specific needs.
The built in filters all take an array of positional arguments.

### Filter Grammar
```

filters ::= filter | [<filter>, ...]
filter ::= <code> | { <code> => <args>  }
args   ::= <String> | <Array>
code   ::= <Symbol> | <Method> | <Proc>
Symbol ::= :after | :before | :between | :comment | :replace | :stanza | :substitute
           Symbols are translated to methods in Line::Filter
Method ::= A reference to a method that has a signature of method(current lines is Array, args is Array)
           and that  returns an array
Proc ::=   A reference to a proc that has a signature of proc(current lines is Array, args is Array)
           and returns an array

```

### Filters
Built in Filter | Description | Arguments | arg1 | arg2  | arg3 |
----------------|-------------|-----------|--|--|--|
 :after | Insert lines after a matching line | Pattern to match | String or Array of lines to insert | :each, :first, or :last to select the matching lines

### Other cookbooks for line processing available via [Supermarket](https://supermarket.chef.io)
- [poise-file](https://supermarket.chef.io/cookbooks/poise-file) - Advanced file management
- [augeas](https://supermarket.chef.io/cookbooks/augeas) - [Augeas](http://augeas.net) support for editting many configuration file formats

# Author

- Contributor: Mark Gibbons
- Contributor: Dan Webb
- Contributor: Sean OMeara
- Contributor: Antek S. Baranski
