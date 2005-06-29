#!C:\perl\bin\perl.exe

################################################################################
#    Copyright 2004, 2005 Mark Vilrokx and the utPLSQL Project
#    (mvilrokx@gmail.com, markvilrokx@hotmail.com)
#
#    This file is part of uWI: the utPLSQL Web Interface.
#
#    uWI is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    uWI is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with uWI; if not, write to the Free Software
#    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
################################################################################

use CGI;
use strict;
#use Apache::DBI;
use DBI;
use CGI::Carp qw(fatalsToBrowser);
use POSIX;
use Data::Dumper;

# Declare env. variables
our $uwi = "uwi.pl";
our $pagesize = 20;
our $q = new CGI();

# Get all Parameters
our $tab = $q->param("tab")||"suites";
our $action = $q->param("action")||"showallsuites";
our $order_by = $q->param("order_by")||"name";
our $order = $q->param("order")||"desc";
our $suite_id = $q->param("suite_id");
our $suite_name = $q->param("suite_name");
our $package_name = $q->param("package_name");
our $package_id = $q->param("package_id");
our $start = $q->param("start")||1;

# our $dbh = undef;

my $cookie;
# Get logoninfo from cookie
my %logoninfo = $q->cookie(-name=>"logoninfo");
my $dbh;

if ($tab ne "about") {
   if ( ! defined %logoninfo || $logoninfo{"db_user"} eq "" ) {
      if ( $action eq "Connect" ) {
         $cookie = LogonCookie();
         %logoninfo = $q->Vars;
         $tab="suites";
         $action="showallsuites";
      } else {
         StartHtml("utPLSQL Web Interface: uWI");
         LogonForm();
         Copyright();
         print $q->end_html;
         exit;
      }
   }
   $dbh = ConnectToDb($logoninfo{"db_user"},
               $logoninfo{"db_pwd"},
               $logoninfo{"db_name"},
               $logoninfo{"db_host"},
               $logoninfo{"db_port"});
}

#our $dbh = DBI->connect("DBI:Oracle:hrotldv", "APPS", "APPS")
#          or die "Cannot connect: " . $DBI::errstr;

# Begin
StartHtml("utPLSQL Web Interface: uWI", $cookie);

#print "tab = $tab<br>";
#print "action = $action";

Tabs();
Train();

if ($action eq "showallsuites" || $action eq "Connect"){
   ShowAllSuites($dbh);
} elsif ($action eq "runsuite"){
   RunSuite($dbh);
} elsif ($action eq "removesuite"){
   RemoveSuite($dbh);
} elsif ($action eq "showsuiteresults"){
   ShowSuiteResults($dbh);
} elsif ($action eq "showsuitepackages"){
   ShowSuitePackages($dbh);
} elsif ($action eq "removefromsuite"){
   RemoveFromSuite($dbh);
} elsif ($action eq "showpackageresults"){
   ShowPackageResults($dbh);
} elsif ($action eq "createnewsuite"){
   CreateSuiteForm($dbh);
} elsif ($action eq "Create Suite"){
   CreateNewSuite($dbh);
} elsif ($action eq "addpackagetosuite"){
   AddPackageToSuiteForm($dbh);
} elsif ($action eq "createnewpackage"){
   AddPackageForm($dbh);
} elsif ($action eq "Add Package"){
   if ($tab eq "suites") {
      AddPackageToSuite($dbh);
   } elsif ($tab eq "packages") {
      AddPackage($dbh);
   }
} elsif ($action eq "showallpackages"){
   ShowAllPackages($dbh);
} elsif ($action eq "runpackage"){
   RunPackage($dbh);
} elsif ($action eq "removepackage"){
   RemovePackage($dbh);
} elsif ($action eq "showabout"){
   About();
} elsif ($action eq "sysinfo"){
   SysInfo(%logoninfo);
} elsif ($action eq "faq"){
   Faq();
} elsif ($action eq "showallscheduledjobs"){
   ShowAllScheduledJobs($dbh);
} elsif ($action eq "addjob"){
   AddJobForm($dbh);
} elsif ($action eq "Add Job"){
   AddJob($dbh);
} elsif ($action eq "enablejob"){
   EnableJob($dbh);
} elsif ($action eq "disablejob"){
   DisableJob($dbh);
} elsif ($action eq "dropjob"){
   DropJob($dbh);
}

Footer();
Copyright();
print $q->end_html;
# End







###############################################################################
#### Subs used throughout the code
###############################################################################
sub StartHtml {
   my ($page_title, $cookie) = @_;
   my $cssRoot = "http://".CGI::server_name()."/";

   my $q;
   my @css = ($cssRoot."uwi.css");
   my @dtd = ("-//W3C//DTD XHTML 1.0 Strict//EN",
              "http://www.w3.org/TR/XHTML1/DTD/XHTML1-strict.dtd");

   $q = new CGI();
   print $q->header(-cookie=>$cookie, -charset=>"UTF-8");
   print $q->start_html(-title=>$page_title,
                        -author=>"markvilrokx\@hotmail.com",
                        -meta=>{keywords=>"utplsql plsql pl*sql Oracle",
                                copyright=>"copyright 2005 Mark Vilrokx and the utPLSQL Project"},
                        -dtd=>\@dtd,
#                        -lang=>'',
                        -style=>{-src=>\@css},
                        -encoding=> "UTF-8");
}

