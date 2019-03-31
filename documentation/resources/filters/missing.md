# Examples for the missing filter

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
filter_lines '/example' do
 filters(missing: [addlines, :last])
end
