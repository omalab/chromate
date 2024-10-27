# frozen_string_literal: true

require_relative 'c_logger'

module Chromate
  class Configuration
    attr_accessor :chrome_path, :user_data_dir, :headless, :args, :exclude_switches

    def initialize
      @chrome_path    = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
      @user_data_dir  = '/Users/mariedavid/.config/google-chrome/Default'
      @headless       = true
      @args           = [
        '--no-first-run',
        '--no-default-browser-check',
        '--disable-blink-features=AutomationControlled',
        '--disable-extensions',
        '--disable-infobars',
        '--no-sandbox',
        '--disable-dev-shm-usage',
        '--disable-gpu',
        '--use-angle=metal',
        '--disable-features=IsolateOrigins,site-per-process',
        '--disable-popup-blocking',
        '--ignore-certificate-errors',
        '--window-size=1920,1080',
        '--window-position=0,0'
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
  end
end
