#!/usr/bin/env perl

# Gearman Perl front end
# Copyright (C) 2009-2010 Dennis Schoen
# All rights reserved.
#
# This library is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself, either Perl version 5.8.9 or,
# at your option, any later version of Perl 5 you may have available.
#
# Example Background Client

use strict;
use warnings;

use Getopt::Std;

use FindBin qw($Bin);
use lib ("$Bin/../blib/lib", "$Bin/../blib/arch");

use Gearman::XS qw(:constants);
use Gearman::XS::Client;

my %opts;
if (!getopts('h:p:', \%opts))
{
  usage();
  exit(1);
}

my $host= $opts{h} || '';
my $port= $opts{p} || 0;

if (scalar @ARGV < 1)
{
  usage();
  exit(1);
}

my $client= new Gearman::XS::Client;

my ($ret, $job_handle);

$ret= $client->add_server($host, $port);
if ($ret != GEARMAN_SUCCESS)
{
  printf(STDERR "%s\n", $client->error());
  exit(1);
}

($ret, $job_handle) = $client->do_background('reverse', $ARGV[0]);
if ($ret != GEARMAN_SUCCESS)
{
  printf(STDERR "%s\n", $client->error());
  exit(1);
}

printf("Background Job Handle=%s\n", $job_handle);

while (1)
{
  my ($ret, $is_known, $is_running, $numerator, $denominator) = $client->job_status($job_handle);

  printf("Known=%s, Running=%s, Percent Complete=%d/%d\n",
          $is_known ? "true" : "false", $is_running ? "true" : "false",
          $numerator, $denominator);

  if (!$is_known)
  {
    last;
  }

  sleep(1);
}

exit;

sub usage {
  printf("\nusage: $0 [-h <host>] [-p <port>] <string>\n");
  printf("\t-h <host> - job server host\n");
  printf("\t-p <port> - job server port\n");
}