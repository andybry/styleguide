require 'sprockets'
environment = Sprockets::Environment.new
environment.append_path('javascripts')
environment.append_path('stylesheets')
environment.append_path('images')
map '/assets' do
  run environment
end
map '/' do 
  run Proc.new {
    [
      200,
      {},
      ['ok']
    ]
  }
end
# run Rack::Directory.new('.')