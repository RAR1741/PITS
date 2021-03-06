# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/reloader'
require 'yaml'
require 'slim'
require 'pry'
require 'net/ftp'
require 'fileutils'
require 'sass'

# Main PITS class
class PITS < Sinatra::Base
  register Sinatra::Reloader

  def initialize
    super()
    @config = YAML.safe_load(File.read('config.yaml'))

    repo_path =
      File.join(
        Dir.pwd,
        @config['log_settings']['repo_path']
      )
    @git_command = "git '--git-dir=#{repo_path}/.git' '--work-tree=#{repo_path}'"

    @@pits_status = createJSON('Not Connected', 'good')
    # @config.inspect
  end

  get '/' do
    # status = 'test'
    slim :index
  end

  get '/status' do
    pp @@pits_status
  end

  get '/logs/:ip' do
    # add_test_file
    # git_commit

    @config['team_number'] = params['ip'].match(/-(.*)-/)[1]

    if @config['logs']['actually_get_logs']
      pull_logs params['ip']
      pp 'Done getting logs...'
    else
      pp 'Not doing the log thing...'
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
    content_type 'text/css', charset: 'utf-8'
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
    @@pits_status = createJSON('Connecting to Robot', 'good')
    Net::FTP.open(ip) do |ftp|
      # login and change directory
      ftp.login
      ftp.chdir((@config['log_settings']['ftp_path']).to_s)
      # Initial upload
      @@pits_status = createJSON('Uploading Config File', 'working')
      ftp.puttextfile 'config.txt', 'config.txt.bak'

      # Download the temp file
      @@pits_status = createJSON('Verifying Config File', 'working')
      ftp.gettextfile(
        'config.txt.bak',
        'config.txt.bak'
      )

      file_1_contents = File.open('config.txt', 'r').read
      file_2_contents = File.open('config.txt.bak', 'r').read

      # rename and overwrite old config
      if file_1_contents == file_2_contents
        ftp.rename('config.txt.bak', 'config.txt')
      end
    end
    @@pits_status = createJSON('Config Pushed', 'good')
  rescue SocketError => e
    if !e.message[/getaddrinfo/].nil?
      @@pits_status = createJSON('Robot Not Found', 'error')
      pp 'Robot not found...'
    else
      pp 'Some other socket thing was a no...'
      @@pits_status = createJSON('mumble mumble sockets', 'error')
      pp e
    end
  end

  def get_config(ip)
    contents = ''
    @@pits_status = createJSON('Connecting to Robot', 'good')
    Net::FTP.open(ip) do |ftp|
      remote_file = 'config.txt'
      local_file = 'config.txt'
      # login to ftp and change directory
      ftp.login
      ftp.chdir((@config['log_settings']['ftp_path']).to_s)
      # copy the file to local
      @@pits_status = createJSON('Downloading Config File', 'working')
      temp = ftp.gettextfile(
        remote_file,
        local_file
      )

      file = File.open(local_file, 'r')
      contents = file.read
      file.close
    end
    @@pits_status = createJSON('Config Pulled', 'good')
    contents
  rescue SocketError => e
    if !e.message[/getaddrinfo/].nil?
      @@pits_status = createJSON('Robot Not Found', 'error')
      pp 'Robot not found...'
    else
      pp 'Some other socket thing was a no...'
      @@pits_status = createJSON('mumble mumble sockets', 'error')
      pp e
    end
  end

  def git_update
    system("#{@git_command} checkout master 2>&1")
    system("#{@git_command} pull  2>&1")
  end

  def git_commit
    # Add all files
    system("#{@git_command} add '--all' '--' '.'  2>&1")

    # Commit
    message = Time.now.strftime('Files added on %m/%d/%Y at %I:%M%p')
    system("#{@git_command} commit '--message=#{message}'  2>&1")

    # Push
    system("#{@git_command} push 'origin' 'master'  2>&1")
  end

  def pull_logs(ip)
    pp 'Starting to pull logs...'

    log_dir = @config['log_settings']['local_path'] + @config['team_number'] + '/'

    FileUtils.mkdir_p log_dir

    @@pits_status = createJSON('Connecting to Robot', 'good')

    Net::FTP.open(ip) do |ftp|
      # login and change directory
      ftp.login

      chdir_path =
        @config['log_settings']['ftp_path'] +
        @config['log_settings']['remote_path']

      ftp.chdir(chdir_path.to_s)

      git_update

      @@pits_status = createJSON('Pulling Log Files', 'working')

      pulled_file = false

      ftp.nlst.each do |file|
        pp "Pulling file: #{file}"

        # Make the local folder, if needed
        log_date = file.match(/^.+?-(.+?)_/)[1]
        date_dir = log_dir + log_date + '/'
        FileUtils.mkdir_p date_dir

        # Move the file local
        ftp.gettextfile(
          file,
          date_dir + file
        )

        ftp.delete(file) if @config['logs']['delete_logs']

        pulled_file = true
      end

      @@pits_status = createJSON('Commiting Log Files', 'working')
      git_commit if pulled_file
      @@pits_status = createJSON('Logs Pulled', 'good')
    end
    pp 'Finished with no errors...'
  rescue SocketError => e
    if !e.message[/getaddrinfo/].nil?
      @@pits_status = createJSON('Robot Not Found', 'error')
      pp 'Robot not found...'
    else
      pp 'Some other socket thing was a no'
      @@pits_status = createJSON('mumble mumble sockets', 'error')
      pp e
    end
  end

  def createJSON(status, warn)
    "{\"pits_status\":\"#{status}\",\"status\":\"#{warn}\"}"
  end
end

PITS.run! if __FILE__ == $PROGRAM_NAME
