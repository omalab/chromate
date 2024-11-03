# frozen_string_literal: true

require 'chromate/hardwares/mouse_controller'
require 'chromate/hardwares/mouses/virtual_controller'
require 'chromate/hardwares/mouses/mac_os_controller'
require 'chromate/helpers'

module Chromate
  module Hardwares
    include Helpers

    def mouse(**ags)
      if Configuration.config.native_control
        return Mouses::MacOsController.new(**ags) if mac?
        return Class.new if linux?
        raise 'Native mouse controller is not supported on Windows' if windows?
      else
        Mouses::VirtualController.new(**ags)
      end
    end
    module_function :mouse
  end
end
