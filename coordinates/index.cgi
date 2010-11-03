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
	my $sth = $dbh->prepare('select file,word, x1, y1, x2, y2 from WORDS where word like ? order by word');
	$sth->execute('%'.$building.'%');
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
       			-style=> "index.css",
       			-onload => 'draw()', 
       			-script => { -language => 'javascript', -src => 'markers.js' }),
       div({-id=>'form',-class=>'form'}),
       h2('Get the Location of the Prevessin Buildings'),
       p,h3("A Perl + Ajax experiment"),
       p,"Which building ? (press 'locate', not enter)",
       textfield(-name=>'building',-id=>'buildingName'),
       button(-value=>'Locate',-onClick=>'asyncBuilding()'),
       "</div>",
       div({-id => 'results_div',-class => 'results_div'}),
       "<p id='results_title'>Results will appear here.</p>",
       ul({-id => 'results_list',-class => 'results_list'}),
       "</ul>",
       "</div>";#end_div();
       
    print canvas({-id=>'canvas',-width=>1589,-height=>1124}),"</canvas>";
    print end_html;
}