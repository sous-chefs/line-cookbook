# Examples for the comment filter

## Original file
````
line1
line2
line
````

## Output file
````
#      line1
#      line2
line
````

## Filter
````
addlines = "add1\nadd2\n"
filter_lines '/example/comment' do
 filters(comment: [/^line\d+$/, '#'/, '      ')
end
