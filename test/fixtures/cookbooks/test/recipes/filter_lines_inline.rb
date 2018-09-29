#
# Test an inline filter
#

directory '/tmp'

# ==================== Inline proc filters =================

template '/tmp/dangerfile' do
end

filter_lines 'Do nothing' do
  sensitive false
  path '/tmp/dangerfile'
  filters proc { |current| current }
end

template '/tmp/reverse' do
  source 'dangerfile.erb'
end

filter_lines 'Reverse line text' do
  sensitive false
  path '/tmp/reverse'
  filters proc { |current| current.map(&:reverse) }
end
