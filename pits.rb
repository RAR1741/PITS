require 'sinatra'
require 'yaml'
config = YAML.load(File.read("config.yaml"))
get "/config" do
  config.inspect
end
