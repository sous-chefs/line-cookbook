# Examples for the after filter

## Original file
````
line1
line2
````

## Output file
````
line1
line2
add1
add2
````

## Filter
````
addlines = "add1\nadd2\n"
or
addlines = ['add1', 'add2']
or
lines = <<~EOF
 add1
 add2
EOF
addlines= lines.gsub(/^\s+/,'')

filter_lines '/example' do
 filters(after: [/^line2$/, addlines, :last])
end
