require 'sprockets'
require 'tilt'

gem_directory =  File.dirname(__FILE__)
environment = Sprockets::Environment.new
environment.append_path('javascripts')
environment.append_path('stylesheets')
environment.append_path('images')
map '/assets' do
  run environment
end
map '/' do 
  run Proc.new {
    layout_template_file = "#{gem_directory}/index.htm.erb"
    layout_template = Tilt.new(layout_template_file)
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
# run Rack::Directory.new('.')