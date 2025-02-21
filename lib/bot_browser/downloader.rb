# frozen_string_literal: true

# Special thanks to the BotBrowser project (https://github.com/MiddleSchoolStudent/BotBrowser)
# for providing an amazing foundation for browser automation and making this work possible.

require 'chromate/binary'

module BotBrowser
  class Downloader
    class << self
      def download(version = nil, profile = nil, platform = :mac)
        version ||= versions.keys.first
        profile ||= profiles[version].keys.first
        version       = version.to_sym
        binary_path   = download_file(versions[version][platform], "/tmp/botbrowser_#{version}_#{platform}.dmg")
        profile_path  = download_file(profiles[version][profile], "/tmp/botbrowser_#{version}_#{platform}.json")

        [binary_path, profile_path]
      end

      def download_file(url, path)
        Chromate::CLogger.log("Downloading #{url} to #{path}")
        Chromate::Binary.run('curl', ['-L', url, '-o', path])

        path
      end

      def versions
        {
          v132: {
            mac: 'https://github.com/MiddleSchoolStudent/BotBrowser/releases/download/20250204/botbrowser_132.0.6834.84_mac_arm64.dmg',
            linux: 'https://github.com/MiddleSchoolStudent/BotBrowser/releases/download/20250204/botbrowser_132.0.6834.84_amd64.deb',
            windows: 'https://github.com/MiddleSchoolStudent/BotBrowser/releases/download/20250204/botbrowser_132.0.6834.84_win_x86_64.7z'
          },
          v130: {
            mac: 'https://github.com/MiddleSchoolStudent/BotBrowser/releases/download/v130/botbrowser_130.0.6723.92_mac_arm64.dmg',
            linux: 'https://github.com/MiddleSchoolStudent/BotBrowser/releases/download/v130/botbrowser_130.0.6723.117_amd64.deb',
            windows: 'https://github.com/MiddleSchoolStudent/BotBrowser/releases/download/v130/botbrowser_130.0.6723.117_win_x86_64.7z'
          }
        }
      end

      def profiles
        {
          v128: {
            mac: 'https://raw.githubusercontent.com/MiddleSchoolStudent/BotBrowser/refs/heads/main/profiles/v128/chrome128_mac_arm64.enc',
            win: 'https://raw.githubusercontent.com/MiddleSchoolStudent/BotBrowser/refs/heads/main/profiles/v128/chrome128_win10_x86_64.enc'
          },
          v129: {
            mac: 'https://raw.githubusercontent.com/MiddleSchoolStudent/BotBrowser/refs/heads/main/profiles/v129/chrome129_mac_arm64.enc'
          },
          v130: {
            mac: 'https://raw.githubusercontent.com/MiddleSchoolStudent/BotBrowser/refs/heads/main/profiles/v130/chrome130_mac_arm64.enc',
            iphone: 'https://raw.githubusercontent.com/MiddleSchoolStudent/BotBrowser/refs/heads/main/profiles/v130/chrome130_iphone.enc'
          },
          v132: {
            mac: 'https://github.com/MiddleSchoolStudent/BotBrowser/blob/main/profiles/v132/chrome132_mac_arm64.enc',
            win: 'https://github.com/MiddleSchoolStudent/BotBrowser/blob/main/profiles/v132/chrome132_win10_x86_64.enc'
          }
        }
      end
    end
  end
end
