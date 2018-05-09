module Line
  module OS
    def self.windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
    end

    def self.unix?
      !OS.windows?
    end
  end
end
