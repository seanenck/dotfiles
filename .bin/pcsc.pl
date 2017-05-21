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
    my $error = $Chipcard::PCSC::errno;
    my $raw = int $error;
    print "Smartcard status ($raw): $error\n";
    if ($raw == $Chipcard::PCSC::SCARD_E_NO_SMARTCARD)
    {
        exit 1;
    }
}
