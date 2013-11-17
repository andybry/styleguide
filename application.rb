require 'pp'
require 'find'

# strip stars and spaces from the beginning and end of the 
# string
def trim(string)
  string.gsub(/^(\s|\*)+|(\s|\*)+$/, '')
end

###############################################################################
# Calculate the possible comments for a file
###############################################################################
def retrieve_possible_comments(file_name)
  src = ::File.read(file_name)
  src_lines = src.split("\n")
  current_comment = [] # an array of lines representing the current comment
  comments = [] # an array of all the comments that we have so far
  previous_line_type = :normal
  #
  # line types (based on how the line ends): 
  #   normal              - end of a multi line comment or no comment
  #   multi_line_comment  - start of a multi line comment, middle of multi line comment
  #   single_line_comment - single line comment
  #
  src_lines.each do |line|
    if(match = line.match(/^(.*)\*\/(.*)$/) and previous_line_type == :multi_line_comment) # end of multi-line
      current_comment << trim(match[2])
      comments << current_comment
      current_comment = []
      previous_line_type = :normal
    elsif(previous_line_type == :multi_line_comment) # middle of multi-line comment
      current_comment << trim(line)
      previous_line_type = :multi_line_comment
    elsif(match = line.match(/^(.*)\/\*(.*)$/)) # start of multi-line comment
      comments << current_comment if(current_comment.length > 0)
      current_comment = []
      current_comment << trim(match[2])
      previous_line_type = :multi_line_comment
    elsif(match = line.match(/\/\/(.*)/)) # single_line_comment
      if(previous_line_type == :single_line_comment) 
        current_comment << trim(match[1])
      else
        comments << current_comment if(current_comment.length > 0)
        current_comment = []
        current_comment << trim(match[1])
      end
      previous_line_type = :single_line_comment
    elsif(previous_line_type == :single_line_comment) # normal line type
      comments << current_comment if(current_comment.length > 0)
      current_comment = []
    end
  end
  comments
end

###############################################################################
# Calculate possible comments for all JS and CSS files
###############################################################################
comments_so_far = []
files = []

Find.find('.') do |path|
  if(::File.file?(path) and path.match(/\.(scss|js)(\.)?/))
    files << path if(not path.match(/\.swp$/))
  end
end

files.each do |file|
  comments_so_far.concat(retrieve_possible_comments(file))
end
