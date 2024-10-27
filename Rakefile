# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[spec rubocop]

require_relative "lib/chromate"

namespace :chromate do
  namespace :test do
    task :pixelscan do
      browser = Chromate::Browser.new
      browser.start
      browser.navigate_to("https://pixelscan.net")
      sleep 10
      browser.screenshot_to_file("results/pixelscan.png")
      browser.stop
    end

    task :brotector do
      browser = Chromate::Browser.new
      browser.start
      browser.navigate_to("https://kaliiiiiiiiii.github.io/brotector?crash=false")
      sleep 2
      browser.click_element("#clickHere")
      browser.screenshot_to_file("results/brotector.png")
      browser.stop
    end

    task :bot do
      browser = Chromate::Browser.new
      browser.start
      browser.navigate_to("https://bot.sannysoft.com")
      sleep 2
      browser.screenshot_to_file("results/bot.png")
      browser.stop
    end

    task :cloudflare do
      browser = Chromate::Browser.new
      browser.start
      browser.navigate_to("https://dash.cloudflare.com/login")
      sleep 10
      browser.screenshot_to_file("results/cloudflare.png")
      browser.stop
    end
  end
end