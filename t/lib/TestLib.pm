package    # hide from PAUSE
  TestLib;

use strict;
use warnings;
use FindBin qw( $Bin );

sub new { return bless {}, shift }

sub run_gearmand {
  my ($self) = @_;
  my $gearmand = find_gearmand();
  die "Cannot locate gearmand executable"
    if !$gearmand;
  if ($self->{gearmand_pid}= fork)  {
    warn("test_server PID is " . $self->{gearmand_pid});
  }
  else {
    die "cannot fork: $!"
      if (!defined $self->{gearmand_pid});
    $|++;
    my @cmd= ($gearmand, '-p', 4731);
    exec(@cmd)
      or die("Could not exec $gearmand");
    exit;
  }
}

sub run_test_worker {
  my ($self) = @_;
  if ($self->{test_worker_pid} = fork)
  {
    warn("test_worker PID is " . $self->{test_worker_pid});
  }
  else
  {
    die "cannot fork: $!"
      if (!defined $self->{test_worker_pid});
    $|++;
    my @cmd = ($^X, "$Bin/test_worker.pl");
    exec(@cmd)
      or die("Could not exec $Bin/test_worker.pl");
    exit;
  }
}

sub DESTROY {
  my ($self) = @_;

  for my $proc (qw/gearmand_pid test_worker_pid/)
  {
    system 'kill', $self->{$proc}
      if $self->{$proc};
  }
}

sub find_gearmand {
  my $gearmand= find_gearmand_in_path();
  $gearmand ||= find_gearmand_with_pkg_config();
  return $gearmand
}

sub find_gearmand_in_path {
  my $gearmand= `which gearmand`;
  chomp $gearmand;
  return $gearmand;
}

sub find_gearmand_with_pkg_config {
  my $pkg_config = `which pkg-config`;
  return
    if !$pkg_config;
  my $exec_prefix= `$pkg_config --variable=exec_prefix gearmand`;
  chomp $exec_prefix;
  return "$exec_prefix/sbin/gearmand"
    if $exec_prefix
}

1;
