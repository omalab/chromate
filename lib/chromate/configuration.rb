# frozen_string_literal: true

require_relative 'c_logger'

module Chromate
  class Configuration
    attr_accessor :chrome_path, :user_data_dir, :headless, :args, :exclude_switches, :proxy, :disable_features

    def initialize
      @chrome_path    = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
      @user_data_dir  = '/Users/mariedavid/.config/google-chrome/Default'
      @headless       = true
      @proxy          = nil
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
        '--disable-popup-blocking',
        '--ignore-certificate-errors',
        '--window-size=1920,1080',
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
      generate_arguments
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

    def generate_arguments
      # Appliquer les configurations dynamiques pour le mode headless et les proxys
      dynamic_args = []

      # Configurer le mode headless
      dynamic_args << "--headless=#{@headless}" unless @headless == false

      # Configurer le serveur proxy s'il est défini
      dynamic_args << "--proxy-server=#{@proxy[:host]}:#{@proxy[:port]}" if @proxy&.dig(:host) && @proxy[:port]

      # Construire le flag disable-features avec les fonctionnalités à désactiver
      dynamic_args << "--disable-features=#{@disable_features.join(",")}" unless @disable_features.empty?

      # Ajouter les arguments exclus uniquement s'ils ne sont pas filtrés
      all_args = @args + dynamic_args
      all_args.reject do |arg|
        @exclude_switches.any? { |exclude| arg.include?(exclude) }
      end
    end
  end
end