sub Tabs {

   print $q->start_ul({-id=>"navbar"});

   print $q->start_li(),
         $q->a({-href=>"$uwi?tab=suites&amp;action=showallsuites",
                -class=>ActiveTab("suites")}, "Test Suites");

   if ($tab eq "suites" || $tab eq ""){
      print $q->ul({-id=>"navbarsuite"},
                   $q->li($q->a({-href=>"$uwi?tab=suites&amp;action=showallsuites",
                                 -class=>ActiveSubTab("showallsuites")},
                                "Show All"
                                )
                          ),
                   $q->li($q->a({-href=>"$uwi?tab=suites&amp;action=createnewsuite",
                                 -class=>ActiveSubTab("createnewsuite")},
                                "Create New Suite"
                                )
                          ),
                   $q->li($q->a({-href=>"$uwi?tab=suites&amp;action=addpackagetosuite&amp;suite_id=$suite_id&amp;suite_name=$suite_name",
                                 -class=>ActiveSubTab("addpackagetosuite")},
                                "Add Package to Suite"
                                )
                          )
                   );
   }
   print $q->end_li;

   print $q->start_li(),
         $q->a({-href=>"$uwi?tab=packages&amp;action=showallpackages",
                -class=>ActiveTab("packages")}, "Test Packages");

   if ($tab eq "packages"){
      print $q->ul({-id=>"navbarpackages"},
                   $q->li($q->a({-href=>"$uwi?tab=packages&amp;action=showallpackages",
                                 -class=>ActiveSubTab("showallpackages")},
                                "Show All"
                                )
                          ),
                   $q->li($q->a({-href=>"$uwi?tab=packages&amp;action=createnewpackage",
                                 -class=>ActiveSubTab("createnewpackage")},
                                "Create New Package"
                                )
                          )
                   );
   }
   print $q->end_li;

   print $q->start_li(),
         $q->a({-href=>"$uwi?tab=uwischeduler&amp;action=showallscheduledjobs",
                -class=>ActiveTab("uwischeduler")}, "uWI Scheduler");

   if ($tab eq "uwischeduler"){
      print $q->ul({-id=>"navbaruwischeduler"},
                   $q->li($q->a({-href=>"$uwi?tab=$tab&amp;action=showallscheduledjobs",
                                 -class=>ActiveSubTab("showallscheduledjobs")},
                                "Scheduled Jobs"
                                )
                          ),
#                   $q->li($q->a({-href=>"$uwi?tab=$tab&amp;action=showallschedules",
#                                 -class=>ActiveSubTab("showallschedules")},
#                                "Schedules"
#                                )
#                          ),
#                   $q->li($q->a({-href=>"$uwi?tab=$tab&amp;action=jobs",
#                                 -class=>ActiveSubTab("jobs")},
#                                "Jobs"
#                                )
#                          ),
                   $q->li($q->a({-href=>"$uwi?tab=$tab&amp;action=addjob",
                                 -class=>ActiveSubTab("addjob")},
                                "Schedule New Job"
                                )
                          )
                   );
   }

   print $q->end_li;

   print $q->start_li(),
         $q->a({-href=>"$uwi?tab=about&amp;action=showabout",
                -class=>ActiveTab("about")}, "About uWI");
   if ($tab eq "about"){
      print $q->ul({-id=>"navbarabout"},
                   $q->li($q->a({-href=>"$uwi?tab=$tab&amp;action=showabout",
                                 -class=>ActiveSubTab("showabout")},
                                "About uWI"
                                )
                          ),
                   $q->li($q->a({-href=>"$uwi?tab=$tab&amp;action=faq",
                                 -class=>ActiveSubTab("faq")},
                                "FAQ"
                                )
                          ),
                   $q->li($q->a({-href=>"$uwi?tab=$tab&amp;action=sysinfo",
                                 -class=>ActiveSubTab("sysinfo")},
                                "System Information"
                                )
                          )
                   );
   }

   print $q->end_li;

   print $q->end_ul;
}

sub ActiveTab {
   my $evaltab = shift;
   my $active;
   if ($evaltab eq $tab){
      $active="here";
   } else {
      $active="";
   }
   return $active;
}

sub ActiveSubTab {
   my $evalsubtab = shift;
   my $active;
   if ($evalsubtab eq $action){
      $active="here";
   } else {
      $active="";
   }
   return $active;
}

sub ShowAllSuites {
   my $dbh = shift;
   my @rows;
   my $sql = " SELECT    '<a href=''$uwi?tab=$tab&amp;action=showsuitepackages&amp;suite_id='
                   || us.id
                   || '&amp;suite_name='
                   || us.NAME
                   || '''>'
                   || us.NAME
                   || '</A>' AS SUITENAME,
                   description,
                      '<a href=''$uwi?tab=$tab&amp;action=showsuiteresults&amp;suite_id='
                   || us.ID
                   || '''>'
                   || us.last_status
                   || '</A>' AS laststatus,
                   us.executions, us.failures,
                   TO_CHAR (us.last_end, 'DD-MON-YYYY HH24:MI:SS') AS last_end,
                   TO_NUMBER (
                      ROUND (
                         (  us.last_end
                          - us.last_start
                         ) * 24 * 60 * 60
                      )
                   ) AS last_duration,
                      '<a href=''$uwi?tab=$tab&amp;action=runsuite&amp;order_by=$order_by&amp;order=$order&amp;suite_name='
                   || us.NAME
                   || '''>Run</A>' AS run,
                      '<a href=''$uwi?tab=$tab&amp;action=removesuite&amp;order_by=$order_by&amp;order=$order&amp;suite_name='
                   || us.NAME
                   || '''>Remove</A>' AS remove
              FROM ut_suite us
          ORDER BY $order_by $order";

   my $sth = $dbh->prepare($sql)
                   or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute
         or die "Cannot execute: " . $sth->errstr();

   push (@rows,$q->th([$q->a({-href=>"$uwi?tab=$tab&amp;action=showallsuites&amp;order_by=name&amp;order=".NextOrder()},"Name".OrderSign("name")),
                       "Description",
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showallsuites&amp;order_by=last_status&amp;order=".NextOrder()},"Status of Last Run".OrderSign("last_status")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showallsuites&amp;order_by=executions&amp;order=".NextOrder()},"# Runs".OrderSign("executions")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showallsuites&amp;order_by=failures&amp;order=".NextOrder()},"# Failed Runs".OrderSign("failures")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showallsuites&amp;order_by=last_end&amp;order=".NextOrder()},"Last Run Date".OrderSign("last_end")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showallsuites&amp;order_by=last_duration&amp;order=".NextOrder()},"Run Time (secs)".OrderSign("last_duration")),
                       "Run", "Remove"]));
   while ((my @row = $sth->fetchrow_array)) {
      push (@rows,$q->td([@row]));
   }
   ZebraTable(\@rows);
   $sth->finish();
}

sub ZebraTable {
   my $table = shift;
   my $row_counter;
   my $num_rows;

   Navigator($table);

   # Make sure table header gets displayed
   push (my @display_rows, $table->[0]);
   # only show one page of rows
   if (@$table < ($start + $pagesize - 1)) {
      $num_rows = @$table;
   } else {
      $num_rows = $start + $pagesize;
   }
   for (my $i=$start; $i<=($num_rows-1); $i++) {
      push (@display_rows, $table->[$i])
   }

   print '<div id="query_table">',
         $q->start_table;
   foreach my $row (@display_rows) {
      $row_counter++;
      if ($row_counter % 2 == 0) {
         if ($row =~ "FAILURE") {
            print $q->Tr({-class=>"evenfailure"},$row);
         } else {
            print $q->Tr({-class=>"even"},$row);
         }
      } else {
         if ($row =~ "FAILURE") {
            print $q->Tr({-class=>"oddfailure"}, $row);
         } else {
            print $q->Tr({-class=>"odd"}, $row);
         }
      }
   }
   print $q->end_table,
         '</div>';
}

sub NextOrder {
   my $next_order;
   if ($order eq "asc") {
      $next_order = "desc";
   } else {
      $next_order = "asc";
   }
   return $next_order;
}

sub OrderSign {
   my $column = shift;
   my $ordersign;
   if ($column eq $order_by) {
      if ($order eq "asc") {
#         $ordersign = " v";
         #ordersign = " \x{2193}";  # arrow
         $ordersign = " \x{25BD}";  # triangle;
      } else {
#         $ordersign = " ^";
         #$ordersign = " \x{2191}"; # arrow;
         $ordersign= " \x{25B3}"; # triangle;
      }
   }
   return $ordersign;
}

