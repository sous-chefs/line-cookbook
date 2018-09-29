#
# Verify the results of using the after filter
#

directory '/tmp'

# ==================== after filter =================

insert_lines = %w(line1 line2 line3)
match_pattern = /^COMMENT ME|^HELLO/

# ==================== after filter =================

template '/tmp/after' do
  source 'dangerfile.erb'
end

filter_lines 'Insert lines after match' do
  sensitive false
  path '/tmp/after'
  filters after: [match_pattern, insert_lines]
end

filter_lines 'Insert lines after match redo' do
  sensitive false
  path '/tmp/after'
  filters after: [match_pattern, insert_lines]
end

template '/tmp/after_first' do
  source 'dangerfile.erb'
end

filter_lines 'Insert lines after first match' do
  sensitive false
  path '/tmp/after_first'
  filters after: [match_pattern, insert_lines, :first]
end

template '/tmp/after_last' do
  source 'dangerfile.erb'
end

filter_lines 'Insert lines after last match' do
  sensitive false
  path '/tmp/after_last'
  filters after: [match_pattern, insert_lines, :last]
end
