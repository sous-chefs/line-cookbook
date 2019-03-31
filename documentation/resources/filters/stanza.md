# Examples for the stanza filter

## Original file
````
[first]
line1 value1
[second]
line2 vaule2
````

## Output file
````
[first]
line1 new1
line2 addme
[second]
line2 value2
line3 add3
````

## Filter
````
filter_lines '/example' do
 filters([
   { stanza: ['first', { line1: 'new1', line2: 'addme'}] },
   { stanza: ['second', { line3: 'add3' }] },
 ])
end