sub RunSuite {
   my $dbh = shift;
   my $sqlscript = " BEGIN
                        utPLSQL.testsuite (?, recompile_in => FALSE);
                     END; ";
   my $sth = $dbh->prepare($sqlscript)
             or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute($suite_name)
         or die "Cannot execute: " . $sth->errstr();
   $sth->finish();
   ShowAllSuites($dbh);
}

sub RemoveSuite {
   my $dbh = shift;
   my $sqlscript = " BEGIN
                        utsuite.rem (name_in => ?);
                     END; ";
   my $sth = $dbh->prepare($sqlscript)
             or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute($suite_name)
         or die "Cannot execute: " . $sth->errstr();
   $sth->finish();
   ShowAllSuites($dbh);
}

sub ShowSuiteResults {
   my $dbh = shift;
   my @rows;
   my $sql = " SELECT utp.NAME, utro.status, utro.description
                 FROM ut_package utp, utr_outcome utro
                WHERE utp.suite_id = $suite_id
                  AND utp.last_run_id = utro.run_id
             ORDER BY $order_by $order";

   my $sth = $dbh->prepare($sql)
                   or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute
         or die "Cannot execute: " . $sth->errstr();

   push (@rows,$q->th([$q->a({-href=>"$uwi?tab=$tab&amp;action=showsuiteresults&amp;suite_id=$suite_id&amp;order_by=1&amp;order=".NextOrder()},"Package Name".OrderSign("1")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showsuiteresults&amp;suite_id=$suite_id&amp;order_by=2&amp;order=".NextOrder()},"Status of Run".OrderSign("2")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showsuiteresults&amp;suite_id=$suite_id&amp;order_by=3&amp;order=".NextOrder()},"Description of Test or Error".OrderSign("3")),
                       ]));
   while ((my @row = $sth->fetchrow_array)) {
      push (@rows,$q->td([@row]));
   }
   ZebraTable(\@rows);
   $sth->finish();
}

sub ShowSuitePackages {
   my $dbh = shift;
   my @rows;
   my $sql = " SELECT NAME AS PACKAGENAME,
                         '<a href=''$uwi?tab=$tab&amp;action=showpackageresults&amp;suite_name=$suite_name&amp;suite_id='
                   || up.suite_id
                   || '&amp;package_id='
                   || up.id
                   || '&amp;package_name='
                   || up.name
                   || '''>'
                   || up.last_status
                   || '</A>' AS laststatus,
                   TO_CHAR (up.last_end, 'DD-MON-YYYY HH24:MI:SS') AS last_end,
                   TO_NUMBER (
                      ROUND (
                         (  up.last_end
                          - up.last_start
                         ) * 24 * 60 * 60
                      )
                   ) AS last_duration,
                      '<a href=''$uwi?tab=$tab&amp;action=removefromsuite&amp;suite_name=$suite_name&amp;order_by=$order_by&amp;order=$order&amp;package_name='
                   || up.NAME
                   || '&amp;suite_id='
                   || up.suite_id
                   || '''>Remove From Suite</A>' AS remove
              FROM ut_package up\n";
   if ($suite_id) {
      $sql = "$sql WHERE up.suite_id = $suite_id \n";
   } else {
      $sql = "$sql WHERE up.suite_id = utsuite.id_from_name('$suite_name') \n";
   }
   $sql = "$sql ORDER BY $order_by $order";

   my $sth = $dbh->prepare($sql)
                   or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute
         or die "Cannot execute: " . $sth->errstr();

   push (@rows,$q->th([$q->a({-href=>"$uwi?tab=$tab&amp;action=showsuitepackages&amp;suite_id=$suite_id&amp;suite_name=$suite_name&amp;order_by=name&amp;order=".NextOrder()},"Package Name".OrderSign("name")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showsuitepackages&amp;suite_id=$suite_id&amp;suite_name=$suite_name&amp;order_by=last_status&amp;order=".NextOrder()},"Status of Run".OrderSign("last_status")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showsuitepackages&amp;suite_id=$suite_id&amp;suite_name=$suite_name&amp;order_by=last_end&amp;order=".NextOrder()},"Last Run Date".OrderSign("last_end")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showsuitepackages&amp;suite_id=$suite_id&amp;suite_name=$suite_name&amp;order_by=last_duration&amp;order=".NextOrder()},"Run Time (sec)".OrderSign("last_duration")),
                       "Remove From Suite"
                       ]));
   while ((my @row = $sth->fetchrow_array)) {
      push (@rows,$q->td([@row]));
   }
   ZebraTable(\@rows);
   $sth->finish();
}

sub RemoveFromSuite {
   my $dbh = shift;
   my $sqlscript = " BEGIN
                        utpackage.rem (suite_in => utsuite.name_from_id(to_number(?)), package_in => ?);
                     END; ";
   my $sth = $dbh->prepare($sqlscript)
             or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute($suite_id, $package_name)
         or die "Cannot execute: " . $sth->errstr();
   $sth->finish();
   ShowSuitePackages($dbh);
}

sub ShowPackageResults {
   my $dbh = shift;
   my @rows;
   my $sql = " SELECT utp.NAME, utro.status, utro.description
                 FROM ut_package utp, utr_outcome utro
                WHERE utp.id = $package_id AND utp.last_run_id = utro.run_id
             ORDER BY $order_by $order";

   my $sth = $dbh->prepare($sql)
                   or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute
         or die "Cannot execute: " . $sth->errstr();

   push (@rows,$q->th(["Package Name".OrderSign("1"),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showpackageresults&amp;suite_id=$suite_id&amp;suite_name=$suite_name&amp;package_id=$package_id&amp;package_name=$package_name&amp;order_by=2&amp;order=".NextOrder()},"Status of Run".OrderSign("2")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showpackageresults&amp;suite_id=$suite_id&amp;suite_name=$suite_name&amp;package_id=$package_id&amp;package_name=$package_name&amp;order_by=3&amp;order=".NextOrder()},"Description of Test or Error".OrderSign("3")),
                       ]));
   while ((my @row = $sth->fetchrow_array)) {
      push (@rows,$q->td([@row]));
   }
   ZebraTable(\@rows);
   $sth->finish();
}

