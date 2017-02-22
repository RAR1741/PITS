# frozen_string_literal: true

require 'sinatra/base'
require 'yaml'
require 'slim'
require 'git'
require 'pry'
require 'net/ssh'
require 'net/scp'
require 'fileutils'

# Main PITS class
class PITS < Sinatra::Base
  def initialize
    super()
    @config = YAML.load(File.read('config.yaml'))
  end

  get '/' do
    slim :index
  end

  get '/logs/:ip' do
    # add_test_file
    # git_commit

    @config['team_number'] = params['ip'].match(/-(.*)-/)[1]

    pull_logs params['ip']
    'DONE'
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

  def pull_logs(ip)
    pp 'Doing a thing...'

    log_dir =
      @config['log_settings']['local_path'] + @config['team_number'] + '/'

    FileUtils.mkdir_p log_dir

    Net::SSH.start(ip, @config['robot']['username'], :password => '') do |ssh|
      lookup_command = "ls -At #{@config['log_settings']['remote_path']}*.csv"
      file_string = ssh.exec!(lookup_command)
      files = file_string.split("\n")

      ssh.exec!('mkdir oldLogs')

      # local_files = []

      files.each do |file|
        pp file

        # Make the local folder, if needed
        log_date = file.match(/^.+?-(.+?)_/)[1]
        date_dir = log_dir + log_date + '/'
        FileUtils.mkdir_p date_dir

        temp = ssh.scp.download(
          file,
          date_dir
        )

        temp.wait

        move_command = 'mv ' + file + ' oldLogs/'
        # TODO: ADD THIS BACK
        # ssh.exec!(move_command)

        # local_files.push(temp)
      end

      git_commit unless files.length.zero?
      # local_files.each(&:wait)
    end
    pp 'Finished with no errors...'
  rescue SocketError => error
    if !error.message[/getaddrinfo/].nil?
      pp 'Robot not found...'
    else
      pp 'Some other socket thing was a no'
      pp error
    end
  rescue Net::SCP::Error => error
    pp 'SCP was no...'
    pp error
  rescue StandardError => error
    pp 'Something else was no...'
    pp error
    # @error = 'Error: robot not found.   :('
  end
end

PITS.run! if __FILE__ == $PROGRAM_NAME
