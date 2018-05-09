directory '/tmp'

eol = (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) ? "\r\n" : "\n"
danger_contents = "HELLO THERE I AM DANGERFILE#{eol}# UNCOMMENT ME YOU FOOL#{eol}COMMENT ME AND I STOP YELLING I PROMISE#{eol}"

template '/tmp/dangerfile' do
end

file '/tmp/dangerfile2' do
  content danger_contents
end

append_if_no_line 'Operation' do
  path '/tmp/dangerfile'
  line 'HI THERE I AM STRING'
end

append_if_no_line 'Operation redo' do
  path '/tmp/dangerfile'
  line 'HI THERE I AM STRING'
end

append_if_no_line 'with special chars' do
  path '/tmp/dangerfile'
  line 'AM I A STRING?+\'".*/-\(){}^$[]'
end

append_if_no_line 'with special chars redo' do
  path '/tmp/dangerfile'
  line 'AM I A STRING?+\'".*/-\(){}^$[]'
end

file '/tmp/file_without_linereturn' do
  content 'no carriage return line'
end

append_if_no_line 'should go on its own line' do
  path '/tmp/file_without_linereturn'
  line 'SHOULD GO ON ITS OWN LINE'
end

append_if_no_line 'should not edit the file' do
  path '/tmp/file_without_linereturn'
  line 'no carriage return line'
end

file '/tmp/add_emptyfile'

append_if_no_line 'should add to empty file' do
  path '/tmp/add_emptyfile'
  line 'added line'
end

append_if_no_line 'create missing file' do
  path '/tmp/add_missing'
  line 'added line'
  ignore_missing true
end
