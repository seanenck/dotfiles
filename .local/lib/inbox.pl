#!/usr/bin/perl
use strict;
use warnings;
use autodie;

use Getopt::Long;
use Email::MIME;
use utf8;
use MIME::Entity;
use Mail::Message::Convert::MimeEntity;
use Mail::Box::Maildir;
use Email::Date::Format qw(email_date);

my $addr    = 'enckse@voidedtech.com';
my $maildir = "/home/enck/store/personal/imap/fastmail/Filtered/Automated/";
my $subject = "";
my $input   = "";
GetOptions(
    "address=s" => \$addr,
    "maildir=s" => \$maildir,
    "subject=s" => \$subject,
    "input=s"   => \$input,
) or die "unable to parse commands";

$addr                           || die "address is required";
$subject                        || die "subject is required";
$maildir                        || die "maildir is required";
( -e $maildir and -d $maildir ) || die "invalid mailrdir";
-e $input                       || die "invalid input file";

my $type;
my $message_body;

my $mime = MIME::Entity->build(
    Type    => "multipart/mixed",
    From    => $addr,
    To      => $addr,
    Subject => $subject,
    Date    => email_date,
    Data    => $message_body
);

$mime->attach(
    Path     => $input,
    Type     => "application/zip",
    Encoding => "base64"
);

my $convert = Mail::Message::Convert::MimeEntity->new;
my Mail::Message $msg = $convert->from($mime);

open STDERR, '>', '/dev/null';

my $folder = new Mail::Box::Maildir(
    folder            => $maildir,
    remove_when_empty => 0,
    access            => 'rw',
);

$folder->addMessage($msg);
