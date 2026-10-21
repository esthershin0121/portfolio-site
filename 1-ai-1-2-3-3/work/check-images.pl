use strict;
use warnings;
use MIME::Base64 qw(decode_base64);
use Digest::SHA qw(sha256_hex);
my $source = '/Users/mac/Desktop/포트폴리오/웹용 이미지';
open my $input, '<:raw', 'index.html' or die $!;
my $html = do { local $/; <$input> };
my @names;
while ($html =~ /<img data-source="([^"]+)" src="data:image\/png;base64,([A-Za-z0-9+\/=]+)"/g) {
  my ($file, $encoded) = ($1, $2);
  open my $original, '<:raw', "$source/$file" or die $!;
  my $bytes = do { local $/; <$original> };
  die "Image mismatch: $file" unless sha256_hex($bytes) eq sha256_hex(decode_base64($encoded));
  push @names, $file;
}
die 'Wrong image count' unless @names == 13;
my @expected = ('H-2.png', 'OTHERSIDE_01_Overview.png', 'OTHERSIDE_02_Analysis.png', 'OTHERSIDE_03_Application.png', 'OTHERSIDE_04_Concept.png', 'OTHERSIDE_05_Strategy.png', 'OTHERSIDE_06_Design.png', 'OTHERSIDE_Board_01_05_Packaging.png', 'OTHERSIDE_Board_01_12_Editorial.png', 'OTHERSIDE_Board_02_03_Poster.png', 'OTHERSIDE_Board_02_08_Product.png', 'OTHERSIDE_Board_02_10_Texture.png', 'OTHERSIDE_Board_02_12_Editorial.png');
die 'Wrong image order' unless join('|', @names) eq join('|', @expected);
print "PASS: 13 embedded PNGs match the original files and attachment order.\n";
