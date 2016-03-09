#! /usr/bin/env perl

use SLEng::Base -modern;
use Path::Tiny 'path'; # unbase package
use TAP::Harness;
use TAP::Parser::Aggregator;
use TAP::Formatter::Console;
use Getopt::Long;
use SLEng::Debug -smpl;

my $git  = 'git';
my %commands = (
	tag      => 'tag',
	checkout => 'checkout -q ',
	status   => 'st',
);

my $opts = {
	repo => '',
};

GetOptions(
	"repo=s" => sub {
		$opts->{repo} = path( $_[1] )->realpath;
		$opts->{repo} .= '/' unless $opts->{repo} =~ m|/$|,
	},
);

die 'Use --repo=<path to mojo git repository>' unless $opts->{repo};
my $pwd  = Path::Tiny->cwd;

my $aggregator = TAP::Parser::Aggregator->new;
my $harness = TAP::Harness->new({ lib => ["$opts->{repo}lib", "lib"] });

my @taglist = ( git_get_tag(), 'master' );

$aggregator->start;
for ( @taglist ) {
	next if /[0-2]\./; # пока непонятки
	git_checkout($_);
	$harness->aggregate_tests( $aggregator, ['t/01-more.t', git_status() ]);
}
$aggregator->stop;
TAP::Formatter::Console->new->summary( $aggregator );

sub git_get_tag {
	return _git( "$git $commands{tag}" );
}

sub git_checkout {
	my $commit = shift || 'master';
	return _git( "$git $commands{checkout} $commit" );
}

sub git_status {
	my @st = _git( "$git $commands{status}" );
	return $st[0];
}

sub _git {
	my $command = shift;
	chdir $opts->{repo};
	open my $pipe, "$command |";
	my @list = map { chomp; $_ } <$pipe>;
	close $pipe;
	chdir $pwd;
	@list;
}
