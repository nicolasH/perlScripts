#!/usr/bin/perl -w
use CGI qw/:standard/;
use CGI::Carp qw(warningsToBrowser fatalsToBrowser);
use strict;
use DBD::SQLite;



print 
       header,
       start_html('Building Locator'),
       h1('Get the Prevessin Buildings Locations'),
       start_form,
       "Which building ?",textfield('building'),p
       submit,
       end_form,
       hr,"\n";
    if (param) {
       print "You are looking for building ",em(param('building')),p,"\n";
       
    }
    print end_html;