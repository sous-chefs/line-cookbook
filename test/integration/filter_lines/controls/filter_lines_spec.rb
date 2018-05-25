control 'filter_lines - Verify the code to use filters. Verify several example filters' do

  eol = os.family == 'windows' ? "\r\n" : "\n"

  # do nothing
  describe file('/tmp/dangerfile') do
    its(:content) { should match(/^HELLO THERE I AM DANGERFILE.*last line#{eol}$/m) }
  end
  describe file_ext('/tmp/dangerfile') do
     its('size_lines') { should eq 5 }
  end

  # reverse the characters in each line
  describe file('/tmp/reverse') do
    its(:content) { should match(/OLLEH#{eol}/) }
    its(:content) { should match(/^enil tsal#{eol}/) }
  end

  describe file('/tmp/before') do
    its(:content) { should match(/line1#{eol}line2#{eol}line3#{eol}HELLO THERE/m) }
    its(:content) { should match(/line1#{eol}line2#{eol}line3#{eol}COMMENT ME/m) }
  end
  describe file_ext('/tmp/before') do
     its('size_lines') { should eq 11 }
  end

  describe file('/tmp/before_first') do
    its(:content) { should match(/line1#{eol}line2#{eol}line3#{eol}HELLO THERE/m) }
    its(:content) { should match(/FOOL#{eol}COMMENT ME/m) }
  end
  describe file_ext('/tmp/before_first') do
     its('size_lines') { should eq 8 }
  end

  describe file('/tmp/before_last') do
    its(:content) { should match(/^HELLO THERE/m) }
    its(:content) { should match(/line1#{eol}line2#{eol}line3#{eol}COMMENT ME/m) }
  end
  describe file_ext('/tmp/before_last') do
     its('size_lines') { should eq 8 }
  end

  describe file('/tmp/after') do
    its(:content) { should match(/HELLO THERE I AM DANGERFILE#{eol}line1#{eol}line2#{eol}line3#{eol}# UN/m) }
    its(:content) { should match(/COMMENT ME AND I STOP YELLING I PROMISE#{eol}line1#{eol}line2#{eol}line3#{eol}int/m) }
  end
  describe file_ext('/tmp/after') do
     its('size_lines') { should eq 11 }
  end

  describe file('/tmp/after_first') do
    its(:content) { should match(/HELLO THERE I AM DANGERFILE#{eol}line1#{eol}line2#{eol}line3#{eol}# UN/m) }
    its(:content) { should match(/COMMENT ME AND I STOP YELLING I PROMISE#{eol}int/m) }
  end
  describe file_ext('/tmp/after_last') do
     its('size_lines') { should eq 8 }
  end

  describe file('/tmp/after_last') do
    its(:content) { should match(/HELLO THERE I AM DANGERFILE#{eol}# UNCOMMENT/m) }
    its(:content) { should match(/COMMENT ME AND I STOP YELLING I PROMISE#{eol}line1#{eol}line2#{eol}line3#{eol}int/m) }
  end
  describe file_ext('/tmp/after_last') do
     its('size_lines') { should eq 8 }
  end
end
