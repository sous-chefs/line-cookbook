# Examples for the substitute filter

## Original file
````
line1 text here
line2 text here
````

## Output file
````
line1 text here
line2 text new
````

## Filter
````
filter_lines '/example' do
 filters(substitute: [/^line2/, /here/, 'new'])
end
