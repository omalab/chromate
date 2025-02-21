# BotBrowser Documentation

BotBrowser is a specialized configuration module for Chromate that helps you manage and use a specific Chrome browser installation for bot automation purposes.

## Table of Contents

1. [Installation](#installation)
2. [Usage](#usage)
3. [Configuration](#configuration)
4. [API Reference](#api-reference)

## Installation

First, require the BotBrowser module in your Ruby code:

```ruby
require 'bot_browser'
```

Then, install the browser:

```ruby
# Install the latest version
BotBrowser.install

# Or install a specific version
BotBrowser.install('v130')
```

## Usage

Here's a basic example of how to use BotBrowser with Chromate:

```ruby
require 'bot_browser'

# Install the browser if not already installed
BotBrowser.install unless BotBrowser.installed?

# Load the BotBrowser configuration
BotBrowser.load

# Create a new browser instance
browser = Chromate::Browser.new

# Use the browser as you would normally with Chromate
browser.navigate_to('https://example.com')
```

## Configuration

BotBrowser uses a configuration file located at `~/.botbrowser/config.yml`. This file is automatically created during installation and contains:

- `bot_browser_path`: Path to the Chrome binary
- `profile`: Path to the browser profile directory

## API Reference

### `BotBrowser.install(version = nil)`
Installs the Chrome browser for bot automation.
- `version`: Optional. Specific version to install. If not provided, installs the latest version.

### `BotBrowser.uninstall`
Removes the installed browser and its configuration.

### `BotBrowser.installed?`
Checks if the browser is installed.
- Returns: `true` if installed, `false` otherwise.

### `BotBrowser.load`
Loads the BotBrowser configuration and sets up Chromate with the appropriate settings.
- Configures Chrome binary path
- Sets up browser profile
- Configures necessary Chrome flags for bot automation
