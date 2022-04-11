#!/usr/bin/perl
use warnings;
use strict;

my ($key, $value);

my %h = ("apple" => 1,
	 "orange" => 2,
	 "mango" => 3,
	 "coconut" => 4);

$value = 0;

print("Please enter a key to search:\n");

OUTER: while(<STDIN>){
   # get input form user
   $key = $_;
   chomp($key);

   # seaching
   INNER: foreach(keys %h){
            if($_ eq $key){
		$value = $h{$_};
		last OUTER;  # exit the while loop
            }
   }  # end for
   print("Not found, Please try again:\n") if($value == 0);

}# end while

print("element found with value: $value\n");
