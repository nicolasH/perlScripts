#!/usr/bin/perl


####################################################################################
#
#        makitAgain, first release november the 29th 2002 around half paste one AM
#
####################################################################################
#
#        This is makitAgain, a Makfile generator for c c++ projects
#        Don't ask the why of the name, there's no peculiar reason.
#        It was created sometime near the end of november 2002
#        mainly under sleep deprivation.
#        I wrote it cuz i'm lazy and wanted to get something useful out of PERL ;)
#
#        It's released under GNU public license, so the usual not responsible for ANY
#        damage (or improvement on your life) this programme has caused.
#        So juste give me credit for what I've done. Please. Thanks.
#        The Artist : Nicolas Hoibian (still no web page up for now)
#
####################################################################################
print "Generating Makefile.";
#How does it works?
#
#You juste type
#
#makitAgain.pl [the_c/c++_file_with_the_main_inside] ([if_you_want:the name for the target])
#
#the name for the target is by default the name of the first file minus it's extension
#
#it explores the include tree with the main's include as root.
#
$option="false";
$i=0;
if (@ARGV[0] eq ""||
    @ARGV[0] eq "--help"||
    @ARGV[0] eq "-help"||
    @ARGV[0] eq "help")
  {
    print "
           How does it works ?
           You juste type
           (./)makitAgain.pl [-v] the_c/c++_file_with_the_main_inside [if you want:the name for the target] [-o the_name_of_the_outputfile]
           -v : VERBOSE, like, all the makefile on screen ;)

           The name for the target is by default the name of the_c/c++_...  file minus it's extension
           Output name is Makefile by default
";
exit;
  }
else
  {
    if(@ARGV[0] eq "-v")
      {
	$option="true";
	$i++;
      }
    if (@ARGV[$i] ne "")
      {
	$upperfile=@ARGV[$i];
	if(@ARGV[$i+1] ne "" )
	  {
	    if (@ARGV[$i+1] eq "-o")
	      {
		if (@ARGV[$i+2] ne "")
		  {$sortie=@ARGV[$i+2];}
	      }
	    else
	      {	
		$target=@ARGV[$i+1];
		$sortie="Makefile";
		print "okok\n";
	      }
	  }
	else {$upperfile =~ /(\w+)\.(\w+)/;
	      $target=$1;$sortie="Makefile";}
      }
  }
if ($option eq "true"){print "verbose\n";}
#$temp_output="take";
#$
#foreach $arguement(@ARGV)
#  {
#if (/-v/)
#$option="true";
#if 
#if (/([^.])\.[^.]{1,3}/)#un nom suivi d'une extension de 1 a 3 caracteres .c .cc .cpp .xxx .x etc 


#print "@ARGV\n>>$upperfile<<$sortie>>\n";
#foreach $fichi (@ARGV)
#{
#    #print "$fichi\n";
#}
main();
if ($option eq "true") {print "\ndone\n";}

#*********************************************************

