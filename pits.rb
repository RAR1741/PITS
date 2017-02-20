require 'sinatra'
require 'yaml'
require 'slim'
require 'git'
require 'pry'

config = YAML.load(File.read('config.yaml'))

get '/' do
  slim :index
end

get '/logs' do
  # Change to the log dir
  Dir.chdir('../RA17_LogFileArchive')

  add_test_file
  git_commit
end

get '/config' do
  config.inspect
end

def add_test_file
  file = File.open(Dir.pwd + '/' + Time.now.to_i.to_s + '.txt', 'a')
  file.write('Some stuff and things...')
  file.close
end

def git_commit
  # Setup the Git object
  g = Git.open(Dir.pwd, log: Logger.new(STDOUT))

  # Add all files
  g.add(:all=>true)

  # Commit
  g.commit(Time.now.strftime('Files added on %m/%d/%Y at %I:%M%p'))

  # Push
  g.push
end
