#!/usr/bin/env perl

use Test::Most tests => 1;
use Test::Requires qw(ZMQ::LibZMQ3 ZMQ::Constants);
use Net::EmptyPort qw(empty_port);

use IO::Async::Loop;
use IO::Async::Routine;

use Net::Async::ZMQ;

subtest "Add socket" => sub {
	my $loop = IO::Async::Loop->new;

	my $port = empty_port();
	my $addr = "tcp://127.0.0.1:$port";

	my $loop_done = $loop->new_future;


	my $child = IO::Async::Routine->new(
		code => sub {
			my $ctx = zmq_init();
			my $socket = zmq_socket( $ctx, ZMQ::Constants::ZMQ_REQ );
			zmq_connect( $socket, $addr );
			for(0..2) {
				zmq_sendmsg( $socket, "hello $_" );
				while ( my $recvmsg = zmq_recvmsg( $socket ) ) {
					my $msg = zmq_msg_data($recvmsg);
				}
			}
		},
		on_return => sub {
			$loop_done->done;
		},
	);
	$loop->add( $child );

	my $ctx = zmq_init();
	my $socket = zmq_socket( $ctx, ZMQ::Constants::ZMQ_REP );
	zmq_bind( $socket, $addr );

	my @blobs;
	$loop->add(
		Net::Async::ZMQ->new(
			socket => $socket,
			on_read_ready => sub {
				while ( my $recvmsg = zmq_recvmsg( $socket ) ) {
					my $msg = zmq_msg_data($recvmsg);
					my $r_msg = reverse $msg;
					zmq_sendmsg( $socket, $r_msg );
					push @blobs, $msg;
				}
			},
		)
	);

	$loop_done->on_ready(sub {
		is_deeply(\@blobs, [
			map { "hello $_" } (0..2)
		], 'Got the 3 messages' );
		$loop->stop;
	});

	$loop->loop_forever;
};

done_testing;
