# frozen_string_literal: true

require 'base64'
require 'json'
require 'securerandom'
require 'net/http'
require 'websocket-client-simple'
require_relative 'client'
require_relative 'element'
require_relative 'user_agent'
require_relative 'actions/navigate'
require_relative 'actions/screenshot'
require_relative 'actions/dom'
require_relative 'native/mouse_controller'

module Chromate
  class Browser
    attr_reader :client

    include Actions::Navigate
    include Actions::Screenshot
    include Actions::Dom

    def initialize(options = {})
      @options        = options
      @chrome_path    = options[:chrome_path] || config.chrome_path
      @user_data_dir  = options[:user_data_dir] || config.user_data_dir || "/tmp/chromate_#{SecureRandom.hex}"
      @headless       = options.fetch(:headless, config.headless)
      @process        = nil
      @client         = nil

      trap('INT') do
        puts 'Stopping browser...'
        stop
        exit
      end

      trap('TERM') do
        puts 'Stopping browser...'
        stop
        exit
      end

      at_exit do
        stop
      end
    end

    def start
      args = [
        @chrome_path,
        "--user-data-dir=#{@user_data_dir}",
        "--lang=#{@options[:lang] || "fr-FR"}"
      ]
      args += config.args if config.args
      args += @options[:options][:args] if @options.dig(:options, :args)
      args << '--headless=new' if @headless
      args << "--user-agent=#{@options[:user_agent] || UserAgent.call}"
      args << "--exclude-switches=#{config.exclude_switches.join(",")}" if config.exclude_switches

      @client = Client.new(@options)
      args << "--remote-debugging-port=#{@client.port}"
      @process = spawn(*args, err: 'chrome_errors.log', out: 'chrome_output.log')
      sleep 2

      @client.start
      self
    end

    def stop
      Process.kill('TERM', @process) if @process
      @client&.close
    end

    private

    def config
      Chromate.configuration
    end
  end
end
