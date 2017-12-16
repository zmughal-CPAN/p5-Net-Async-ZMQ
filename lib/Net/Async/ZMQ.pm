package Net::Async::ZMQ;

use strict;
use warnings;

use Hash::NoRef qw(SvREFCNT_inc);
use IO::Handle;
use ZMQ::Constants qw(ZMQ_FD);
use Fcntl qw(O_RDONLY);
use if $^O eq 'MSWin32', 'Win32API::File' => qw(OsFHandleOpenFd);

use IO::Async::Handle;

sub new {
	my ($class, %args) = @_;

	my $socket = delete $args{socket};
	my $io_handle = _zmq_get_io_handle($socket);

	my $handle =  IO::Async::Handle->new(
		read_handle => $io_handle,
		%args,
	);

	return $handle;
}

sub _zmq_get_io_handle {
	my ($socket) = @_;

	my $fd;

	if( $^O eq 'MSWin32' ) {
		# `SOCKET` data type is a `uint64` on Windows x64.
		my $socket_handle = ZMQ::LibZMQ3::zmq_getsockopt_uint64( $socket, ZMQ_FD );
		# Converts OS socket handle to a C runtime file descriptor.
		$fd = OsFHandleOpenFd($socket_handle, O_RDONLY);
	} else {
		$fd = ZMQ::LibZMQ3::zmq_getsockopt( $socket, ZMQ_FD );
	}

	# Use dup() on the ZMQ file descriptor so that Perl can close the
	# handle without closing the ZMQ handle.
	#
	# Also, avoid using IO::Handle here due to how it closes the file
	# handle automatically.
	open(my $io_handle, "<&", $fd);

	$io_handle;
}

1;
