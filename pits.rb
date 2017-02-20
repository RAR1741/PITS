require 'sinatra'
require 'yaml'
require 'slim'

config = YAML.load(File.read("config.yaml"))

get "/" do
  slim :index
end

get "/config" do
  config.inspect
end
