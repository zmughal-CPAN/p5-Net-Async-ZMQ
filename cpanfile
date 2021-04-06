# This file is generated by Dist::Zilla::Plugin::CPANFile v6.017
# Do not edit this file directly. To change prereqs, edit the `dist.ini` file.

requires "Fcntl" => "0";
requires "IO::Async::Handle" => "0";
requires "IO::Async::Notifier" => "0";
requires "Module::Load" => "0";
requires "Package::Stash" => "0";
requires "base" => "0";
requires "if" => "0";
requires "perl" => "5.013002";
requires "strict" => "0";
requires "warnings" => "0";

on 'test' => sub {
  requires "IO::Async::Loop" => "0";
  requires "Test::Most" => "0";
  requires "Test::Needs" => "0";
  requires "constant" => "0";
  requires "lib" => "0";
  requires "perl" => "5.013002";
};

on 'test' => sub {
  suggests "ZMQ::Constants" => "0";
  suggests "ZMQ::FFI" => "0";
  suggests "ZMQ::LibZMQ3" => "0";
  suggests "ZMQ::LibZMQ4" => "0";
};

on 'configure' => sub {
  requires "ExtUtils::MakeMaker" => "0";
  requires "perl" => "5.006";
};
