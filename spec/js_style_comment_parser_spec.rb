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
      it 'initializes the comment to the empty array' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.instance_variable_get(:@comments)).to eq([])
      end
      it 'initializes the current comment to the empty array' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.instance_variable_get(:@current_comment)).to eq([])
      end
      it 'initializes the in_multi_line variable to false' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.instance_variable_get(:@in_multi_comment)).to be(false)
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

    context 'file contains a single line javascript comment' do
      file_lines = [
          '// line 1 of comment  '
      ]
      before(:each) do
        write_file(file_name, file_lines)
      end
      it 'returns the single array containing the trimmed line' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.parse()).to eq([
            ['line 1 of comment']
                                       ])
      end
    end

    context 'file contains adjacent single line comments' do
      file_lines = [
          'asdf // line 1 of comment  ',
          'qwer //    line 2 of comment    ',
          '// line 3 of comment  '
      ]
      before(:each) do
        write_file(file_name, file_lines)
      end
      it 'returns an array with one element: the array of trimmed lines' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.parse()).to eq([
                                           [
                                               'line 1 of comment',
                                               'line 2 of comment',
                                               'line 3 of comment'
                                           ]
                                       ])
      end
    end

    context 'file contains 2 sets of adjacent single line comments' do
      file_lines = [
          'asdf // line 1 of comment  ',
          'qwer //    line 2 of comment    ',
          '// line 3 of comment  ',
          'a line without a comment',
          'another line without a comment',
          'asdf // line 1 of comment 2',
          'asdf // line 2 of comment 2'
      ]
      before(:each) do
        write_file(file_name, file_lines)
      end
      it 'returns the 2 element array of both comments' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.parse).to eq([
            [
                'line 1 of comment',
                'line 2 of comment',
                'line 3 of comment'
            ],
            [
                'line 1 of comment 2',
                'line 2 of comment 2'
            ]
                                     ])
      end
    end

    context 'file contains a multi line comment on one line' do
      file_lines = [
          'asdf /* the comment */ qwerty'
      ]
      before(:each) do
        write_file(file_name, file_lines)
      end
      it 'returns the single array element containing the stripped line' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.parse).to eq([
            [
                'the comment'
            ]
                                     ])
      end
    end

    context 'file contains 2 adjacent multi line comments' do
      file_lines = [
          'asdf /* the comment */ qwerty',
          'asdf /* the second comment */ qwerty'
      ]
      before(:each) do
        write_file(file_name, file_lines)
      end
      it 'keeps the comments separate, returning them individualy' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.parse).to eq([
            [
                'the comment'
            ],
            [
                'the second comment'
            ]

                                     ])
      end
    end

    context 'when file contains a mixture of single line comments' do
      file_lines = [
          '// single line comment 1, line 1',
          '// single line comment 1, line 2',
          '// single line comment 1, line 3',
          'no comment line',
          'no comment line 2',
          '// single line comment, only one line',
          '/* multi line comment on one line */',
          '/* another multi line*/',
          '// single line comment 3, line 1',
          '// single line comment 3, line 2'
      ]
      before(:each) do
        write_file(file_name, file_lines)
      end
      it 'merges the single line comments together and keeps multi separate' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.parse).to eq([
            [
                'single line comment 1, line 1',
                'single line comment 1, line 2',
                'single line comment 1, line 3'
            ],
            [
                'single line comment, only one line'
            ],
            [
                'multi line comment on one line'
            ],
            [
                'another multi line'
            ],
            [
                'single line comment 3, line 1',
                'single line comment 3, line 2'
            ]
                                     ])
      end
    end

    context 'when file contains a single multi line comment over many lines' do
      file_lines = [
          'asdf /* line 1 of the comment',
          'line 2 of the comment',
          '      * line 3 of the comment   ',
          '      * line 4 of the comment */ qwer'

      ]
      before(:each) do
        write_file(file_name, file_lines)
      end
      it 'returns the one element array with each line as an element stripping initial stars' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.parse()).to eq([
            [
                'line 1 of the comment',
                'line 2 of the comment',
                'line 3 of the comment',
                'line 4 of the comment'
            ]
                                    ])
      end
    end

    context 'when the file contains multiple comments' do
      file_lines = [
          'not a comment line;',
          '/*',
          ' * multiline comment 1, line 1',
          ' * multiline comment 1, line 2',
          ' */',
          'not a comment line;',
          'not a comment line;',
          'asdf /* single line multi comment */ qwer',
          '/* multiline comment 2, line 1',
          ' * multiline comment 2, line 2',
          ' * multiline comment 2, line 3 */ qwer',
          'another not a comment line;',
          '// single line comment',
          'another not a comment line;',
          '// single line comment, line 1',
          '// single line comment, line 2',
          '// single line comment, line 3'
      ]
      before(:each) do
        write_file(file_name, file_lines)
      end
      it 'parses them by combining the above rules' do
        instance = Styleguide::JSStyleCommentParser.new(file_name)
        expect(instance.parse()).to eq([
            [
                '',
                'multiline comment 1, line 1',
                'multiline comment 1, line 2',
                ''
            ],
            [
                'single line multi comment'
            ],
            [
                'multiline comment 2, line 1',
                'multiline comment 2, line 2',
                'multiline comment 2, line 3'
            ],
            [
                'single line comment'
            ],
            [
                'single line comment, line 1',
                'single line comment, line 2',
                'single line comment, line 3',
            ]
                                       ])
      end
    end

  end

  after(:each) do
    File.delete(file_name) if File.exists?(file_name)
  end

end
