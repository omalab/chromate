# frozen_string_literal: true

require 'chromate/hardwares/mouse_controller'
require 'chromate/hardwares/mouses/native_controller'

module Chromate
  module Hardwares
    def mouse(**ags)
      Mouses::NativeController.new(**ags)
    end
    module_function :mouse
  end
end
