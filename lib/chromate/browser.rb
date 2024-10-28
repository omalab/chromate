# frozen_string_literal: true

require 'base64'
require 'json'
require 'securerandom'
require 'net/http'
require 'websocket-client-simple'
require_relative 'helpers'
require_relative 'client'
require_relative 'element'
require_relative 'elements/select'
require_relative 'user_agent'
require_relative 'actions/navigate'
require_relative 'actions/screenshot'
require_relative 'actions/dom'
require_relative 'native/mouse_controller'

module Chromate
  class Browser
    attr_reader :client

    include Helpers
    include Actions::Navigate
    include Actions::Screenshot
    include Actions::Dom

    def initialize(options = {})
      @options        = options
      @chrome_path    = options[:chrome_path] || config.chrome_path
      @user_data_dir  = options[:user_data_dir] || config.user_data_dir || "/tmp/chromate_#{SecureRandom.hex}"
      @headless       = options.fetch(:headless, config.headless)
      @record         = options.fetch(:record, false)
      @xfvb           = options.fetch(:xfvb, config.xfvb)
      @process        = nil
      @xfvb_process   = nil
      @client         = nil

      trap('INT') { stop_and_exit }
      trap('TERM') { stop_and_exit }

      at_exit { stop }
    end

    def start
      start_x_server if @xfvb && (linux? || mac?)
      record_session if @record && @xfvb

      @client = Client.new(@options)
      args = [
        @chrome_path,
        "--user-data-dir=#{@user_data_dir}",
        "--lang=#{@options[:lang] || "fr-FR"}"
      ]
      exclude_switches = config.exclude_switches || []
      exclude_switches += @options[:exclude_switches] if @options[:exclude_switches]
      args += config.generate_arguments(**@options)
      args += @options[:options][:args] if @options.dig(:options, :args)
      args << "--user-agent=#{@options[:user_agent] || UserAgent.call}"
      args << "--exclude-switches=#{exclude_switches.join(",")}" if exclude_switches.any?
      args << "--remote-debugging-port=#{@client.port}"

      # Ajouter l'affichage X11 si un serveur X est démarré
      if @xfvb_process || mac?
        ENV['DISPLAY'] = ':0' if mac? # XQuartz utilise généralement :0 sur macOS
        args << "--display=#{ENV.fetch("DISPLAY", nil)}"
      end

      @process = spawn(*args, err: 'chrome_errors.log', out: 'chrome_output.log')
      sleep 2

      @client.start
      self
    end

    def stop
      Process.kill('TERM', @process)        if @process
      Process.kill('TERM', @xfvb_process)   if @xfvb_process
      Process.kill('TERM', @recording)      if @recording
      @client&.close
    end

    private

    def start_x_server
      if linux?
        # Start Xvfb on display :99
        @xfvb_process = spawn('Xvfb :99 -screen 0 1920x1080x24 &')
        ENV['DISPLAY'] = ':99'
        sleep 1 # Wait for Xvfb to start
      elsif mac?
        # Start XQuartz
        system('open -a XQuartz')
        ENV['DISPLAY'] = ':0'
        sleep 2 # Wait for XQuartz to start
      end
    end

    def record_session
      @recording = spawn('ffmpeg', '-f', 'avfoundation', '-i', '1:0', '-r', '30', '-t', '00:00:10', 'output.mov')
    end

    def stop_and_exit
      puts 'Stopping browser...'
      stop
      exit
    end

    def config
      Chromate.configuration
    end
  end
end
