# Examples for the replace_between filter

## Original file
````
line1
line2
line3
````

## Output file
````
line1
rep1
rep2
line3
````

## Filter
````
replines = "rep1\nrep2\n"
filter_lines '/example/replace_between' do
 filters(replace_between: [/^line1$/, /^line2$/, replines])
end

## Original file
````
line1
line2
line3
````

## Output file
````
rep1
rep2
````

## Filter
````
replines = "rep1\nrep2\n"
filter_lines '/example/replace_between_include_bounds' do
 filters(replace_between: [/^line1$/, /^line2$/, replines, :include])
end
