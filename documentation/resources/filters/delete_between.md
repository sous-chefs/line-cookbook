# Examples for the delete_between filter

## Original file
````
line1
del1
del2
line2
del1
del2
line3
````

## Output file
````
line1
del1
del2
line2
line3
````

## Filter
````
dellines = "del1\ndel2\n"
filter_lines '/example' do
 filters(delete_between: [/^line2$/, /^line3$/, dellines, :last])
end
