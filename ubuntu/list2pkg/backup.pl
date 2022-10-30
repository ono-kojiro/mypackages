#!/usr/bin/env perl

use utf8;
use strict;
use warnings;

use Getopt::Long;
use File::Copy;

sub main()
{
  my $ret = 0;
  my $options = {};

  GetOptions(
	$options,
	"input=s",
	"output=s",
  );

  #if(not defined($options->{'input'})){
  #  printf STDERR ("no input option\n");
  #  $ret++;
  #}
  if(not defined($options->{'output'})){
    printf STDERR ("no output option\n");
    $ret++;
  }

  if($ret){
    exit($ret);
  }

  printf("output is %s\n", $options->{'output'});
  my $dir_path;
  my ($from, $to);

  my $line;
  while($line = <STDIN>){
    $line =~ s/\r?\n?$//;

    if(-d $line){
      printf("%s is directory\n", $line);
      $dir_path = $options->{'output'} . $line;
      mkdir($dir_path); 
    }
    elsif(-f $line){
      printf("%s is file\n", $line);
      $from = $line;
      $to   = $options->{'output'} . $line;
      copy($from, $to);
    }
    else{
      printf("%s is unknown\n", $line);
    }
  }
}

main();

