# Examples for the between filter

## Original file
````
line1
line2
line3
````

## Output file
````
line1
line2
add1
add2
line3
````

## Filter
````
addlines = "add1\nadd2\n"
filter_lines '/example' do
 filters(between: [/^line2$/, /^line3$/, addlines, :last])
end
