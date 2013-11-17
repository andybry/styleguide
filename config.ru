require 'sprockets'
require 'tilt'
require 'rack'
require 'find'

$gem_directory =  File.dirname(__FILE__)

environment = Sprockets::Environment.new
environment.append_path('javascripts')
environment.append_path('stylesheets')
environment.append_path('images')
environment.append_path('specs')

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
      Find.find('specs') do |path|
        if(::File.file?(path))
          spec_files << (path.gsub(/^specs\//, ''))
        end
      end
      jasmine_template = Tilt.new("#{$gem_directory}/jasmine-1.3.1/SpecRunner.html.erb")
      output = jasmine_template.render(Object.new, {
        spec_files: spec_files
      })
      [
        200, 
        {},
        [output]
      ]
    else
      super
    end
  end
end

map '/jasmine' do
  run JasmineApplication.new("#{$gem_directory}/jasmine-1.3.1")
end

map '/' do 
  run Proc.new {
    layout_template_file = "#{$gem_directory}/layout.htm.erb"
    layout_template = Tilt.new(layout_template_file)
    stylesheets = 
    output = layout_template.render(Object.new, {}) do
      '<h1>Andrew Ralph Bryant</h1>'
    end
    [
      200,
      {},
      [output]
    ]
  }
end
