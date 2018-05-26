# Filters to massage files
module Line
  class Filter
    def before(current, args)
      # Insert a set of lines immediately before each match of the pattern
      # current is an array of lines
      # args[0] is a pattern to match a line
      # args[1] is an array of lines to insert before the matched lines
      # args[2] match instance, flatten, first, last, (anywhere before)
      # TODO all of the lines are there anywhere before, order doesn't matter
      # TODO all of the lines are there ignore comments
      match_pattern = args[0]
      insert_array = args[1]
      select_match = args[2] || :flatten
      select_match = :flatten if select_match.to_s == 'each'

      # find lines matching the pattern
      matches = []
      current.each_index { |i| matches << i if current[i] =~ match_pattern }

      [matches.send(select_match.to_s)].flatten.each do |match|
        next if lines_match(current, match, insert_array, :before)
        current[match] = Replacement.new(current[match], insert_array, :before)
      end
      expand(current)
    end

    def after(current, args)
      # Insert a set of lines immediately after each match of the pattern
      # current is an array of lines
      # args[0] is a pattern to match a line
      # args[1] is an array of lines to insert after the matched lines
      # args[2] match instance, each => flatten, first, last, (anywhere after)
      # TODO all of the lines are there anywhere after, order doesn't matter
      match_pattern = args[0]
      insert_array = args[1]
      select_match = args[2] || :flatten
      select_match = :flatten if select_match.to_s == 'each'

      # find matching lines  (match object, line #, insert match, insert direction)
      matches = []
      current.each_index { |i| matches << i if current[i] =~ match_pattern }

      [matches.send(select_match.to_s)].flatten.each do |match|
        next if lines_match(current, match, insert_array, :after)
        current[match] = Replacement.new(current[match], insert_array, :after)
      end
      expand(current)
    end

  def augeas(current, args)
  # https://github.com/nhuff/chef-augeas
  end

  def in_stanza(current, args)
    # [a1]
    #   lines in the a1 stanza
    # [a2]
    # args[0] stanza matching pattern
    # args[1] stanza to select, if not there it will be created
    # args[3] pattern to match
    # args[4] line to replace or add to the stanza
    # args[5] match instance, each, first, last
    #
    # Find the matches
    # Select the matches
    # For each match
    #     Find next stanza or EOF
    #     Bounds on the stanza lines
    #     line matches pattern?
    #     yes - next match
  end

    def lines_match(lines, start, ia, direction)
      case direction
      when :before
        is = ia.size
        # check to see if enough lines before to match
        false
        if start - is > -1
          # compare to see if the inserted lines are already there
          (0..(is - 1)).each do |j|
            next if lines[start - is + j] == ia[j]
            break
          end
        end
      when :after
        is = ia.size
        # check to see if enough lines after to match
        if start + is <= lines.size
          # compare to see if the inserted lines are already there
          (0..(is - 1)).each do |j|
            next if lines[start + j +1] == ia[j]
            break
          end
        end
      end
    end

    def expand(lines)
      new_lines = []
      lines.each do |line|
        # note - want to do *lines to add them instead adding an array
        new_lines.push line.class == Replacement ? line.insert : line
      end
      new_lines.flatten # add the lines better so we don't need this
    end
  end

  class Replacement
    def initialize(original, additional, direction)
      @original = original.dup
      @additional = additional
      @direction = direction # replace, before, after
    end

    def ==(other)
      @original == other
    end

    def insert
      case @direction
      when :after
        [@additional].unshift(@original)
      when :before
        [@additional].push(@original)
      else
        [@original]
      end
    end
  end
end
