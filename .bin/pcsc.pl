#!/usr/bin/perl
use strict;
use warnings;

use Chipcard::PCSC;

my $valid = 0;
my $context = new Chipcard::PCSC();
 
if (defined $context)
{
    my @reader = $context->ListReaders();
    if (defined $reader[0])
    {
        my $card = new Chipcard::PCSC::Card($context, $reader[0]);
        if (defined $card)
        {
            $valid = 1;
            $card->Disconnect();
        }
    }

}

if (!$valid)
{
    print "Smartcard status: $Chipcard::PCSC::errno\n";
    exit 1;
}