sub Train {
   if (   $action eq "showsuitepackages" || ($action eq "Add Package" && $tab ne "packages")
       || $action eq "removefromsuite" || $action eq "showpackageresults") {
      print $q->start_ul({-id=>"train"});
      if (   $action eq "showsuitepackages" || ($action eq "Add Package" && $tab ne "packages")
          || $action eq "removefromsuite"){
         print $q->li($q->a({-href=>"$uwi?tab=$tab&amp;action=showallsuites"}, "Suites"));
         print $q->li(">>  $suite_name");
      }
      if ($action eq "showpackageresults"){
         if ($tab eq "suites"){
            print $q->li($q->a({-href=>"$uwi?tab=$tab&amp;action=showallsuites"}, "Suites"));
            print $q->li(">>  ".$q->a({-href=>"$uwi?tab=$tab&amp;action=showsuitepackages&amp;suite_id=$suite_id&amp;suite_name=$suite_name"}, "$suite_name"));
            print $q->li(">>  $package_name");
         } elsif ($tab eq "packages"){
            print $q->li($q->a({-href=>"$uwi?tab=$tab&amp;action=showallpackages"}, "Packages"));
            print $q->li(">>  $package_name");
         }
      }
      print $q->end_ul;
   }
}

sub Navigator {
   my $table = shift;
   my $num_pages = ceil(@$table/$pagesize);

   if ($num_pages > 1) {
      print $q->start_ul({-id=>"navigator"});
      for (my $i=0; $i<$num_pages; $i++) {
         if ( (($i*$pagesize)+1) == $start) {
            print $q->li("$i"+1);
         } else {
            print $q->li($q->a({-href=>"$uwi?tab=$tab&amp;action=$action&amp;suite_id=$suite_id&amp;suite_name=$suite_name&amp;package_id=$package_id&amp;package_name=$package_name&amp;order_by=$order_by&amp;order=$order&amp;start=".(($i*$pagesize)+1)}, "$i"+1));
         }
      }
   }
   print $q->end_ul;
}

sub Footer {
   print $q->start_ul({-id=>"footer"});
   print $q->li($q->a({-href=>"http://utplsql.sourceforge.net/"}, "utPLSQL Project"));
   print $q->li($q->a({-href=>"http://utplsql.oracledeveloper.nl/"}, "utPLSQL Forums"));
   print $q->li($q->a({-href=>"http://groups.yahoo.com/group/utPLSQL-Info/"}, "utPLSQL Group"));
   print $q->li($q->a({-href=>"https://sourceforge.net/project/showfiles.php?group_id=6633"}, "utPLSQL Downloads"));
   print $q->li($q->a({-href=>"http://utplsql.oracledeveloper.nl/doc/index.html"}, "utPLSQL Documentation"));
   print $q->end_ul;
}

sub CreateSuiteForm {
   print $q->startform({id=>"input_form"}),
         "<fieldset>",
         $q->legend("Create Suite");

   print $q->label({-for=>"suite_name"}, "Suite Name"),
         $q->textfield(-name=>"suite_name", -id=>"suite_name",
                       -class=>"mandatory", -default=>"$suite_name",
                       -maxlength=>2000),
         $q->br;
   print $q->label({-for=>"suite_description"}, "Description"),
         $q->textfield(-name=>"suite_description", -id=>"suite_description",
                       -default=>"", -maxlength=>2000),
         $q->br;
   print $q->label({-for=>"rem_if_exists"}, "Replace Existing Suite"),
         $q->checkbox(-name=>"rem_if_exists", -id=>"rem_if_exists", -label=>"",
                      -checked=>, -value=>"TRUE"),
         $q->br;
   print $q->submit(-name=>"action", -class=>"submit_button",
                    -id=>"insert_suite", -value=>"Create Suite");
   print $q->reset(-name=>"Reset Form", -class=>"reset_button",
                   -id=>"reset_suite_form", -value=>"Reset Form");
   print "</fieldset>",
         $q->endform;
}

sub CreateNewSuite {
   my $dbh = shift;
   my $sqlscript = " DECLARE
                        FUNCTION to_bool (i VARCHAR2)
                           RETURN BOOLEAN
                        IS
                        BEGIN
                           IF (i IS NULL)
                           THEN
                              RETURN NULL;
                           ELSIF (   (UPPER(i) = 'F')
                                  OR (UPPER(i) = 'FALSE')
                                  OR (UPPER(i) = '0'))
                           THEN
                              RETURN FALSE;
                           ELSE
                              RETURN TRUE;
                           END IF;
                        END;
                     BEGIN
                        utsuite.add (name_in => :name_in,
                                     desc_in => :desc_in,
                                     rem_if_exists_in => to_bool(:rem_if_exists_in));
                      END; ";

   eval {
      my $sth = $dbh->prepare($sqlscript)
                      or die "Cannot prepare: " . $dbh->errstr();
      $sth->bind_param(":name_in", $q->param("suite_name"));
      $sth->bind_param(":desc_in", $q->param("suite_description"));
      $sth->bind_param(":rem_if_exists_in", $q->param("rem_if_exists"));
      $sth->execute or die "Cannot execute: " . $sth->errstr();
      $sth->finish();
   };

   if( $@ ) {
      warn "Execution of stored procedure failed: $DBI::errstr\n";
      $dbh->rollback;
   } else {
      $dbh->commit;
   };
   ShowAllSuites($dbh);
}

sub AddPackageToSuiteForm {
   my $dbh = shift;
   print $q->startform({id=>"input_form"}),
         "<fieldset>",
         $q->legend("Add Package To Suite $suite_name");

   print $q->hidden(-name=>"tab", -default=>"$tab");
   if ($suite_id eq "") {
      print $q->label({-for=>"suite_name"}, "Suite Name");
      print $q->popup_menu(-name=>"suite_name",
                           -values=> GetSuites($dbh));
      print $q->br;

   } else {
      print $q->hidden(-name=>"suite_id", -id=>"suite_id", -class=>"mandatory",
                       -default=>"$suite_id", -maxlength=>2000);
      print $q->hidden(-name=>"suite_name", -id=>"suite_name", -class=>"mandatory",
                       -default=>"$suite_name", -maxlength=>2000);
   }

   print $q->label({-for=>"package_name"}, "Package Name");
   print $q->textfield(-name=>"package_name", -id=>"package_name",
                       -class=>"mandatory", -default=>"", -maxlength=>2000);
   print $q->br;
   print $q->submit(-name=>"action", -class=>"submit_button",
                    -id=>"insert_package", -value=>"Add Package");
   print $q->reset(-name=>"Reset Form", -class=>"reset_button",
                   -id=>"reset_package_form", -value=>"Reset Form");
   print "</fieldset>",
         $q->endform;
}

sub AddPackageToSuite {
   my $dbh = shift;
   my $sqlscript = " BEGIN
                        utpackage.add (suite_in => :suite_name,
                                       package_in => :package_name);
                      END; ";

   eval {
      my $sth = $dbh->prepare($sqlscript)
                      or die "Cannot prepare: " . $dbh->errstr();
      $sth->bind_param(":suite_name", $q->param("suite_name"));
      $sth->bind_param(":package_name", $q->param("package_name"));
      $sth->execute or die "Cannot execute: " . $sth->errstr();
      $sth->finish();
   };

   if( $@ ) {
      warn "Execution of stored procedure failed: $DBI::errstr\n";
      $dbh->rollback;
   } else {
      $dbh->commit;
   };
   ShowSuitePackages($dbh);
}

