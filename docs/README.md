# Chromate Documentation Index

Welcome to the Chromate Documentation! This index provides an overview of the main classes and their detailed documentation, covering public methods, usage examples, and key features.

## 📚 Table of Contents

1. [Introduction](#introduction)
2. [Classes Overview](#classes-overview)
3. [Detailed Documentation](#detailed-documentation)
   - [Chromate::Browser](#1-chromatebrowser-class)
   - [Chromate::Element](#2-chromateelement-class)

---

## Introduction

Chromate is a Ruby-based library designed to interact with the Chrome DevTools Protocol (CDP). It allows you to control a headless Chrome browser, manipulate DOM elements, and perform automated tasks such as navigation, screenshot capture, and form submissions.

This documentation provides a comprehensive guide for the core components of Chromate:

- **Chromate::Browser**: Manages the browser instance, providing methods for starting, stopping, navigation, and executing browser actions.
- **Chromate::Element**: Represents a DOM element, enabling actions like clicking, typing, and attribute manipulation.

## Classes Overview

| Class              | Description                                           |
| ------------------ | ----------------------------------------------------- |
| `Chromate::Browser`| A class for controlling the Chrome browser instance.  |
| `Chromate::Element`| A class for interacting with individual DOM elements. |

## Detailed Documentation

### 1. `Chromate::Browser` Class

The `Browser` class is responsible for managing the lifecycle of a Chrome browser instance. It provides methods for navigation, screenshot capture, and DOM interaction. It also includes features for headless mode, native control, and video recording of sessions.

- **Features:**
  - Start and stop the browser instance.
  - Navigate to URLs, refresh, and go back in browser history.
  - Capture full-page and Xvfb screenshots.
  - Execute JavaScript code and interact with DOM elements.

For the full documentation and usage examples, refer to [Chromate::Browser Documentation](#chromatebrowser-class).

### 2. `Chromate::Element` Class

The `Element` class provides a robust interface for interacting with DOM elements in the browser. It includes methods for text extraction, attribute manipulation, and user interaction simulation (click, hover, type).

- **Features:**
  - Retrieve text and HTML content of an element.
  - Set and get element attributes.
  - Simulate user interactions (click, hover, type).
  - Interact with shadow DOM elements.

For the full documentation and usage examples, refer to [Chromate::Element Documentation](#chromateelement-class).

---

## How to Get Started

To start using Chromate in your project, ensure that you have a working installation of Google Chrome and Ruby. Follow the setup instructions provided in the README file of the project.

Example usage:

```ruby
require 'chromate'

browser = Chromate::Browser.new(headless: true)
browser.start
browser.navigate_to('https://example.com')
element = browser.find_element('#header')
puts element.text
browser.stop
```