require 'socket'

# support unixsocket to tcp only supproted library.
# @example
#   require 'unix_socket_hack'
#   UNIXSocketHack.apply({ 'unixsocket:9999' => '/path/to/unix.sock' })
#   sock = TCPSocket.new('unixsocket', 9999)
#   #=> UNIXSocket
#
class UNIXSocketHack
  def self.apply(mapping)
    TCPSocket.singleton_class.class_eval do
      alias_method :new_without_unixsockhack, :new

      define_method(:new_with_unixsockhack) do |host,service|
        if val = mapping[[host, service].join(":")]
          return UNIXSocket.new(val)
        else
          return new_without_unixsockhack(host, service)
        end
      end

      alias_method :new, :new_with_unixsockhack
    end

    UNIXSocket.class_eval do
      alias_method :setsockopt_without_unixsockhack, :setsockopt

      define_method(:setsockopt_with_unixsockhack) do |level, optname, optval|
        if level == Socket::IPPROTO_TCP
          # warn "do not setopt by unixsockhack level:#{level}, optname: #{optname}, optval:#{ optval }"
       else
         return setsockopt_without_unixsockhack(level, optname, optval)
       end
      end

      alias_method :setsockopt, :setsockopt_with_unixsockhack
    end
  end
end

