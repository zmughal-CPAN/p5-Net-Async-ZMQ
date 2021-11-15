package Net::Async::ZMQ;
# ABSTRACT: IO::Async support for ZeroMQ

use strict;
use warnings;

use base qw( IO::Async::Notifier );

1;
__END__
=head1 SYNOPSIS

  use IO::Async::Loop;
  use Net::Async::ZMQ;
  use Net::Async::ZMQ::Socket;

  use ZMQ::LibZMQ3;  # or ZMQ::LibZMQ4
  use ZMQ::Constants qw(
    ZMQ_REQ
    ZMQ_NOBLOCK
    ZMQ_EVENTS ZMQ_POLLIN
  );

  my $loop = IO::Async::Loop->new;

  my $ctx = zmq_init();
  my $client_socket = zmq_socket( $ctx, ZMQ_REQ );
  zmq_connect( $client_socket, "tcp://127.0.0.1:9999" );

  my $counter = 0;

  my $zmq = Net::Async::ZMQ->new;

  zmq_sendmsg( $client_socket, "initial message" );

  $zmq->add_child(
    Net::Async::ZMQ::Socket->new(
      socket => $client_socket,
      on_read_ready => sub {
        while ( zmq_getsockopt( $client_socket, ZMQ_EVENTS ) & ZMQ_POLLIN ) {
          my $recvmsg = zmq_recvmsg( $client_socket, ZMQ_NOBLOCK );
          my $msg = zmq_msg_data($recvmsg);
          zmq_sendmsg( $client_socket, "hello @{[ $counter++ ]}" );
        }
      },
    )
  );

  $loop->add( $zmq );

  $loop->run;

=head1 DESCRIPTION

A subclass of L<IO::Async::Notifier> that can hold ZMQ sockets
that are provided by L<Net::Async::ZMQ::Socket>.

Supports sockets from the following libraries:

=begin :list

* L<ZMQ::LibZMQ3>

* L<ZMQ::LibZMQ4>

* L<ZMQ::FFI>

=end :list

=head1 SEE ALSO

=begin :list

* L<C<ZMQ_FD> in C<zmq_getsockopt>|http://api.zeromq.org/master:zmq-getsockopt>

* L<ZeroMQ - Edge Triggered Notification|https://funcptr.net/2012/09/10/zeromq---edge-triggered-notification/>

=end :list

=cut
