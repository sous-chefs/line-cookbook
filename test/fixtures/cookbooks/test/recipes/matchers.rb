directory '/tmp'

add_to_list 'Add to list 1' do
  path '/tmp/dangerfile3'
  pattern 'empty_list='
  delim [' ']
  entry 'newentry'
end

append_if_no_line 'Operation' do
  path '/tmp/dangerfile'
  line 'HI THERE I AM STRING'
end

delete_from_list 'Delete Operation 1' do
  path '/tmp/dangerfile3'
  pattern 'my @net1918 ='
  delim [', ', '"']
  entry '10.0.0.0/8'
end

delete_lines 'Operation 5' do
  path '/tmp/dangerfile1'
  pattern '^HI.*'
end

replace_or_add 'Operation 2' do
  path '/tmp/dangerfile'
  pattern 'hey there.*'
  line 'hey there how you doin'
end
