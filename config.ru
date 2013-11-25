require 'sprockets'
require 'tilt'
require 'rack'
require 'find'
require 'rack/livereload'
require 'styleguide'

###############################################################################
# Styleguide calculations
###############################################################################

module StyleguideCalculator
  class << self

    def calculate_styleguide()
      # retrieve comments from js and scss files
      comments_so_far = []
      files = []

      Find.find('.') do |path|
        if(::File.file?(path) and path.match(/\.(scss|js)(\.)?/))
          files << path if(not path.match(/\.swp$/))
        end
      end

      files.each do |file|
        comments_parser = Styleguide::JSStyleCommentParser.new(file)
        comments = comments_parser.parse()
        comments_so_far.concat(comments)
      end

      styleguide_sections = {}
      comments_so_far.each do |comment|
        if(match = comment[0].match(/^Styleguide (.*)$/))
          section = {}
          name = match[1]
          section[:name] = name
          current_key = nil
          current_value = ''
          comment[1..-1].each do |line|
            if(match = line.match(/^(\w+)::\s*$/)) 
              section[current_key] = current_value if current_key
              current_value = ''
              current_key = match[1].to_sym
            else
              current_value = current_value + line + "\n"
            end
          end
          section[current_key] = current_value if current_key
          styleguide_sections[name] = section
        end
      end

      styleguide_sections
    end

  end
end

###############################################################################
# Rack configuration
###############################################################################

$gem_directory =  File.dirname(__FILE__)

environment = Sprockets::Environment.new
environment.append_path('javascripts')
environment.append_path('stylesheets')
environment.append_path('images')
environment.append_path('spec')

map '/assets' do
  run environment
end

class JasmineApplication < Rack::Directory
  def call(env)
    path_info = env['PATH_INFO']
    if(path_info == '')
      [
        301,
        {
          Location: '/jasmine/'
        },
        []
      ]
    elsif(path_info == '/')
      spec_files = []
      Find.find('spec') do |path|
        if(::File.file?(path))
          spec_files << (path.gsub(/^spec\//, ''))
        end
      end
      jasmine_template = Tilt.new("#{$gem_directory}/jasmine-1.3.1/SpecRunner.html.erb")
      output = jasmine_template.render(Object.new, {
        spec_files: spec_files
      })
      [
        200, 
        {'Content-Type' => 'text/html'},
        [output]
      ]
    else
      super
    end
  end
end

map '/jasmine' do
  use Rack::LiveReload
  run JasmineApplication.new("#{$gem_directory}/jasmine-1.3.1")
end

map '/' do
  use Rack::LiveReload
  run Proc.new { |env|
    styleguide = StyleguideCalculator::calculate_styleguide
    path_info = env['PATH_INFO']
    possible_section = Rack::Utils.unescape(path_info[1..-1])
    layout_template_file = "#{$gem_directory}/layout.htm.erb"
    layout_template = Tilt.new(layout_template_file)
    output = ''
    if(section = styleguide[possible_section])
      section_template_file = "#{$gem_directory}/section.htm.erb"
      section_template = Tilt.new(section_template_file)
      output = layout_template.render(Object.new, {}) do
        section_template.render(Object.new, {
          section: section
        })
      end
    else
      index_template_file = "#{$gem_directory}/index.htm.erb"
      index_template = Tilt.new(index_template_file)
      output = layout_template.render(Object.new, {}) do
        index_template.render(Object.new, {
          styleguide: styleguide
        })
      end
    end
      [
        200,
        {'Content-Type' => 'text/html'},
        [output]
      ]
  }
end
