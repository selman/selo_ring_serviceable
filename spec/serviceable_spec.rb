require 'spec_helper'

describe SeloRing::Serviceable do
  before do
    @myservice = MyService.new
    @ring_server = MiniTest::Mock.new
    @myservice.ring_server = @ring_server
    @ident =
      [Socket.gethostname.downcase,
       Process.pid,
       @myservice.public_methods(false).join('#')].compact.join('_')
  end

  it "should register service" do
    tuple = [:name, :MyService, DRbObject.new(@myservice), @ident]
    renewer = Rinda::SimpleRenewer.new
    @myservice.tuple = tuple
    @myservice.renewer = renewer
    
    expected = [
                [tuple,
                 renewer]
               ]

    @ring_server.expect :write, expected, [tuple, renewer]
    @myservice.register
    @ring_server.verify
  end

  it "should check ring_server and registered" do
    check_ring_server([[:name, :MyService, @myservice, @ident]]) do |service|
      service.registered?.must_equal true
    end
  end

  it "should check ring_server and not registered" do
    check_ring_server([]) do |service|
      service.registered?.must_equal false
    end   
  end

  it "should rescue DRb::DRbConnError" do
    def @ring_server.read_all(*args); raise DRb::DRbConnError end
    @myservice.registered?.must_equal false
  end

  def check_ring_server(expected)
    @ring_server.expect :read_all, expected, [[:name, :MyService, nil, @ident]]

    yield(@myservice) if block_given?

    @myservice.identifier.must_equal @ident
    @myservice.service_name.must_equal :MyService
    @ring_server.verify
  end
end
