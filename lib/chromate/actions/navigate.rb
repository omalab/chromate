# frozen_string_literal: true

module Chromate
  module Actions
    module Navigate
      # @param [String] url
      # @return [self]
      def navigate_to(url)
        @client.send_message('Page.navigate', url: url)
        wait_for_page_load
      end

      # @return [self]
      def wait_for_page_load
        page_loaded = false

        @client.send_message('Page.enable')
        @client.ws.on :message do |msg|
          message = JSON.parse(msg.data)

          page_loaded = true if message['method'] == 'Page.loadEventFired'
        end

        Timeout.timeout(10) do
          sleep 0.1 until page_loaded
        end
        self
      end

      # @return [self]
      def refresh
        @client.send_message('Page.reload')
        self
      end

      # @return [self]
      def go_back
        @client.send_message('Page.goBack')
        self
      end
    end
  end
end
