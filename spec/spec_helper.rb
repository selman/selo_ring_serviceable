require 'bundler/setup'

begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
end

require 'minitest/autorun'
require 'selo_ring/serviceable'

module SeloRing::Serviceable
  attr_writer :ring_server, :tuple, :renewer
end

DRb.start_service

class MyService
  include SeloRing::Serviceable

  def m1
    "test1"
  end

  def m2
    "test2"
  end
end
