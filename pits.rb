# frozen_string_literal: true

require 'sinatra/base'
require 'yaml'
require 'slim'
require 'git'
require 'pry'
require 'net/ssh'
require 'net/scp'

# Main PITS class
class PITS < Sinatra::Base
  def initialize
    super()
    @config = YAML.load(File.read('config.yaml'))
  end

  get '/' do
    slim :index
  end

  get '/logs' do
    # add_test_file
    # git_commit
    pull_logs
    "DONE"
  end

  get '/config' do
    @config.inspect
  end

  def add_test_file
    file_path =
      File.join(
        Dir.pwd,
        @config['log_settings']['repo_path'], Time.now.to_i.to_s + '.txt'
      )

    file = File.open(file_path, 'a')
    file.write('Some stuff and things...')
    file.close
  end

  def git_commit
    repo_path =
      File.join(
        Dir.pwd,
        @config['log_settings']['repo_path']
      )

    # Setup the Git object
    g = Git.open(repo_path, log: Logger.new(STDOUT))

    # Add all files
    g.add(all: true)

    # Commit
    g.commit(Time.now.strftime('Files added on %m/%d/%Y at %I:%M%p'))

    # Push
    g.push
  rescue GitExecuteError => error
    pp 'Git error:'
    pp error
  end

  def pull_logs
    pp 'Doing a thing...'

    Net::SSH.start(@config['robot']['ip'], @config['robot']['username'], :password => "") do |ssh|
      file_string = ssh.exec!('ls -At *.csv')
      files = file_string.split("\n")

      ssh.exec!('mkdir oldLogs')

      # local_files = []

      files.each do |file|
        pp file
        temp = ssh.scp.download(
          file,
          @config['log_settings']['local_path']
        )

        temp.wait

        move_command = 'mv ' + file + ' oldLogs/'
        ssh.exec!(move_command)

        # local_files.push(temp)
      end

      git_commit unless files.length.zero?
      # local_files.each(&:wait)
    end
    pp 'Done a thing...'
  rescue SocketError => error
    pp 'Sockets was no...'
    pp error
  rescue Net::SCP::Error => error
    pp 'SCP was no...'
    pp error
  rescue StandardError => error
    pp 'Something was no...'
    pp error
    # @error = 'Error: robot not found.   :('
  end
end

PITS.run! if __FILE__ == $PROGRAM_NAME
