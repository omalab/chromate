# frozen_string_literal: true

require 'rbconfig'
module Helpers
  def linux?
    RbConfig::CONFIG['host_os'] =~ /linux|bsd/i
  end

  def mac?
    RbConfig::CONFIG['host_os'] =~ /darwin/i
  end

  def windows?
    RbConfig::CONFIG['host_os'] =~ /mswin|mingw|cygwin/i
  end
end
