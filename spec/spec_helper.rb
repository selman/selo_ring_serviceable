require 'bundler/setup'

begin
  require 'simplecov'
  SimpleCov.start
rescue LoadError
end

require 'minitest/autorun'
require 'selo_ring'

module SeloRing
  class Serviceable
    attr_writer :ring_server, :tuple, :renewer
    attr_reader :identifier, :service
  end
end

class MyService < SeloRing::Serviceable

  def m1
    "test1"
  end

  def m2
    "test2"
  end
end
