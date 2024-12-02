# frozen_string_literal: true

module Chromate
  module Actions
    module Screenshot
      # @param file_path [String] The path to save the screenshot to
      # @param options [Hash] Options for the screenshot
      # @option options [String] :format The format of the screenshot (default: 'png')
      # @option options [Boolean] :full_page Whether to take a screenshot of the full page
      # @option options [Boolean] :fromSurface Whether to take a screenshot from the surface
      # @return [Hash] A hash containing the path and base64-encoded image data of the screenshot
      def screenshot(file_path = "#{Time.now.to_i}.png", options = {})
        file_path ||= "#{Time.now.to_i}.png"
        return xvfb_screenshot(file_path) if @xfvb

        if options[:full_page]
          original_viewport = fetch_viewport_size
          update_screen_size_to_full_page!
        end

        image_data = make_screenshot(options)
        reset_screen_size! if options[:full_page]

        File.binwrite(file_path, image_data)

        {
          path: file_path,
          base64: Base64.encode64(image_data)
        }
      ensure
        restore_viewport_size(original_viewport) if options[:full_page]
      end

      private

      # @param file_path [String] The path to save the screenshot to
      # @return [Boolean] Whether the screenshot was successful
      def xvfb_screenshot(file_path)
        display = ENV['DISPLAY'] || ':99'
        system("xwd -root -display #{display} | convert xwd:- #{file_path}")
      end

      # Updates the screen size to match the full page dimensions
      # @return [void]
      def update_screen_size_to_full_page!
        metrics = @client.send_message('Page.getLayoutMetrics')
        content_size = metrics['contentSize']
        width = content_size['width'].ceil
        height = content_size['height'].ceil

        @client.send_message('Emulation.setDeviceMetricsOverride', {
                               mobile: false,
                               width: width,
                               height: height,
                               deviceScaleFactor: 1
                             })
      end

      # Resets the device metrics override
      # @return [void]
      def reset_screen_size!
        @client.send_message('Emulation.clearDeviceMetricsOverride')
      end

      # Fetches the current viewport size
      # @return [Hash] The current viewport dimensions
      def fetch_viewport_size
        metrics = @client.send_message('Page.getLayoutMetrics')
        {
          width: metrics['layoutViewport']['clientWidth'],
          height: metrics['layoutViewport']['clientHeight']
        }
      end

      # Restores the viewport size to its original dimensions
      # @param viewport [Hash] The original viewport dimensions
      # @return [void]
      def restore_viewport_size(viewport)
        return unless viewport

        @client.send_message('Emulation.setDeviceMetricsOverride', {
                               mobile: false,
                               width: viewport[:width],
                               height: viewport[:height],
                               deviceScaleFactor: 1
                             })
      end

      # @param options [Hash] Options for the screenshot
      # @option options [String] :format The format of the screenshot
      # @option options [Boolean] :fromSurface Whether to take a screenshot from the surface
      # @return [String] The image data
      def make_screenshot(options = {})
        default_options = {
          format: 'png',
          fromSurface: true,
          captureBeyondViewport: true
        }

        params = default_options.merge(options)

        @client.send_message('Page.enable')
        @client.send_message('DOM.enable')
        @client.send_message('DOM.getDocument', depth: -1, pierce: true)

        result = @client.send_message('Page.captureScreenshot', params)

        image_data = result['data']
        Base64.decode64(image_data)
      end
    end
  end
end