sub ShowAllPackages {
   my $dbh = shift;
   my @rows;
   my $sql = " SELECT NAME AS PACKAGENAME,
                         '<a href=''$uwi?tab=$tab&amp;action=showpackageresults&amp;suite_name=$suite_name&amp;suite_id='
                   || up.suite_id
                   || '&amp;package_id='
                   || up.id
                   || '&amp;package_name='
                   || up.name
                   || '''>'
                   || up.last_status
                   || '</A>' AS laststatus,
                   up.executions, up.failures,
                   TO_CHAR (up.last_end, 'DD-MON-YYYY HH24:MI:SS') AS last_end,
                   TO_NUMBER (
                      ROUND (
                         (  up.last_end
                          - up.last_start
                         ) * 24 * 60 * 60
                      )
                   ) AS last_duration,
                      '<a href=''$uwi?tab=$tab&amp;action=runpackage&amp;order_by=$order_by&amp;order=$order'
                   || '&amp;package_id='
                   || up.id
                   || '&amp;package_name='
                   || up.name
                   || '''>Run</A>' AS run,
                      '<a href=''$uwi?tab=$tab&amp;action=removepackage&amp;order_by=$order_by&amp;order=$order&amp;package_name='
                   || up.NAME
                   || '&amp;package_id='
                   || up.id
                   || '''>Remove</A>' AS remove
              FROM ut_package up
             WHERE up.suite_id IS NULL
          ORDER BY $order_by $order";

   my $sth = $dbh->prepare($sql)
                   or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute
         or die "Cannot execute: " . $sth->errstr();

   push (@rows,$q->th([$q->a({-href=>"$uwi?tab=$tab&amp;action=showallpackages&amp;order_by=name&amp;order=".NextOrder()},"Package Name".OrderSign("name")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showallpackages&amp;order_by=last_status&amp;order=".NextOrder()},"Status of Run".OrderSign("last_status")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showallpackages&amp;order_by=executions&amp;order=".NextOrder()},"# Runs".OrderSign("executions")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showallpackages&amp;order_by=failures&amp;order=".NextOrder()},"# Failed Runs".OrderSign("failures")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showallpackages&amp;order_by=last_end&amp;order=".NextOrder()},"Last Run Date".OrderSign("last_end")),
                       $q->a({-href=>"$uwi?tab=$tab&amp;action=showallpackages&amp;order_by=last_duration&amp;order=".NextOrder()},"Run Time (sec)".OrderSign("last_duration")),
                       "Run",
                       "Remove"
                       ]));
   while ((my @row = $sth->fetchrow_array)) {
      push (@rows,$q->td([@row]));
   }
   ZebraTable(\@rows);
   $sth->finish();
}

sub AddPackageForm {
   print $q->startform({id=>"input_form"}),
         "<fieldset>",
         $q->legend("Add Package");

   print $q->hidden(-name=>"tab", -default=>"$tab");
   print $q->label({-for=>"package_name"}, "Package Name");
   print $q->textfield(-name=>"package_name", -id=>"package_name",
                       -class=>"mandatory", -default=>"", -maxlength=>2000);
   print $q->br;
   print $q->submit(-name=>"action", -class=>"submit_button",
                    -id=>"insert_package", -value=>"Add Package");
   print $q->reset(-name=>"Reset Form", -class=>"reset_button",
                   -id=>"reset_package_form", -value=>"Reset Form");
   print "</fieldset>",
         $q->endform;
}

sub AddPackage {
   my $dbh = shift;
   my $sqlscript = " BEGIN
                        utpackage.add (suite_in => :suite_name,
                                       package_in => :package_name);
                      END; ";

   eval {
      my $sth = $dbh->prepare($sqlscript)
                      or die "Cannot prepare: " . $dbh->errstr();
      $sth->bind_param(":suite_name", "");
      $sth->bind_param(":package_name", $q->param("package_name"));
      $sth->execute or die "Cannot execute: " . $sth->errstr();
      $sth->finish();
   };

   if( $@ ) {
      warn "Execution of stored procedure failed: $DBI::errstr\n";
      $dbh->rollback;
   } else {
      $dbh->commit;
   };
   ShowAllPackages($dbh);
}

sub RunPackage {
   my $dbh = shift;
   my $sqlscript = " BEGIN
                        utPLSQL.test (?, recompile_in => FALSE);
                     END; ";
   my $sth = $dbh->prepare($sqlscript)
             or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute($package_name)
         or die "Cannot execute: " . $sth->errstr();
   $sth->finish();
   ShowAllPackages($dbh);
}

sub RemovePackage {
   my $dbh = shift;
   my $sqlscript = " BEGIN
                        utpackage.rem (suite_in => ?, package_in => ?);
                     END; ";
   my $sth = $dbh->prepare($sqlscript)
             or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute($suite_name, $package_name)
         or die "Cannot execute: " . $sth->errstr();
   $sth->finish();
   ShowAllPackages($dbh);
}

sub LogonCookie {
   my %logoninfo = $q->Vars;
   my $expiration_date = "";

   if ( $logoninfo{"db_info_remember"} ) {
      $expiration_date = $logoninfo{"db_info_remember"};
   }
   delete $logoninfo{"db_info_remember"};
   delete $logoninfo{"action"};
   my $cookie = $q->cookie(-name=>"logoninfo",
                           -expires=>$expiration_date,
                           -value=>\%logoninfo);
   return $cookie;
}

sub LogonForm {
   print $q->startform(-id=>"input_form"),#, -action=>"$uwi?tab=suites&amp;action=showallsuites"),
         "<fieldset>",
         $q->legend("Logon");

   print $q->label({-for=>"db_user"}, "User Name");
   print $q->textfield(-name=>"db_user", -id=>"db_user",
                       -class=>"mandatory", -default=>"", -maxlength=>2000);
   print $q->br;
   print $q->label({-for=>"db_pwd"}, "Password");
   print $q->password_field(-name=>"db_pwd", -id=>"db_pwd",
                            -class=>"mandatory", -default=>"", -maxlength=>2000);
   print $q->br;
   print $q->label({-for=>"db_name"}, "Database");
   print $q->textfield(-name=>"db_name", -id=>"db_name",
                       -class=>"mandatory", -default=>"", -maxlength=>2000);
   print $q->br;
   print $q->label({-for=>"db_host"}, "Host");
   print $q->textfield(-name=>"db_host", -id=>"db_host",
                       -default=>"", -maxlength=>2000);
   print $q->br;
   print $q->label({-for=>"db_port"}, "Port");
   print $q->textfield(-name=>"db_port", -id=>"db_port",
                       -default=>"", -maxlength=>2000);
   print $q->br;
   print $q->label({-for=>"db_info_remember"}, "Remember Logon Info");
   print $q->checkbox(-name=>"db_info_remember", -id=>"db_info_remember",
                      -label=>"", -checked=>"checked", -value=>"+3M");
   print $q->br;
   print $q->submit(-name=>"action", -class=>"submit_button",
                    -id=>"connect", -value=>"Connect");
   print $q->reset(-name=>"Reset Form", -class=>"reset_button",
                   -id=>"reset_connect_form", -value=>"Reset Form");
   print "</fieldset>",
         $q->endform;
   print '<div id="noconnect">';
   print 'I do not want to connect or I have problems connecting to my database, please take me to the ' .$q->a({-href=>"$uwi?tab=about&amp;action=showabout"},"About pages"). ' (no connection necessary).';
   print '</div>';
}

sub ConnectToDb {
   my %ConnAttr;
   my $dbh;
   $ConnAttr{"RaiseError"} = 1;
   $ConnAttr{"AutoCommit"} = 0;
   my $user = $_[0];
   my $pwd = $_[1];
   if ( !@_[3] ) {
      my $db = $_[2];
      $dbh = DBI->connect("DBI:Oracle:$db", $user, $pwd, \%ConnAttr);
   } else {
      my $sid = $_[2];
      my $host = $_[3];
      if ( !@_[4] ) {
         $dbh = DBI->connect("dbi:Oracle:host=$host;sid=$sid", $user, $pwd, \%ConnAttr);
      } else {
         my $port = $_[4];
         $dbh = DBI->connect("dbi:Oracle:host=$host;sid=$sid;port=$port", $user, $pwd, \%ConnAttr);
      }
   }
   return $dbh;
}

sub UwiVersion {
   my $version = '1.1.2';
   return $version;
}

sub About {
   print '<div id="about">';
   print '<b>Welcome to uWI, the utPLSQL Web Interface.</b>';
   print '<p>uWI is a Web Application that helps you manage your utPLSQL tests, both Test Suites and Individual Test Packages.  ';
   print 'It allows you to create Suites, add or remove Tests Packages to them and run them.  ';
   print 'You can easily see the results of your tests and drill down all the way to the individual test making it extremely easy to identify which test fails (if any).  ';
   print '</p>';
   print '<p>Because uWI is a Web Application, it runs on any platform, all you need is a Web Browser.  ';
   print 'If you are interested in hosting uWI yourself, feel free to '.$q->a({-href=>"mailto:markvilrokx\@hotmail.com"},"contact me").' for the source code and installation instructions.  ';
   print '</p>';
   print '<p>uWI was written in such a way that form (how it looks) and function (how it works) are completely seperated.  ';
   print 'It is using a Cascading Style Sheet called uwi.css which controls the looks.  ';
   print 'I happen to like gray, but if you don\'t, and you are a bit handy with CSS, you can make it look anyway you want by just manipulating the uwi.css file.  ';
   print '</p>';
   print '<br>';
   print $q->a({-href=>"$uwi?tab=suites&amp;action=showallsuites"},"Now Get Started!").'<br>';
   print '<br>';
   print 'Happy Testing.<br>';
   print '<br>';
   print 'Cheers,<br>';
   print 'Mark.<br>';
   print '</p>';
   print '<p>';
   print '<b>Version History:</b>';
   print '</p>';
   print '<p>';
   print '1.1.2: Final preparations for official release, made uWIscheduler dependant on DB Version';
   print '</p>';
   print '<p>';
   print '1.1.1: e-mail address I provided was wrong, corrected';
   print '</p>';
   print '<p>';
   print '1.1.0: Introduction of uWI Scheduler (only works on 10g)';
   print '</p>';
   print '<p>';
   print '1.0.3: Added LOV for Suite Names in Add Suite Form';
   print '</p>';
   print '<p>';
   print '1.0.2: Made generated HTML code XHTML Compliant.';
   print '</p>';
   print '<p>';
   print '1.0.1: Beautified/Simplified the code for improved maintainability';
   print '</p>';
   print '<p>';
   print '1.0.0: First Offical release';
   print '</p>';
   print '</div>';
}

sub Copyright {
   print '<div id="copyright">';
   print '<p>&copy; Copyright 2004 - 2005   '.$q->a({-href=>"mailto:markvilrokx\@hotmail.com"},"Mark Vilrokx").' and the utPLSQL Project</p>';
   print '</div>';
}

sub SysInfo {
   my $logoninfo = shift;

   my @rows;
   push (@rows,$q->th(["System Variable","Value"]));

   push (@rows,$q->td("uWI Version").$q->td(UwiVersion));

   eval {
      $dbh = ConnectToDb($logoninfo{"db_user"},
               $logoninfo{"db_pwd"},
               $logoninfo{"db_name"},
               $logoninfo{"db_host"},
               $logoninfo{"db_port"});

      my $sql = "SELECT 'utPLSQL Version', utplsql.version from dual";
      my $sth = $dbh->prepare($sql) or die "Cannot prepare: " . $dbh->errstr();
      $sth->execute or die "Cannot execute: " . $sth->errstr();
      while ((my @row = $sth->fetchrow_array)) {
         push (@rows,$q->td([@row]));
      }

      my $sql = "SELECT 'Oracle Database Version Part '||rownum, banner from v\$version";
      my $sth = $dbh->prepare($sql) or die "Cannot prepare: " . $dbh->errstr();
      $sth->execute or die "Cannot execute: " . $sth->errstr();
       while ((my @row = $sth->fetchrow_array)) {
         push (@rows,$q->td([@row]));
      }
      $sth->finish();
   };
      
   if( $@ ) {
      push (@rows,$q->td("uWI Version").$q->td("<b>Not Connected!</b>"));
      push (@rows,$q->td("Oracle Database Version").$q->td("<b>Not Connected!</b>"));
   } else {
      $dbh->commit;
   };

#   } else {
#      push (@rows,$q->td("uWI Version").$q->td("<b>Not Connected!</b>"));
#      push (@rows,$q->td("Oracle Database Version").$q->td("<b>Not Connected!</b>"));
#   }

   push (@rows,$q->td("Perl Version").$q->td("$]"));
   push (@rows,$q->td("CGI Version").$q->td("$CGI::VERSION"));
   push (@rows,$q->td("DBI Version").$q->td("$DBI::VERSION"));
   push (@rows,$q->td("DBD::Oracle Version").$q->td("$DBD::Oracle::VERSION"));
   push (@rows,$q->td("Browser").$q->td(CGI::user_agent()));
   push (@rows,$q->td("Remote Host").$q->td(CGI::remote_host()));
#   push (@rows,$q->td("Remote User (i.e you)").$q->td(CGI::remote_user()));
   push (@rows,$q->td("Web Server").$q->td(CGI::server_software ()));
   push (@rows,$q->td("Server Name").$q->td(CGI::server_name()));

   ZebraTable(\@rows);

}

sub Faq {
   print '<div id="faq">';
   print '<b>Why can\'t I connect to my database?</b>';
   print '<p>There are several reasons as to why you are unable to connect to your database.  ';
   print 'First of all, make sure that the logon parameters you provide are correct.  ';
   print 'Because I do not have your Database Connection settings on my Webserver, you <i>have</i> to provide a Host and Port.  ';
   print 'You can find these in your local TNSNAMES.ora file.  ';
   print '</p>';
   print '<p>';
   print 'If you are sure the parameters are correct, but you still cannot connect to your database, it means that your database is not Web-enabled, i.e. it is inaccessable over the internet and so I cannot connect to it.  ';
   print 'You will have to Web-enable your database for me to be able to connect to it.  ';
   print 'Now I am well aware that not everybody is willing to do this, which leaves you with 2 options:  ';
   print 'You connect to my database and you have a test drive, see if you like uWI.  ';
   print 'Please contact '.$q->a({-href=>"mailto:markvilrokx\@hotmail.com"},"me").' for login details.  ';
   print 'Or, I just give you the perl script and you run it on your own webserver, then you don\'t need to Web-enable your Database as it runs on the same machine or Intranet as your Webserver (you then do not need to provide a host and port name, it will use your local TNSNAMES.ora file).  ';
   print 'Please contact '.$q->a({-href=>"mailto:markvilrokx\@hotmail.com"},"me").' for the perl script and installation instructions.  ';
   print '</p>';
   print '<p>';
   print $q->a({-href=>"mailto:markvilrokx\@hotmail.com"},"Submit a New Question");
   print '</p>';
   print '</div>';
}

sub GetSuites {
   my $dbh = shift;
   my @rows;
   my $sql = " SELECT name
                 FROM ut_suite
             ORDER BY name";

   my $sth = $dbh->prepare($sql)
                   or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute
         or die "Cannot execute: " . $sth->errstr();

   while ((my @row = $sth->fetchrow_array)) {
      push (@rows,@row);
   }
   $sth->finish();
   return \@rows;
}

sub ShowAllScheduledJobs {
   my $dbh = shift;
   my @rows;
   if (DBVersion($dbh) =~ m/10\..*/) {
      my $sql = " SELECT job_name name,
                         to_char(start_date,'DD-MON-YYYY HH24:MI:SS'),
                         repeat_interval,
                         to_char(next_run_date,'DD-MON-YYYY HH24:MI:SS'),
                         end_date,
                         state,
                         DECODE(enabled,
                                'TRUE',
                                '<a href=''$uwi?tab=$tab&amp;action=disablejob&amp;job_name='|| job_name||'''>'||enabled||'</A>',
                                '<a href=''$uwi?tab=$tab&amp;action=enablejob&amp;job_name='|| job_name||'''>'||enabled||'</A>') AS enabled,
                         '<a href=''$uwi?tab=$tab&amp;action=dropjob&amp;job_name='|| job_name||'''>Remove</A>' AS Remove
                    FROM user_scheduler_jobs
                ORDER BY $order_by $order";

      my $sth = $dbh->prepare($sql)
                      or die "Cannot prepare: " . $dbh->errstr();
      $sth->execute
            or die "Cannot execute: " . $sth->errstr();

      push (@rows,$q->th([$q->a({-href=>"$uwi?tab=$tab&amp;action=showallscheduledjobs&amp;order_by=job_name&amp;order=".NextOrder()},"Job Name".OrderSign("job_name")),
                          $q->a({-href=>"$uwi?tab=$tab&amp;action=showallscheduledjobs&amp;order_by=start_date&amp;order=".NextOrder()},"Start Date".OrderSign("start_date")),
                          $q->a({-href=>"$uwi?tab=$tab&amp;action=showallscheduledjobs&amp;order_by=repeat_interval&amp;order=".NextOrder()},"Repeat Interval".OrderSign("repeat_interval")),
                          $q->a({-href=>"$uwi?tab=$tab&amp;action=showallscheduledjobs&amp;order_by=next_run_date&amp;order=".NextOrder()},"Next Run Date".OrderSign("next_run_date")),
                          $q->a({-href=>"$uwi?tab=$tab&amp;action=showallscheduledjobs&amp;order_by=end_date&amp;order=".NextOrder()},"End Date".OrderSign("end_date")),
                          $q->a({-href=>"$uwi?tab=$tab&amp;action=showallscheduledjobs&amp;order_by=state&amp;order=".NextOrder()},"State".OrderSign("state")),
                          "Enabled",
                          "Remove"
                          ]));
      while ((my @row = $sth->fetchrow_array)) {
         push (@rows,$q->td([@row]));
      }
      ZebraTable(\@rows);
      $sth->finish();
   } else {
      ShowUnavailableFeature();
   }
}

