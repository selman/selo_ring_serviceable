module SeloRing
  require 'rinda/ring'

  ##
  # Serviceable module adds Rinda::RingServer service capabilities to
  # your custom class when runned #start function registers a DRb
  # service with a Rinda::RingServer and re-registers the service if
  # communication with the Rinda::RingServer is ever lost.
  #
  # Similarly, if the Rinda::RingServer should ever lose contact with the
  # service the registration will be automatically dropped after a short
  # timeout.
  #
  # = Example
  #
  # class MyService
  #   include Serviceable
  #
  #   def to_sym
  #     :MyService
  #   end
  # end
  # MyService.new.run
  # 

  module Serviceable
    include DRbUndumped

    attr_reader :check_every, :identifier, :service_name,
    :tuple, :renewer, :ring_finger #nodoc

    if $testing
      attr_writer :ring_server, :identifier, :service_name, :tuple, :renewer
    end

    ##
    # Starts a loop that checks for a registration tuple every #check_every
    # seconds.

    def start
      DRb.start_service(nil,nil,:safe_level => 1) unless DRb.primary_server
      @check_every ||= 180
      loop do
        begin
          self.register unless self.registered?
        rescue DRb::DRbConnError
          self.ring_server = nil
        rescue RuntimeError => e
          raise unless e.message == 'RingNotFound'
        end
        sleep self.check_every
      end
    end

    ##
    # Registers this service with the primary Rinda::RingServer.

    def register
      @tuple ||= [:name, self.service_name, DRbObject.new(self), self.identifier]
      @renewer ||= Rinda::SimpleRenewer.new
      self.ring_server.write(self.tuple, self.renewer)
      nil
    end

    ##
    # Looks for a registration tuple in the primary Rinda::RingServer. If a
    # RingServer can't be found or contacted, returns false.

    def registered?
      serviced = self.public_methods(false).join("#")
      @identifier ||= [Socket.gethostname.downcase, Process.pid, serviced].compact.join '_'   
      @service_name ||= self.class.to_s.to_sym
      registrations = self.ring_server.read_all([:name, self.service_name, nil, self.identifier])
      registrations.any? { |registration| registration[2] == self }
    rescue DRb::DRbConnError
      @ring_server = nil
      false
    end

    ##
    # Looks up the primary Rinde::RingServer.

    def ring_server
      @ring_finger ||= Rinda::RingFinger.new
      return @ring_server ||= self.ring_finger.lookup_ring_any
    end
  end # module Serviceable
end # module SeloRing
