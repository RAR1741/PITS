# frozen_string_literal: true

require 'sinatra/base'
require 'yaml'
require 'slim'
require 'git'
require 'pry'
require 'net/ssh'
require 'net/scp'
require 'fileutils'
require 'sass'

# Main PITS class
class PITS < Sinatra::Base
  
  def initialize
    super()
    @config = YAML.load(File.read('config.yaml'))
    status = 'Not Connected'
    # @config.inspect
  end

  get '/' do
    #status = 'test'
    slim :index
  end
  
  get '/status' do
    pp status
  end

  get '/logs/:ip' do
    # add_test_file
    # git_commit

    @config['team_number'] = params['ip'].match(/-(.*)-/)[1]

    if @config['logs']['actually_get_logs']
      pull_logs params['ip']
      'DONE'
    else
      'Not doing the log thing...'
    end
  end

  get '/config/get/:ip' do
    get_config params['ip']
  end

  post '/config/put/:ip' do
    contents = request.body.read

    file = File.open('config.txt', 'w')
    file.write(contents)
    file.close

    put_config params['ip']
  end

  get '/css/*.css' do
    content_type 'text/css', :charset => 'utf-8'
    filename = params[:splat].first
    scss filename.to_sym, views: "#{settings.root}/stylesheets"
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

  def put_config(ip)
    Net::SSH.start(ip, @config['robot']['username'], :password => '') do |ssh|
      # Initial upload
      ssh.scp.upload! 'config.txt', 'config.txt.bak'

      # Download the temp file
      temp = ssh.scp.download(
        'config.txt.bak',
        'config.txt.bak'
      )

      temp.wait

      file_1_contents = File.open('config.txt', 'r').read
      file_2_contents = File.open('config.txt.bak', 'r').read

      if file_1_contents == file_2_contents
        # Rename the new remote file
        rename_command = 'mv config.txt.bak config.txt'
        ssh.exec!(rename_command)
      end
    end
  end

  def get_config(ip)
    contents = ''
    Net::SSH.start(ip, @config['robot']['username'], :password => '') do |ssh|
      remote_file = 'config.txt'
      local_file = 'config.txt'

      temp = ssh.scp.download(
        remote_file,
        local_file
      )

      temp.wait

      file = File.open(local_file, 'r')
      contents = file.read
      file.close
    end

    contents
  rescue SocketError => error
    if !error.message[/getaddrinfo/].nil?
      pp 'Robot not found...'
    else
      pp 'Some other socket thing was a no...'
      pp error
    end
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
      status = 'Pulling Log Files'

      files.each do |file|
        pp "Pulling file: #{file}"

        # Make the local folder, if needed
        log_date = file.match(/^.+?-(.+?)_/)[1]
        date_dir = log_dir + log_date + '/'
        FileUtils.mkdir_p date_dir

        temp = ssh.scp.download(
          file,
          date_dir
        )

        temp.wait

        if @config['logs']['delete_logs']
          delete_command = 'rm ' + file
          ssh.exec!(delete_command)
        end

        # local_files.push(temp)
      end
      status = 'Commiting Log Files'
      git_commit unless files.length.zero?
      status = 'Not Connected'
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
  
  def status=(val)
    @@status = val
  end
  
  def status
    @@status
  end
  
end

PITS.run! if __FILE__ == $PROGRAM_NAME