sub recupIncludes
{
  #print"recupIncludes\n";
  if ($option!=true){print".";}
  $file=@_[0];
  #    $j=@_[1];
  $i=0;
  open f, "$file" or die "[recup] Can't find $file: $!\n";
  while (<f>)
    {
      if (/\#include \"([\w]+\.[\w]+)\"$/ )
	{
	  $needed_simple[$i]=$1;
	  $i++;
	  if ($option eq "true"){print "$file a besoin de $1\n";}
	}
    }
}

#**********************************************************

sub recurs_recupIncludes
{
  #print "recurs\n";
  if ($option!=true){print ".";}
  $file=@_[0];
  $oldi=@_[1];
  #print"arobase underscore @_[0]\n";
  #print"file: $file\n";
  #print ">$oldi- $i-\n";
  open f, "$file" or die "[recurs] Can't find $file: $!\n";
  while (<f>)
    {
      if (/\#include[\s]*\"([\w]+\.[\w]+)\"$/ )
	{
	  @needed[$i]=$1;
	  $i++;
	}
    }
  if ($option eq "true"){print "$file a besoin de @needed\n";}
  if ($oldi==$i)
    {
      return;
    }
  else
    {
      #print "urk urk!\n";
      for(my($ind)=$oldi; $ind<$i ; $ind++)
	{
	  #print "indice et i :$ind fichier a cette endroit:@needed[$ind] - $i\n";
	  recurs_recupIncludes(@needed[$ind],$i);
	}
    }
}


#*******************************************************

sub interesting_files
  {
    if ($option eq "true"){print "interesting file\n";}
    else {print".";}
    $i=0;
    recurs_recupIncludes($upperfile,0);
    $nbfichier=$i;
    #print "intersting files:$i\n";
    $old="";
    @needed = sort @needed;
    print"@needed\n";
    foreach $fichier(@needed)
      {
	if ($fichier ne $old)
	  {
	    $old=$fichier;
	    @needed_cleaned[$j]=$old;
	    $j++;
	  }
	#else {print"oyoyoyo $fichier ";}
      }
    if ($option eq "true"){print "originaux: @needed_cleaned dont $j differents\n";}
    open (l, 'ls -l|');
    $i=0;
    while (<l>)
      {
	/^-.*\d ([\w]+)\.([\w]+)$/;
	
	if($2 eq "c"  ||
	   $2 eq "h"   ||
	   $2 eq "cc"  ||
	   $2 eq "cpp" ||
	   $2 eq "CC"  )
	  {
	    if ($option eq "true"){print "$1.$2 \n";}
	    @inRep[$i]=$1."\.".$2;$i++;
	  }
      }
    close l;
    $l=0;
    if ($option eq "true"){print " in rep    : @inRep\n";}
    if ($option eq "true"){print " in headers: @needed_cleaned\n";}
    foreach $pointH(@needed_cleaned)
      {
	$pointH =~ /([\w]+)\.([\w]+)/;
	if ($option eq "true"){print "radical du point h: $1\n";}
	$rad=$1;
	foreach $file (@inRep)
	  {
	    $file =~ /([\w]+)\.([\w]+)/;
	    if ($option eq "true"){print "fichier du rep:$file\n";}
	    if ($rad eq $1)
	      {
		if ($option eq "true"){print "radical du point h: $rad du fichier: $1\n";}
		@final[$l]=$file;$l++;
	      }
	  }
      }
    @final[$l]=$upperfile;$l++;
    #print "hurghhh:@final\n";
  }

#*****************************************************


sub points_O
  {
    #$sortie=@_[0];
    interesting_files();
    open output, ">>$sortie" or die "[points_O] Can't find $sortie: $!\n";
    $d=0;
    @dot_o="";
    foreach $file2(@final)
      { 
	$file2 =~ /([\w]+)\.([\w]+)/;
	$radical =$1;
	$extension =$2;
	if($2 eq "c"   ||
	   $2 eq "cc"  ||
	   $2 eq "cpp" ||
	   $2 eq "CC"  )
	  {
	    #"sources"******************
	    #print "source:$file2\n";
	    print output "$radical";
	    if ($option eq "true"){print "$radical";}
	    @dot_o[$d]="$radical.o";
	    $d++;
	    @needed_simple="";
	    @principal="";
	    $i=0;
if ($option eq "true"){$option="false";$temp="true";}
	    recupIncludes($file2);#,0);
if ($temp eq "true"){$option="true";$temp="false";}
	    print output ".o: $file2 @needed_simple ";
	    if ($option eq "true"){print ".o: $file2 @needed_simple ";}
	    @principal=@needed_simple;
	    
	    foreach $head(@principal)
	      {
		if ($head ne "")
		  {
		    @needed_simple="";
		    if ($option eq "true"){$option="false";$temp="true";}
		    recupIncludes($head);#,$i);
		    if ($temp eq "true"){$option="true";$temp="false";}
		    print output "@needed_simple ";
		    if ($option eq "true"){print "@needed_simple ";}
		  }
		else {print "**No (other) header(s)**\n";}
	      }
	    print output "\n\t";
	    if ($option eq "true"){print "\n\t";}
	    if ($extension eq "c")
	      {
		print output "\$(C) \$(CFLAGS) ";
		if ($option eq "true"){print "\$(C) \$(CFLAGS) ";}
	      }
	    else 
	      {
		print output "\$(CXX) \$(CXXFLAGS) ";
		if ($option eq "true"){print "\$(CXX) \$(CXXFLAGS) ";}
	      }

	    print output "\$(INCLUDE) \$(LIB) -c $file2\n\n";
	    if ($option eq "true"){print "\$(INCLUDE) \$(LIB)";}
	    if ($option eq "true"){print "-c $file2\n\n";}
	  }
      }
    #$upperfile =~ /(\w+)\.(\w+)/;
    print output "$target : @dot_o\n\t";
    if ($option eq "true"){print "$target : @dot_o\n\t";}
    if($2 eq "c")
      { print output"\$(C) \$(CFLAGS) ";
	if ($option eq "true"){print "\$(C) \$(CFLAGS) ";}
      }
    else
      { print output"\$(CXX) \$(CXXFLAGS) "; 
	if ($option eq "true"){print "\$(CXX) \$(CXXFLAGS) ";}
      }
    print output "\$(INCLUDE) \$(LIB) @dot_o -o $target \$(OPT)" ;
    if ($option eq "true"){print "\$(INCLUDE) \$(LIB) @dot_o -o $target \$(OPT)" ;}
    print output "\n\nclean: \n\trm -f @dot_o";   
    if ($option eq "true"){print "\n\nclean: \n\trm -f @dot_o";}
   
    close output;
  }

sub main
  {
    $i=0;
    open output, ">>$sortie" or die "[main] Can't find $sortie: $!\n";
    $now=gmtime;
    $host= `whoami`;chomp $host;
    print output"
\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#
\#
\#     Makefile generated by makitAgain, witch was itself written by Nicolas Hoibian
\#     generating date: $now
\#     generated from [$upperfile] for [$target] by [$host]
\#
\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#


target: $target

\# options and special stuff

OPT       :
INCLUDE   :
LIB       :
CXX       :g++
CXXFLAGS  :
C         :gcc
CFLAGS    :


\# rules n' regulations
";

close output;
#if ($option eq "true")
#  {
#   print "
#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#
#\#
#\#     Makefile generated by makitAgain, witch was itself written by Nicolas Hoibian
#\#     generating date: $now
#\#     generated from $upperfile for $target by $host
#\#
#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#


#target: $target

#\# options and special stuff

#OPT       :
#INCLUDE   :
#LIB       :
#CXX       :g++
#CXXFLAGS  :
#C         :gcc
#CFLAGS    :


#\# rules and regulations
#";
    # }
    points_O();
  }
