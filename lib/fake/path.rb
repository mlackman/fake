module Fake
  class Path

    attr_reader :path

    def initialize(path)
      @path = path
    end

    def eql?(path_str)
      if dynamic?
        dynamic_paths_eql?(path_str)
      else
        path == path_str
      end
    end

  private

    def dynamic_paths_eql?(path_str)
      parts = path.split('/')
      other_parts = path_str.split('/')
      return false if parts.length != other_parts.length

      regexp_parts = convert_to_regexp(parts)

      regexp_parts.each_with_index do |regexp, index|
        return false unless regexp.match(other_parts[index])
      end
      return true
    end

    def dynamic?
      path.include?(':')
    end

    def convert_to_regexp(parts)
      parts.map do |part|
        if dynamic_path_part?(':')
          Regexp.new('.*')
        else
          Regexp.new('^#{part}$')
        end
      end
    end

    def dynamic_path_part?(part)
      part.start_with?(':')
    end

  end
end
