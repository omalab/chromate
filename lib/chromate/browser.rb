# frozen_string_literal: true

require 'base64'
require 'json'
require 'securerandom'
require 'net/http'
require 'websocket-client-simple'
require_relative 'helpers'
require_relative 'binary'
require_relative 'client'
require_relative 'hardwares'
require_relative 'element'
require_relative 'elements/select'
require_relative 'elements/option'
require_relative 'elements/tags'
require_relative 'elements/radio'
require_relative 'elements/checkbox'
require_relative 'user_agent'
require_relative 'actions/navigate'
require_relative 'actions/screenshot'
require_relative 'actions/dom'
require_relative 'actions/stealth'

module Chromate
  class Browser
    attr_reader :client, :options

    include Helpers
    include Actions::Navigate
    include Actions::Screenshot
    include Actions::Dom
    include Actions::Stealth

    # @param options [Hash] Options for the browser
    # @option options [String] :chrome_path The path to the Chrome executable
    # @option options [String] :user_data_dir The path to the user data directory
    # @option options [Boolean] :headless Whether to run Chrome in headless mode
    # @option options [Boolean] :xfvb Whether to run Chrome in Xvfb
    # @option options [Boolean] :native_control Whether to use native controls
    # @option options [Boolean] :record Whether to record the screen
    def initialize(options = {})
      @options        = config.options.merge(options)
      @chrome_path    = @options.fetch(:chrome_path)
      @user_data_dir  = @options.fetch(:user_data_dir, "/tmp/chromate_#{SecureRandom.hex}")
      @headless       = @options.fetch(:headless)
      @xfvb           = @options.fetch(:xfvb)
      @native_control = @options.fetch(:native_control)
      @record         = @options.fetch(:record, false)
      @binary         = nil
      @record_process = nil
      @client         = nil
      @args           = []

      trap('INT') { stop_and_exit }
      trap('TERM') { stop_and_exit }
    end

    # @return [self]
    def start
      build_args
      @client = Client.new(self)
      @args << "--remote-debugging-port=#{@client.port}"

      if @xfvb
        if ENV['DISPLAY'].nil?
          ENV['DISPLAY'] = ':0'   if mac? # XQuartz generally uses :0 on Mac
          ENV['DISPLAY'] = ':99'  if linux? # Xvfb generally uses :99 on Linux
        end
        @args << "--display=#{ENV.fetch("DISPLAY", nil)}"
      end

      Hardwares::MouseController.reset_mouse_position
      Chromate::CLogger.log("Starting browser with args: #{@args}", level: :debug)
      @binary = Binary.new(@chrome_path, @args)

      @binary.start
      @client.start

      start_video_recording if @record

      patch if config.patch?

      update_config!

      self
    end

    # @return [Boolean]
    def started?
      @binary&.started? || false
    end

    # @return [self]
    def stop
      stop_process(@record_process) if @record_process
      @binary.stop                  if started?
      @client&.stop

      @binary = nil
      @record_process = nil

      self
    end

    # @return [Boolean]
    def native_control?
      @native_control
    end

    private

    # @return [Integer]
    def start_video_recording
      outname = @record.is_a?(String) ? @record : "output_video_#{Time.now.to_i}.mp4"
      outfile = File.join(Dir.pwd, outname).to_s
      args = [
        '-f',
        'x11grab',
        '-draw_mouse',
        '1',
        '-r',
        '30',
        '-s',
        '1920x1080',
        '-i',
        ENV.fetch('DISPLAY'),
        '-c:v',
        'libx264',
        '-preset',
        'ultrafast',
        '-pix_fmt',
        'yuv420p',
        '-y',
        outfile
      ]
      binary = Binary.new('ffmpeg', args)
      binary.start
      @record_process = binary.pid
    end

    # @return [Array<String>]
    def build_args
      exclude_switches = config.exclude_switches || []
      exclude_switches += @options[:exclude_switches] if @options[:exclude_switches]
      @user_agent = @options[:user_agent] || UserAgent.call

      @args = if @options.dig(:options, :args)
                @options[:options][:args]
              else
                config.generate_arguments(**@options)
              end

      @args << "--user-agent=#{@user_agent}"
      @args << "--exclude-switches=#{exclude_switches.join(",")}" if exclude_switches.any?
      @args << "--user-data-dir=#{@user_data_dir}"

      @args
    end

    def set_hardwares
      config.mouse_controller = Hardwares.mouse(client: @client, element: nil)
      config.keyboard_controller = Hardwares.keyboard(client: @client, element: nil)
    end

    # @return [void]
    def update_config!
      config.args = @args
      config.user_data_dir = @user_data_dir
      config.headless = @headless
      config.xfvb = @xfvb
      config.native_control = @native_control

      set_hardwares
    end

    # @param pid [Integer] PID of the process to stop
    # @param timeout [Integer] Timeout in seconds to wait for the process to stop
    # @return [void]
    def stop_process(pid, timeout: 5)
      return unless pid

      # Send SIGINT to the process to stop it gracefully
      Process.kill('INT', pid)
      begin
        Timeout.timeout(timeout) do
          Process.wait(pid)
        end
      rescue Timeout::Error
        # If the process does not stop gracefully, send SIGKILL
        CLogger.log("Process #{pid} did not stop gracefully. Sending SIGKILL...", level: :debug)
        Process.kill('KILL', pid)
      end
    rescue Errno::ESRCH
      # The process has already stopped
    end

    # @return [void]
    def stop_and_exit
      CLogger.log('Stopping browser...', level: :debug)
      stop
      exit
    end

    # @return [Chromate::Configuration]
    def config
      Chromate.configuration
    end
  end
end
