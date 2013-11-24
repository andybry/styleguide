require 'styleguide/js_style_comment_parser'

describe 'JSStyleCommentParser' do

  file_name = 'parser_text_file.txt'
  def write_file(file_name, file_lines)
    file = ::File.open(file_name, 'w+')
    file_text = file_lines.join("\n")
    file.write(file_text)
    file.close()
  end

  describe '#initialize' do
    context 'when the file exists' do
      file_lines = [
          'line 1 of the file',
          'line 2 of the file',
          'line 3 of the file'
      ]
      before(:each) do
        write_file(file_name, file_lines)
      end
      it 'stores an array of the lines in the file' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.instance_variable_get(:@lines)).to eq(file_lines)
      end
    end

    context 'when the file does not exist' do
      it 'stores an empty array' do
        instance = Styleguide::JSStyleCommentParser.new('file that does not exist')
        expect(instance.instance_variable_get(:@lines)).to eq([])
      end
    end
  end

  describe 'parse' do
    context 'file contains no comments' do
      file_lines = [
          'line 1',
          'line 2',
          'line 3'
      ]
      before(:each) do
        write_file(file_name, file_lines)
      end
      it 'returns the empty array' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.parse()).to eq([])
      end
    end
  end

  after(:each) do
    File.delete(file_name) if File.exists?(file_name)
  end

end
