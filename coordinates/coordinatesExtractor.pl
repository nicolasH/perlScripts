#sources : 
#http://stackoverflow.com/questions/620470/how-can-i-get-the-width-and-height-of-a-text-string-with-campdf
use strict;
use warnings;
use CAM::PDF;

my $file = "CERN_Prevessin_A3_Paysage.pdf";
#$file = "CERN_Meyrin_A3_Paysage.pdf";
$file =~ m/^([^\.]+)\.pdf/;
my $name = $1;

my $pdf = CAM::PDF->new($file) or die $CAM::PDF::errstr;

for my $pagenum (1 .. $pdf->numPages) {
  my @dim =  $pdf->getPageDimensions($pagenum);
  #Actually the MediaBox x,y,width,height;
  print "insert into FILES(\"$name\",$dim[0],$dim[1],$dim[2],$dim[3]);\n";
  
  my $pagedict = $pdf->getPage($pagenum);
  my $rotate = 0;
  while ($pagedict) {
   	$rotate = $pdf->getValue($pagedict->{Rotate});
    if (defined $rotate) {
      last;
    }
    my $parent = $pagedict->{Parent};
    $pagedict = $parent && $pdf->getValue($parent);
  }
  #print ";/Rotate [$rotate]\n";

  my $pagetree = $pdf->getPageContentTree($pagenum) or die;
  my @text = $pagetree->traverse('MyRenderer')->getTextBlocks;
  my $previousBlock ;
  my $currentWord="";
  my $lastDst=0;
  my $wordDstSum = 0;
  my $firstBlock;
  my $wordFirstTxt;
  my $dst;
  for my $textblock (@text) {
    $dst = distance($previousBlock,$textblock);
	#use the distance to calculate if words or letters belong together.
	if($dst){
		if($dst>=16 ||
		(length $currentWord >2 && !defined belongsToSameLine($wordFirstTxt,$previousBlock,$textblock))
		#building numbers
		#($textblock->{str} =~ m/\d/ && $currentWord =~ m/^[0-9]+$/ &&  
		# (length $currentWord>1) && $dst>($wordDstSum/((length $currentWord)-1)*1.1))
		){
			my $line = underlinePoints($wordFirstTxt,$previousBlock,$currentWord);
			printInsert($name,$currentWord,$line);
			#print "\n";
			$currentWord=$textblock->{str};
			$wordDstSum = 0;
			$wordFirstTxt = $textblock;
		}else{
			$currentWord = $currentWord . $textblock->{str};
			$wordDstSum +=$dst;
			if(length $currentWord>2){
				belongsToSameLine($wordFirstTxt,$previousBlock,$textblock);
			}
		}
	}else{#First iteration
		$currentWord = $textblock->{str};
		$wordFirstTxt = $textblock;
	}
	#print "text '$textblock->{str}' at ","($textblock->{left},$textblock->{bottom},$textblock->{width},$dst) \n";

	$lastDst = $dst;	
	$previousBlock = $textblock;
  }
  #last word
  my $line = underlinePoints($wordFirstTxt,$previousBlock,$currentWord);
  printInsert($name,$currentWord,$line);

  #print "== last word : $currentWord\n";
}

sub distance {
	my($txt1,$txt2) = @_;
	if(!($txt1 && $txt2)){
		return;}
	my $x = $txt1->{left} - $txt2->{left};
	my $y = $txt1->{bottom} - $txt2->{bottom};
	return sqrt($x*$x+$y*$y);
}

sub belongsToSameLine {
	my($firstTxt,$lastTxt,$txt) = @_;
	my $dst = distance($firstTxt,$lastTxt);
	my $dst_ = distance($firstTxt,$txt);
	if (!defined $dst || !defined $dst_){
		return;
	}
	
	my( $dx,$dy,$dx_,$dy_) = 0;
	
	#deltas
	$dx = $lastTxt->{left} - $firstTxt->{left};
	$dy = $lastTxt->{bottom} - $firstTxt->{bottom};
	if($dx != 0){
		$dx = $dst / $dx;
	}	
	if($dy != 0){
		$dy = $dst / $dy;
	}
	
	$dx_ = $txt->{left} - $firstTxt->{left};
	$dy_ = $txt->{bottom} - $firstTxt->{bottom};	
	if($dx_!=0){
		$dx_ = $dst_ / $dx_;
	}	
	if($dy_!=0){
		$dy_ = $dst_ / $dy_;
	}
	if(abs($dx - $dx_)<0.2 && abs($dy - $dy_)<0.2){
		return 1;
	}else{
		return
	}
}

sub underlinePoints {
	my($firstTxt,$lastTxt,$currentWord) = @_;
	my $dst = distance($firstTxt,$lastTxt);
	if (!defined $dst){
		return;
	}
	my ($dx,$dy,$dx_,$dy_ )= 0;

	my $x1 = $firstTxt->{left};
	my $y1 = $firstTxt->{bottom};

	my $x2 = $lastTxt->{left};
	my $y2 = $lastTxt->{bottom};

	#deltas
	$dx = $x2 - $x1;
	$dy = $y2 - $y1;
	#print "current w : ",$currentWord," length", length $currentWord , "\n";
	my $wordLen = $dst * length($currentWord) /(length($currentWord)-1);

	if($dx != 0){
		$dx = $dst / $dx;
		$x2 = $x1 + ($wordLen / $dx);
	}
	if($dy != 0){
		$dy = $dst / $dy;
		$y2 = $y1 + ($wordLen / $dy);				
	}

	return {
		x1 => $x1,
		y1 => $y1,
		x2 => $x2,
		y2 => $y2
	}	
}

sub printInsert{
	my ($name,$currentWord,$line) = @_;
	print "insert into WORDS values(\"$name\",\"$currentWord\", $line->{x1}, $line->{y1}, $line->{x2}, $line->{y2});\n"
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
  my $w = ($width * $self->{Tfs});
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

