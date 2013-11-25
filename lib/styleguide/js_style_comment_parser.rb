module Styleguide

  # Parse a file of a given name for JavaScript style comments
  # that appear in the file
  # (i.e.
  #   single line:
  #     // to end of line AND
  #   multiline:
  #     /*
  #      up to
  #      */
  # )
  #
  # the comments are returned as an array, an each element of the
  # array is itself the array of contiguous comments.
  #
  # For single line comments this means any line comments that are next to
  # each other are merged into one comment (an element in the array)
  #
  # For multi line comments each each comment is split into a single item
  # of the array and any additional stars that are included at the start
  # of the comment line are removed
  #
  # Whitespace is trimmed from the start and end of the lines of
  # both types of comment
  #
  # =Example
  #  parser = Styleguide.JSStyleCommentParser.new('file name')
  #  comments = parser.parse()
  class JSStyleCommentParser

    SINGLE_LINE_COMMENT_RE = /^.*\/\/(.*)$/
    MULTI_LINE_COMMENT_ONE_LINE_RE = /^.*\/\*(.*)\*\/.*$/
    MULTI_LINE_COMMENT_START_RE = /^.*\/\*(.*)$/
    MULTI_LINE_COMMENT_MIDDLE_RE = /^\s*\*?(.*)$/
    MULTI_LINE_COMMENT_END_RE = /^\s*\*?(.*)\*\/.*$/

    # Initializes an instance by storing a copy of the file
    # split into lines or the empty array if the file does not exist
    #
    # :arg: file_name - the path of the file to parse
    def initialize(file_name)
      if ::File.exists?(file_name)
        file_contents = ::File.read(file_name)
        @lines = file_contents.split("\n")
      else
        @lines = []
      end
      @comments = []
      @current_comment = []
      @in_multi_comment = false
    end

    # Parse the JavaScript style comments from the file
    #
    # Returns an array of comments where each element of the array
    # is the array of lines in the comment
    #
    # For single line comments, any comments on adjacent lines are
    # merged together
    #
    # For multi line comments the comment is returned as a single
    # comment in the array (although still split into lines)
    def parse
      @lines.each do |line|
        if(match = line.match(SINGLE_LINE_COMMENT_RE))
          @current_comment.push(match[1].strip())
        elsif(match = line.match(MULTI_LINE_COMMENT_ONE_LINE_RE))
          @comments.push(@current_comment) if not @current_comment.empty?
          @current_comment = []
          @current_comment.push(match[1].strip())
          @comments.push(@current_comment) if not @current_comment.empty?
          @current_comment = []
        elsif(match = line.match(MULTI_LINE_COMMENT_START_RE))
          @comments.push(@current_comment) if not @current_comment.empty?
          @current_comment = []
          @current_comment.push(match[1].strip())
          @in_multi_comment = true
        elsif @in_multi_comment and (match = line.match(MULTI_LINE_COMMENT_END_RE))
          @current_comment.push(match[1].strip())
          @comments.push(@current_comment) if not @current_comment.empty?
          @current_comment = []
          @in_multi_comment = false
        elsif @in_multi_comment and (match = line.match(MULTI_LINE_COMMENT_MIDDLE_RE))
          @current_comment.push(match[1].strip())
        else
          @comments.push(@current_comment) if not @current_comment.empty?
          @current_comment = []
        end
      end
      @comments.push(@current_comment) if not @current_comment.empty?
      @comments
    end

  end

end