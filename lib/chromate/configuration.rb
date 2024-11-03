# frozen_string_literal: true

require_relative 'helpers'
require_relative 'c_logger'

module Chromate
  class Configuration
    include Helpers
    attr_accessor :user_data_dir, :headless, :xfvb, :native_control, :args, :headless_args, :xfvb_args, :exclude_switches, :proxy,
                  :disable_features

    def initialize
      @user_data_dir      = File.expand_path('~/.config/google-chrome/Default')
      @headless           = true
      @xfvb               = false
      @native_control     = false
      @proxy              = nil
      @args               = [
        '--no-first-run',
        '--no-default-browser-check',
        '--disable-blink-features=AutomationControlled',
        '--disable-extensions',
        '--disable-infobars',
        '--no-sandbox',
        '--disable-popup-blocking',
        '--ignore-certificate-errors',
        '--disable-gpu',
        '--disable-dev-shm-usage',
        '--window-size=1920,1080',
        '--hide-crash-restore-bubble'
      ]
      @args << '--use-angle=metal' if mac?
      @headless_args = [
        '--headless=new',
        '--window-position=2400,2400'
      ]
      @xfvb_args = [
        '--window-position=0,0'
      ]
      @disable_features = %w[
        Translate
        OptimizationHints
        MediaRouter
        DialMediaRouteProvider
        CalculateNativeWinOcclusion
        InterestFeedContentSuggestions
        CertificateTransparencyComponentUpdater
        AutofillServerCommunication
        PrivacySandboxSettings4
        AutomationControlled
      ]
      @exclude_switches = ['enable-automation']
    end

    def self.config
      @config ||= Configuration.new
    end

    def self.configure
      yield(config)
    end

    def config
      self.class.config
    end

    def chrome_path
      return ENV['CHROME_BIN'] if ENV['CHROME_BIN']

      if mac?
        '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
      else
        '/usr/bin/google-chrome'
      end
    end

    def generate_arguments(headless: @headless, xfvb: @xfvb, proxy: @proxy, disable_features: @disable_features, **_args)
      dynamic_args = []

      dynamic_args += @headless_args  if headless
      dynamic_args += @xfvb_args      if xfvb
      dynamic_args << "--proxy-server=#{@proxy[:host]}:#{@proxy[:port]}"  if proxy && proxy[:host] && proxy[:port]
      dynamic_args << "--disable-features=#{@disable_features.join(",")}" unless disable_features.empty?

      @args + dynamic_args
    end

    def options
      {
        chrome_path: chrome_path,
        user_data_dir: @user_data_dir,
        headless: @headless,
        xfvb: @xfvb,
        native_control: @native_control,
        args: @args,
        headless_args: @headless_args,
        xfvb_args: @xfvb_args,
        exclude_switches: @exclude_switches,
        proxy: @proxy,
        disable_features: @disable_features
      }
    end
  end
end
