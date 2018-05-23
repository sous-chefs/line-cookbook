module Line
  module Helper
    def raise_not_found
      raise "File #{new_resource.path} not found" unless target_file_exist? || new_resource.ignore_missing
    end

    def sensitive_default
      new_resource.sensitive = true unless property_is_set?(:sensitive)
    end

    def target_current_lines
      target_file_exist? ? ::File.binread(new_resource.path).split(new_resource.eol) : []
    end

    def target_file_exist?
      @target_file_exist ||= ::File.exist?(new_resource.path)
    end
  end
end
