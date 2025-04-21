# frozen_string_literal: true

require 'yaml'
require 'chromate/helpers'
require 'chromate/c_logger'
require 'bot_browser/downloader'

module BotBrowser
  class Installer
    class NotInstalledError < StandardError; end
    class << self
      include Chromate::Helpers

      def install(version = nil)
        create_config_dir
        binary_path, profile_path = Downloader.download(version, nil, platform)
        bot_browser_path          = install_binary(binary_path)
        bot_browser_profile_path  = install_profile(profile_path)

        write_config(bot_browser_path, bot_browser_profile_path)
      end

      def config_dir
        "#{Dir.home}/.botbrowser"
      end

      def installed?
        File.exist?("#{config_dir}/config.yml")
      end

      def uninstall
        raise NotInstalledError, 'BotBrowser is not installed' unless installed?

        config = YAML.load_file("#{config_dir}/config.yml")
        Chromate::CLogger.log("Uninstalling binary at #{config["bot_browser_path"]}")
        FileUtils.rm_rf(config['bot_browser_path'])
        Chromate::CLogger.log("Uninstalling profile at #{config["profile"]}")
        FileUtils.rm_rf(config['profile'])
        FileUtils.rm_rf(config_dir)
        Chromate::CLogger.log('Uninstalled')
      end

      private

      def platform
        if mac?
          :mac
        elsif linux?
          :linux
        elsif windows?
          :windows
        else
          raise 'Unsupported platform'
        end
      end

      def install_binary(binary_path)
        Chromate::CLogger.log("Installing binary from #{binary_path}")
        return install_binary_mac(binary_path) if mac?
        return install_binary_linux(binary_path) if linux?
        return install_binary_windows(binary_path) if windows?

        raise 'Unsupported platform'
      end

      def create_config_dir
        Chromate::CLogger.log("Creating config directory at #{config_dir}")
        FileUtils.mkdir_p(config_dir)
      end

      def install_profile(profile_path)
        Chromate::CLogger.log("Installing profile from #{profile_path}")
        `cp #{profile_path} #{config_dir}/`

        "#{config_dir}/#{File.basename(profile_path)}"
      end

      def install_binary_mac(binary_path)
        Chromate::Binary.run('hdiutil', ['attach', binary_path])
        Chromate::Binary.run('cp', ['-r', '/Volumes/Chromium/Chromium.app', '/Applications/'])
        Chromate::Binary.run('hdiutil', ['detach', '/Volumes/Chromium'])
        Chromate::Binary.run('xattr', ['-rd', 'com.apple.quarantine', '/Applications/Chromium.app'])
        Chromate::Binary.run('codesign', ['--force', '--deep', '--sign', '-', '/Applications/Chromium.app'], need_success: false)

        '/Applications/Chromium.app/Contents/MacOS/Chromium'
      end

      def install_binary_linux(binary_path)
        Chromate::Binary.run('dpkg', ['-i', binary_path])
        Chromate::Binary.run('apt-get', ['install', '-f'])

        '/usr/bin/chromium-browser'
      end

      def install_binary_windows(binary_path)
        Chromate::Binary.run('7z', ['x', binary_path])

        'chromium.exe'
      end

      def write_config(bot_browser_path, bot_browser_profile_path)
        Chromate::CLogger.log("Writing config to #{config_dir}/config.yml")
        File.write(File.expand_path("#{config_dir}/config.yml"), <<~YAML)
          ---
          bot_browser_path: #{bot_browser_path}
          profile: #{bot_browser_profile_path}
        YAML
      end
    end
  end
end
