# Examples for the before filter

## Original file
````
line1
line2
````

## Output file
````
line1
add1
add2
line2
````

## Filter
````
addlines = "add1\nadd2\n"
filter_lines '/example' do
 filters(before: [/^line2$/, addlines, :last])
end
