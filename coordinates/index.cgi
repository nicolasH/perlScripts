#!/usr/bin/perl -w
use CGI qw/:standard canvas/;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use strict;
use DBI;
use DBD::SQLite;

my $dbfile = "prevessin.db";

my @result;
my $building = param('buildingName');

if(param){
	print header('application/json');
	my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");
	#currently exact match only
	my $sth = $dbh->prepare('select file,word, x1, y1, x2, y2 from WORDS where word like ?');
	$sth->execute($building.'%');
	$sth->bind_columns(\my($file,$word,$x1,$y1,$x2,$y2));
	print "[";
	while (my@data = $sth->fetchrow_array()) {
    	if(defined $word){
	   		print '{"word" : "'.$word.'", "x1" : '.$x1.', "y1": '.$y1.', "x2":'.$x2.',"y2":'.$y2.'},';
    	}
	}
	print ']';
  	$sth->finish;
	undef($dbh);
	print footer;
}else{

print 
       header,
       start_html(-title=> 'Building Locator', 
       			-base => 'true', 
       			-onload => 'draw()', 
       			-script => { -language => 'javascript', -src => 'markers.js' }),
       h2('Get the Location of the Prevessin Buildings'),
       p,"A Perl + Ajax experiment",
       start_form(-action=>''),
       "Which building ? (press 'locate', not enter)",textfield(-name=>'building',-id=>'buildingName'),
       button(-value=>'Locate',-onClick=>'asyncBuilding()'),
       end_form,
       hr,"\n";
    print canvas({-id=>'canvas',-width=>1589,-height=>1124});
    print end_html;
}