module SeloRing
  ##
  # Serviceable class adds Rinda::RingServer service capabilities to
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
  # class MyService < SeloRing::Servicable
  #   include Serviceable
  #
  #   def test
  #     "test"
  #   end
  # end
  # MyService.start
  # 

  class Serviceable
    ##
    # Reads options from hash

    def initialize(opts={})
      @identifier  =
        [Socket.gethostname.downcase,
         Process.pid,
         opts.delete(:name)].compact.join('_')

      @ring_finger =
        Rinda::RingFinger.new opts.delete(:broadcast),
                              opts.delete(:ring_port) || Rinda::Ring_PORT

      @check_every = opts.delete(:check_every) || 180
      @renewer     = opts.delete(:renewer) || Rinda::SimpleRenewer.new

      uri, _       = opts.delete(:uri), opts.delete(:front)
      DRb.start_service(uri, nil, opts) unless DRb.primary_server

      @ring_server = nil
      @service     = self.class.to_s.to_sym
      @tuple       = [:name,
                      @service,
                      DRbObject.new(self),
                      @identifier]
    end

    ##
    # Starts service

    def self.start(opts={})
      new(opts).start
      DRb.thread.join
    end

    ##
    # Starts a loop that checks for a registration tuple every #check_every
    # seconds.

    def start
      Thread.start do
        loop do
          begin
            self.register unless self.registered?
          rescue DRb::DRbConnError
            self.ring_server = nil
          rescue RuntimeError => e
            raise unless e.message == 'RingNotFound'
          end
          sleep @check_every
        end
      end
    end

    ##
    # Registers this service with the selected Rinda::RingServer.

    def register
      self.ring_server.write(@tuple, @renewer)
      nil
    end

    ##
    # Looks for a registration tuple in the selected Rinda::RingServer. If a
    # RingServer can't be found or contacted, returns false.

    def registered?
      registrations = self.ring_server.read_all([:name,
                                                 @service,
                                                 nil,
                                                 @identifier])
      registrations.any? { |registration| registration[2] == self }
    rescue DRb::DRbConnError
      @ring_server = nil
      false
    end

    ##
    # Looks up the selected Rinda::RingServer.

    def ring_server
      return @ring_server ||= @ring_finger.lookup_ring_any
    end
  end # class Serviceable
end # module SeloRing
