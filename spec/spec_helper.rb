require 'simplecov'
SimpleCov.start

$testing = true

require 'minitest/autorun'
require 'selo_ring/serviceable'

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
