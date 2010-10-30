#sources : 
#http://stackoverflow.com/questions/620470/how-can-i-get-the-width-and-height-of-a-text-string-with-campdf

use CAM::PDF;
my $pdf = CAM::PDF->new('CERN_Prevessin_A3_Paysage.pdf') or die $CAM::PDF::errstr;
#my $pdf = CAM::PDF->new('CERN_Meyrin_A3_Paysage.pdf') or die $CAM::PDF::errstr;

for my $pagenum (1 .. $pdf->numPages) {
  my $pagetree = $pdf->getPageContentTree($pagenum) or die;
  my @text = $pagetree->traverse('MyRenderer')->getTextBlocks;
  my $previousBlock ;
  my $currentWord="";
  my $lastDst=0;
  for my $textblock (@text) {
    $dst = distance($previousBlock,$textblock);
	#print "$textblock->{str}";# at ","($textblock->{left},$textblock->{bottom}) ";
	
	if($dst){
		if($dst>=16 ||( $currentWord =~ m/\d+/ && $textblock->{str} =~ m/\d/ && $dst>$lastDst*1.5)){#|| $dst<$previousBlock->{width}*2){
			print "== WORD : $currentWord\n";
			#print " $dst \n";
			$currentWord=$textblock->{str};
		}else{
			$currentWord = $currentWord . $textblock->{str};
		}
	}else{#First iteration
		$currentWord = $textblock->{str};
	}
	#print "text '$textblock->{str}' at ","($textblock->{left},$textblock->{bottom},$textblock->{width},$dst) \n";

	$lastDst = $dst;	
	$previousBlock = $textblock;
  }
  print "== last word : $currentWord\n";
}

sub distance {
	my($txt1,$txt2) = @_;
	if(!($txt1 && $txt2)){
		return;}
	$x = $txt1->{left} - $txt2->{left};
	$y = $txt1->{bottom} - $txt2->{bottom};
	return sqrt($x*$x+$y*$y);
}

package MyRenderer;
use base 'CAM::PDF::GS';

sub new {
  my ($pkg, @args) = @_;
  my $self = $pkg->SUPER::new(@args);
  $self->{refs}->{text} = [];
  return $self;
}
sub getTextBlocks {
  my ($self) = @_;
  return @{$self->{refs}->{text}};
}
sub renderText {
  my ($self, $string, $width) = @_;
  my ($x, $y) = $self->textToDevice(0,0);
  $w = ($width * $self->{Tfs});
  push @{$self->{refs}->{text}}, {
                                  str => $string,
                                  left => $x,
                                  bottom => $y,
                                  right => $x + $w,
                                  width =>$w
                                  #top => $y + ???,
                                 };
  return;
}

