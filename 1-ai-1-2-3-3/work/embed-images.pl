use strict;
use warnings;
use MIME::Base64 qw(encode_base64);

my $source = '/Users/mac/Desktop/포트폴리오/웹용 이미지';
my @files = (
  'H-2.png',
  'OTHERSIDE_01_Overview.png',
  'OTHERSIDE_02_Analysis.png',
  'OTHERSIDE_03_Application.png',
  'OTHERSIDE_04_Concept.png',
  'OTHERSIDE_05_Strategy.png',
  'OTHERSIDE_06_Design.png',
  'OTHERSIDE_Board_01_05_Packaging.png',
  'OTHERSIDE_Board_01_12_Editorial.png',
  'OTHERSIDE_Board_02_03_Poster.png',
  'OTHERSIDE_Board_02_08_Product.png',
  'OTHERSIDE_Board_02_10_Texture.png',
  'OTHERSIDE_Board_02_12_Editorial.png',
);
open my $input, '<:raw', 'index.html' or die $!;
my $html = do { local $/; <$input> };
close $input;
my @titles = ('Overview', 'Analysis', 'Application', 'Concept', 'Strategy', 'Design');
for my $i (0..$#files) {
  my $file = $files[$i];
  open my $image, '<:raw', "$source/$file" or die "$file: $!";
  my $bytes = do { local $/; <$image> };
  close $image;
  die "Invalid PNG: $file" unless substr($bytes, 0, 8) eq "\x89PNG\r\n\x1a\n";
  my ($w, $h) = unpack('NN', substr($bytes, 16, 8));
  my $data = encode_base64($bytes, '');
  my $class = $i == 0 ? 'hero-image' : $i < 7 ? 'thumbnail' : 'gallery-image';
  my $alt = ($i > 0 && $i < 7) ? $titles[$i-1] : '';
  my $load = $i == 0 ? 'loading="eager" fetchpriority="high"' : 'loading="lazy"';
  my $markup = qq{<div class="$class"><img data-source="$file" src="data:image/png;base64,$data" alt="$alt" width="$w" height="$h" $load decoding="async"></div>};
  my $count = $html =~ s{<div class="$class" aria-hidden="true"></div>}{$markup};
  die "Expected placeholder for $file" unless $count == 1;
  print "$file: ${w}x${h}\n";
}
open my $output, '>:raw', 'index.html' or die $!;
print {$output} $html;
close $output;
printf "Embedded %d images; HTML %.2f MiB\n", scalar @files, length($html)/1048576;