sub AddJobForm {
   my $dbh = shift;
   if (DBVersion($dbh) =~ m/10\..*/) {
      print $q->startform({id=>"input_form"}),
            "<fieldset>",
            $q->legend("Add Job");

      print $q->hidden(-name=>"tab", -default=>"$tab");

      print $q->label({-for=>"job_name"}, "Job Name");
      print $q->textfield(-name=>"job_name", -id=>"job_name",
                          -class=>"mandatory", -default=>"", -maxlength=>2000);
      print $q->br;

      print $q->label({-for=>"suite_name"}, "Suite Name");
      print $q->popup_menu(-name=>"suite_name",
                           -values=> GetSuites($dbh));
      print $q->br;

      print $q->label({-for=>"start_date"}, "Start Date");
      print $q->textfield(-name=>"start_date", -id=>"start_date",
                          -class=>"mandatory", -default=>"", -maxlength=>2000);
      print $q->br;


      print $q->label({-for=>"freq"}, "Frequency");
      print $q->popup_menu(-name=>"freq",
                           -values=> [qw/SECONDLY MINUTELY HOURLY DAILY WEEKLY MONTHLY YEARLY/]);
      print $q->br;

      print $q->label({-for=>"interval"}, "Interval");
      print $q->textfield(-name=>"interval", -id=>"interval",
                          -default=>"", -maxlength=>3);
      print $q->br;

      print $q->label({-for=>"dates"}, "Dates");
      print $q->textfield(-name=>"dates", -id=>"dates",
                          -default=>"", -maxlength=>2000);
      print $q->br;

#   print $q->label({-for=>"bymonth"}, "Month");
#   print $q->scrolling_list(-name=>"bymonth",
#                            -values=> ["", qw/JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC/],
#                            -size=>5,
#                            -labels=>{""=>"", "JAN"=>"January", "FEB"=>"February",
#                                      "MAR"=>"March", "APR"=>"April", "MAY"=>"May",
#                                      "JUN"=>"June", "JUL"=>"July", "AUG"=>"August",
#                                      "SEP"=>"September", "OCT"=>"October",
#                                      "NOV"=>"November", "DEC"=>"December"},
#                            -multiple=>"true");
#   print $q->br;

#   print $q->label({-for=>"byweekno"}, "Week Number");
#   print $q->scrolling_list(-name=>"byweekno",
#                            -values=> ["", qw/1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53/],
#                            -size=>5,
#                            -multiple=>"true");
#   print $q->br;

#   print $q->label({-for=>"byyearday"}, "Year Day Number");
#   print $q->textfield(-name=>"byyearday", -id=>"byyearday",
#                       -default=>"", -maxlength=>3);
#   print $q->br;

#   print $q->label({-for=>"bymonthday"}, "Month Day Number");
#   print $q->textfield(-name=>"bymonthday", -id=>"bymonthday",
#                       -default=>"", -maxlength=>2);
#   print $q->br;

#   print $q->label({-for=>"byday"}, "Day of Week");
#   print $q->popup_menu(-name=>"byday",
#                        -values=> ["", qw/MON TUE WED THU FRI SAT SUN/],
#                        -labels=>{""=>"", "MON"=>"Monday", "TUE"=>"Tuesday",
#                                  "WED"=>"Wednesday", "THU"=>"Thursday",
#                                  "FRI"=>"Friday", "SAT"=>"Saturday",
#                                  "SUN"=>"Sunday"});
#   print $q->br;

#   print $q->label({-for=>"byday"}, "Day");
#   print $q->popup_menu(-name=>"byday",
#                        -values=> ["", qw/1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31/]);
#   print $q->br;

      print $q->label({-for=>"end_date"}, "End Date");
      print $q->textfield(-name=>"end_date", -id=>"end_date",
                          -default=>"", -maxlength=>2000);
      print $q->br;

      print $q->label({-for=>"comments"}, "Comments");
      print $q->textfield(-name=>"comments", -id=>"v",
                          -default=>"", -maxlength=>2000);
      print $q->br;
      print $q->submit(-name=>"action", -class=>"submit_button",
                       -id=>"insert_job", -value=>"Add Job");
      print $q->reset(-name=>"Reset Form", -class=>"reset_button",
                      -id=>"reset_job_form", -value=>"Reset Form");
      print "</fieldset>",
            $q->endform;
   } else {
      ShowUnavailableFeature();
   }
}

