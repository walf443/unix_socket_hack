require 'spec_helper'
require 'tempfile'

describe "UnixSocketHack" do
  before(:all) do
    tmp = Tempfile.new('unixsocket')
    @unix_sock_path = tmp.path + ".sock"
    UNIXSocketHack.apply({'localhost:9999' => @unix_sock_path })

    @unix_server = UNIXServer.open(@unix_sock_path )
    @tcp_server  = TCPServer.open('localhost', 9999)
    @tcp_server2  = TCPServer.open('localhost', 9998)
  end
  after(:all) do
    @unix_server.close
    @tcp_server.close
    FileUtils.rm(@unix_sock_path)
  end

  it "connect to unixsocket:9999 should be UNIXSock" do 
    sock = TCPSocket.new('localhost', 9999);
    sock.class.should == UNIXSocket
  end

  it "connect to localhost:9998 should be TCPSocket" do 
    sock = TCPSocket.new('localhost', 9998);
    sock.class.should == TCPSocket
  end

  it "connect to 127.0.0.1:9999 should be TCPSocket" do 
    sock = TCPSocket.new('127.0.0.1', 9999);
    sock.class.should == TCPSocket
  end
end
