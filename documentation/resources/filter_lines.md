# Resource: filter_lines

## Actions

| Action | Description |
| ------ | ----------- |
| edit   | Use a proc  |

## Properties

| Properties     | Description                       | Type                   | Values and Default                  |
| -------------- | --------------------------------- | ---------------------- | ----------------------------------- |
| path           | String                            | Path to file           | Required, no default                |
| filters        | Array of filters, Proc, Method    | See the filter grammar | Required, no default                |
| ignore_missing | Don't fail if the file is missing | true or false          | Default is true                     |
| eol            | Alternate line end characters     | String                 | default \n on unix, \r\n on windows |
| backup         | Backup before changing            | Boolean, Integer       | default false                       |
| safe           | Verify that the inserts don't cause a file to grow with each converge. The filter must support safe mode for this to work. |  Boolean                | default true

## Example Usage

```ruby

filter_lines 'Shift lines to at least 8 leading spaces' do
  path '/some/file'
  filters proc { |current| current.map(|line| line =~ /^ {8}/ ? line : "       #{line}") }
end
```

```ruby
# For the provided sample filters the line input can be in an array or string with line delimeters
insert_lines = %w(line1 line2 line3)
text_lines = 
'line1
line2
line3'.gsub(/^\s+/, '')


match_pattern = /^COMMENT ME|^HELLO/
filter_lines 'Insert lines after match' do
  path '/some/file'
  filters after: [match_pattern, insert_lines]
end

filter_lines 'Built in example filters' do
  path '/tmp/multiple_filters'
  sensitive false
  filters(
    [
    # insert lines after the last match
      { after:  [match_pattern, insert_lines, :last] },
    # insert lines before the first  match
      { before: [match_pattern, text_lines, :first]  },
    ]
  )
end
```

## Notes

The filter_lines resource passes the contents of the path file in an array of lines to a Proc or Method
filter. The filter should return an array of lines. The output array will be written to the file or passed to the next filter.
The built in filters are usable examples of what can be done with a filter, please write your own when you have specific needs.
The built in filters all take an array of positional arguments.

## Filter Options
Options are expected to be either a hash, with the following keys and values, or nil.

* safe: true or false.  Overrides the default set by the resource property. If an inserted line matches the insert point selection pattern the line may be inserted repeatedy. Setting safe to true prevents those inserts.

## Filter Grammar

```text
filters ::= filter | [<filter>, ...]
filter  ::= <code> | { <code> => <args>  }
args    ::= <String> | <Array>
code    ::= <Symbol> | <Method> | <Proc>
Symbol  ::= :after | :before | :between | :comment | :replace | :stanza | :substitute
            Symbols are translated to methods in Line::Filter
Method  ::= A reference to a method that has a signature of method(current lines is Array, args is Array)
            and that  returns an array
Proc    ::= A reference to a proc that has a signature of proc(current lines is Array, args is Array)
            and returns an array
```

## Filters

| Built in Filter | Description                                 | Arguments        | arg1                               | arg2                                                       | arg3 |
| --------------- | ------------------------------------------- | ---------------- | ---------------------------------- | ---------------------------------------------------------- | ---- |
| [:after](filters/after.md)    | Insert lines after a matching line          | Pattern to match | String or Array of lines to insert | `:each`, `:first`, or `:last` to select the matching lines | options |
| [:before](filters/before.md)       | Insert lines before a matching line         | Pattern to match | String or Array of lines to insert | :each, :first, or :last to select the matching lines       | options |
| [:between](filters/between.md)      | Insert lines between matched lines          | Pattern - Insert after this| Pattern - Insert before this | Lines to insert | options |
| [:comment](filters/comment.md)      | Change lines to comments                    | Pattern to match | Comment string                     |  String to add after the comment indicator   |  |
| [:delete_between](filters/delete_between.md)| Delete lines between matching patterns     | Pattern - delete after this | Pattern - delete before this | `:exclude`, `:include`, `:first`, `:last` | |
| [:missing](filters/missing.md)      | Insert lines before or after existing lines | String or Array of lines to add | `:before`, `:after` | |
| [:replace](filters/replace.md)      | Replace matching lines                      | Pattern to match | String or Array to replace the matched line | options                       | |
| [:stanza](filters/stanza.md)       | Insert or change keys in a stanza           | Stanza name | Hash of keys and values to set   |             | options |
| [:substitute](filters/substitute.md)   | substitute test in matching lines           | Pattern to select lines | Pattern to select text | Replacement text |  options |