sub AddJob {
   my $dbh = shift;
   my $suite_name = $q->param("suite_name");
   my $repeat_interval;
   
   $repeat_interval = "freq=".$q->param("freq")."; ";
   if ($q->param("interval")) {
      $repeat_interval = $repeat_interval."interval=".$q->param("interval")."; ";
   }
   if ($q->param("dates")) {
      $repeat_interval = $repeat_interval.$q->param("dates");
   }

   my $sqlscript = " BEGIN
                        dbms_scheduler.create_job (job_name => :job_name,
                                                   job_type => 'PLSQL_BLOCK',
                                                   job_action => 'BEGIN
                                                                     utPLSQL.testsuite ($suite_name, recompile_in => FALSE);
                                                                  END;',
                                                   start_date => to_date(:start_date,'DD-MON-YYYY HH24:MI:SS'),
                                                   repeat_interval => '$repeat_interval',
                                                   end_date => to_date(:end_date,'DD-MON-YYYY HH24:MI:SS'),
                                                   enabled => TRUE,
                                                   comments => :comments);

                     END; ";

   eval {
      my $sth = $dbh->prepare($sqlscript)
                      or die "Cannot prepare: " . $dbh->errstr();
      $sth->bind_param(":job_name", $q->param("job_name"));
      $sth->bind_param(":start_date", $q->param("start_date"));
      $sth->bind_param(":end_date", $q->param("end_date"));
      $sth->bind_param(":comments", $q->param("comments"));
      $sth->execute or die "Cannot execute: " . $sth->errstr();
      $sth->finish();
   };

   if( $@ ) {
      warn "Execution of stored procedure failed: $DBI::errstr\n";
      $dbh->rollback;
   } else {
      $dbh->commit;
   };
   ShowAllScheduledJobs($dbh);
}

