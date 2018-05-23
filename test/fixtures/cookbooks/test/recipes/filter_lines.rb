directory '/tmp'

template '/tmp/dangerfile' do
end

filter_lines 'Do nothing' do
  path '/tmp/dangerfile'
  filter proc { |current| current }
end

template '/tmp/reverse' do
  source 'dangerfile.erb'
end

filter_lines 'Reverse line text' do
  path '/tmp/reverse'
  filter proc { |current| current.map(&:reverse) }
end

# before
# after
# between
filters = Line::Filter.new
insert_lines = %w(line1 line2 line3)
match_pattern = /^COMMENT ME|^HELLO/

# ==================== before filter =================
template '/tmp/before' do
  source 'dangerfile.erb'
  sensitive true
end

filter_lines 'Insert lines before match' do
  path '/tmp/before'
  sensitive false
  filter filters.method(:before)
  filter_args [match_pattern, insert_lines]
end

filter_lines 'Insert lines before match 2nd try' do
  path '/tmp/before'
  sensitive false
  filter filters.method(:before)
  filter_args [match_pattern, insert_lines]
end

template '/tmp/before_first' do
  source 'dangerfile.erb'
  sensitive true
end

filter_lines 'Insert lines before match' do
  path '/tmp/before_first'
  sensitive false
  filter filters.method(:before)
  filter_args [match_pattern, insert_lines, :first]
end

template '/tmp/before_last' do
  source 'dangerfile.erb'
  sensitive true
end

filter_lines 'Insert lines last match' do
  path '/tmp/before_last'
  sensitive false
  filter filters.method(:before)
  filter_args [match_pattern, insert_lines, :last]
end

# ==================== after filter =================

template '/tmp/after' do
  source 'dangerfile.erb'
  sensitive true
end

filter_lines 'Insert lines after match' do
  path '/tmp/after'
  sensitive false
  filter filters.method(:after)
  filter_args [match_pattern, insert_lines]
end

filter_lines 'Insert lines after match 2nd try' do
  path '/tmp/after'
  sensitive false
  filter filters.method(:after)
  filter_args [match_pattern, insert_lines]
end

template '/tmp/after_first' do
  source 'dangerfile.erb'
  sensitive true
end

filter_lines 'Insert lines after first match' do
  path '/tmp/after_first'
  sensitive false
  filter filters.method(:after)
  filter_args [match_pattern, insert_lines, :first]
end

template '/tmp/after_last' do
  source 'dangerfile.erb'
  sensitive true
end

filter_lines 'Insert lines after last match' do
  path '/tmp/after_last'
  sensitive false
  filter filters.method(:after)
  filter_args [match_pattern, insert_lines, :last]
end

# =====================

file '/tmp/emptyfile' do
  content ''
end

filter_lines 'Do nothing to the empty file' do
  path '/tmp/emptyfile'
  filter proc { |current| current }
end
