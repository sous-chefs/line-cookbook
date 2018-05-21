# Filters to massage files
module Line
  class Filter
    def before(current, args)
      # Insert a set of lines before each match of the pattern
      # current is an array of lines
      # args[0] is a pattern to match a line
      # args[1] is an array of lines to insert before the matched lines
      # args[2] match instance, flatten, first, last
      mp = args[0]
      ia = args[1]
      select_match = args[2] || :flatten
      is = ia.size
      matches = []
      added_lines = 0
      # find matching lines
      current.each_index { |i| matches << i if current[i] =~ mp }
      [matches.send(select_match.to_s)].flatten.each do |match|
        next unless match
        lines_match = false
        # check to see if enough lines before to match
        if match + added_lines - is > -1
          # compare to see if the inserted lines are already there
          lines_match = true
          (0..(is - 1)).each do |j|
            next if current[match + added_lines - is + j] == ia[j]
            lines_match = false
            break
          end
        end
        # insert the new lines before the matched line
        (0..(is - 1)).each { |i| current.insert(match + added_lines, ia[i]); added_lines += 1 } unless lines_match
      end
      current
    end

    def after(current, args)
      # Insert a set of lines after each match of the pattern
      # current is an array of lines
      # args[0] is a pattern to match a line
      # args[1] is an array of lines to insert after the matched lines
      # args[2] match instance, flatten, first, last
      mp = args[0]
      ia = args[1]
      select_match = args[2] || :flatten
      is = ia.size
      matches = []
      added_lines = 0
      # find matching lines
      current.each_index { |i| matches << i if current[i] =~ mp }
      [matches.send(select_match.to_s)].flatten.each do |match|
        next unless match
        lines_match = false
        # check to see if enough lines after to match
        if current.size - (match + added_lines) > is
          # compare to see if the inserted lines are already there
          lines_match = true
          (0..(is - 1)).each do |j|
            next if current[match + added_lines + 1 + j] == ia[j]
            lines_match = false
            break
          end
        end
        # insert the new lines after the matched line
        (0..(is - 1)).each { |i| current.insert(match + added_lines + 1, ia[i]); added_lines += 1 } unless lines_match
      end
      current
    end
  end
end