sub DisableJob {
   my $dbh = shift;
   my $job_name = $q->param("job_name");
   my $sqlscript = " BEGIN
                        dbms_scheduler.disable (name => :job_name);
                     END; ";

   eval {
      my $sth = $dbh->prepare($sqlscript)
                      or die "Cannot prepare: " . $dbh->errstr();
      $sth->bind_param(":job_name", $q->param("job_name"));
      $sth->execute or die "Cannot execute: " . $sth->errstr();
      $sth->finish();
   };

   if( $@ ) {
      warn "Execution of stored procedure failed: $DBI::errstr\n";
      $dbh->rollback;
   } else {
      $dbh->commit;
   };
   ShowAllScheduledJobs($dbh);
}

sub EnableJob {
   my $dbh = shift;
   my $job_name = $q->param("job_name");
   my $sqlscript = " BEGIN
                        dbms_scheduler.enable (name => :job_name);
                     END; ";

   eval {
      my $sth = $dbh->prepare($sqlscript)
                      or die "Cannot prepare: " . $dbh->errstr();
      $sth->bind_param(":job_name", $q->param("job_name"));
      $sth->execute or die "Cannot execute: " . $sth->errstr();
      $sth->finish();
   };

   if( $@ ) {
      warn "Execution of stored procedure failed: $DBI::errstr\n";
      $dbh->rollback;
   } else {
      $dbh->commit;
   };
   ShowAllScheduledJobs($dbh);
}

sub DropJob {
   my $dbh = shift;
   my $job_name = $q->param("job_name");
   my $sqlscript = " BEGIN
                        dbms_scheduler.drop_job (job_name => :job_name);
                     END; ";

   eval {
      my $sth = $dbh->prepare($sqlscript)
                      or die "Cannot prepare: " . $dbh->errstr();
      $sth->bind_param(":job_name", $q->param("job_name"));
      $sth->execute or die "Cannot execute: " . $sth->errstr();
      $sth->finish();
   };

   if( $@ ) {
      warn "Execution of stored procedure failed: $DBI::errstr\n";
      $dbh->rollback;
   } else {
      $dbh->commit;
   };
   ShowAllScheduledJobs($dbh);
}

sub DBVersion {
   my $dbh = shift;
   my @rows;

   my $sql = "SELECT version
                FROM product_component_version
               WHERE product like 'Oracle%'";
   my $sth = $dbh->prepare($sql) or die "Cannot prepare: " . $dbh->errstr();
   $sth->execute or die "Cannot execute: " . $sth->errstr();
   while ((my @row = $sth->fetchrow_array)) {
      push (@rows,$q->td([@row]));
   }
   return $rows[0];
}

sub ShowUnavailableFeature {
   print '<div id="unavailable_feature">';
   print '<p>This feature is not available on this DB release.</p>';
   print '</div>';
}

