# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Chromate do
  it 'has a version number' do
    expect(Chromate::VERSION).not_to be nil
  end

  it 'can be configured' do
    Chromate.configure do |config|
      expect(config).to be_a Chromate::Configuration
    end
  end

  it 'has a configuration' do
    expect(Chromate.configuration).to be_a Chromate::Configuration
  end

  it 'can be configured with a block' do
    Chromate.configure do |config|
      config.user_data_dir = 'foo'
    end

    expect(Chromate.configuration.user_data_dir).to eq 'foo'
  end
end
