# frozen_string_literal: true

module Chromate
  module Actions
    module Navigate
      def navigate_to(url)
        @client.send_message('Page.navigate', url: url)
      end

      def refresh
        @client.send_message('Page.reload')
      end

      def go_back
        @client.send_message('Page.goBack')
      end
    end
  end
end
