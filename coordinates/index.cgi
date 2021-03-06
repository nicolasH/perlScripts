#!/usr/bin/perl -w
use CGI qw/:standard canvas/;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use strict;
use DBI;
use DBD::SQLite;

#my $dbfile = "CERN_Meyrin_A3_Paysage.db";
my $dbfile = "sites.db";
my $meyrin = "CERN_Meyrin_A3_Paysage";
my $prevessin = "CERN_Prevessin_A3_Paysage";

my @result;
my $building = param('buildingName');

if(param){
	print header('application/json');
	my $dbh = DBI->connect("dbi:SQLite:dbname=$dbfile","","");
	#currently exact match only
	my $sth = $dbh->prepare('select file,word, x1, y1, x2, y2 from WORDS where word like ? order by word+0');
	$sth->execute('%'.$building.'%');
	$sth->bind_columns(\my($file,$word,$x1,$y1,$x2,$y2));
	print "[";
	while (my@data = $sth->fetchrow_array()) {
    	if(defined $word){
	   		print '{"word" : "'.$word.'", "filePrefix": "'.$file.'","x1" : '.$x1.', "y1": '.$y1.', "x2":'.$x2.',"y2":'.$y2.'},';
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
       h2('CERN Prevessin and Meyrin Building locator'),
       #p,h3("A Perl + Ajax experiment"),
       p,"Which building ? (click locate).",
       textfield(-name=>'building',-id=>'buildingName'),
       button(-value=>'Locate',-onClick=>'asyncBuilding()'),
       "</div>\n";

		#the 'tab'       
       print div({-id => 'title_div_meyrin',-class => 'title_div_meyrin',-onmouseover => "showImage('$meyrin');"}),
       "Meyrin :",
       "</div>\n";

       print div({-id => 'title_div_prevessin',-class => 'title_div_prevessin',-onmouseover => "showImage('$prevessin');"}),
       "Prevessin :",
       "</div>\n";
       #the 'tab' content
     
       print div({-id => 'results_div_meyrin',-class => 'results_div_meyrin'}),
       ul({-id => 'results_list_meyrin',-class => 'results_list'}),
       "</ul>\n",
       "</div>\n";

       print div({-id => 'results_div_prevessin',-class => 'results_div_prevessin'}),
       ul({-id => 'results_list_prevessin',-class => 'results_list'}),
       "</ul>\n",
       "</div>\n";

	my $width = 1589;
	my $height = 1124;
	$width = 2000;
	$height = 1414;
    print canvas({-id=>'canvas_prevessin',-width=>$width,-height=>$height}),"</canvas>\n";
    print canvas({-id=>'canvas_meyrin',-width=>$width,-height=>$height}),"</canvas>\n";
    print <<'JAVASCRIPT';
    <script type="text/javascript">
	var gaJsHost = (("https:" == document.location.protocol) ? "https://ssl." : "http://www.");
	document.write(unescape("%3Cscript src='" + gaJsHost + "google-analytics.com/ga.js' type='text/javascript'%3E%3C/script%3E"));
</script>
<script type="text/javascript">
	var pageTracker = _gat._getTracker("UA-3650019-1");
	pageTracker._initData();
	pageTracker._trackPageview();
</script>
JAVASCRIPT
    
    print end_html;
}