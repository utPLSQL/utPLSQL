create or replace package mystats_pkg authid current_user as

   /*
   || ----------------------------------------------------------------------------
   ||
   || Utility:     MyStats
   ||
   || Package:     MYSTATS_PKG
   ||
   || Script:      mystats_pkg.sql
   ||
   || Version:     3.0
   ||
   || Author:      Adrian Billington
   ||              www.oracle-developer.net
   ||              (c) oracle-developer.net
   ||
   || Description: PL/SQL-only version of Jonathan Lewis's SNAP_MY_STATS package.
   ||              This package is used to output the resource usage as recorded
   ||              in V$MYSTAT and V$LATCH.
   ||
   ||              Key Differences
   ||              ---------------
   ||
   ||                 a) All logic is encapsulated in a single PL/SQL package
   ||                    (no stats view);
   ||
   ||                 b) This uses invoker rights and dynamic SQL to workaround
   ||                    the sites where developers cannot get explicit grants
   ||                    on the required V$ views, but instead have access via
   ||                    roles or other privileges;
   ||
   ||                 c) This includes latch statistics and makes use of Tom
   ||                    Kyte's RUNSTATS method for distinguising between stats
   ||                    and latches;
   ||
   ||                 d) This includes advanced reporting options (see Usage
   ||                    section below for details);
   ||
   ||                 e) This includes a session time model report;
   ||
   ||                 f) This requires at least version 10.1 to run because it
   ||                    makes use of collection methods such as MEMBER OF and
   ||                    also reports on V$SESS_TIME_MODEL statistics.
   ||
   || Usage:           exec mystats_pkg.ms_start( [optional statistics include/exclude parameters] )
   ||                  --<do some work>--
   ||                  exec mystats_pkg.ms_stop( [optional reporting parameters] )
   ||
   ||                  Optional statistics types are selected during calls to the MS_START procedure
   ||                  and are all included by default:
   ||
   ||                     1. Statistics (V$SESSTAT)
   ||                     2. Latches    (V$LATCH)
   ||                     3. Time Model (V$SESS_TIME_MODEL)
   ||
   ||                  Optional reporting parameters are specified during calls to the MS_STOP procedure
   ||                  and take one of the following formats:
   ||
   ||                     1. Threshold (numeric, using P_THRESHOLD parameter (numeric))
   ||                     2. Statistic names (array of statnames, using P_STATNAMES parameter (collection))
   ||                     3. Statistic name LIKE pattern (statname pattern, using P_STATNAME_LIKE parameter (string))
   ||                     4. Statistic name REGEXP pattern (statname pattern, using P_STATNAME_LIKE and P_USE_REGEXP parameters (string and boolean))
   ||
   ||                  See examples below.
   ||
   ||              1. Output all statistics
   ||              -------------------------------------------------------------
   ||              exec mystats_pkg.ms_start;
   ||              --<do some work>--
   ||              exec mystats_pkg.ms_stop;
   ||
   ||              2. Output statistics with delta values >= 1,000
   ||              -------------------------------------------------------------
   ||              exec mystats_pkg.ms_start;
   ||              --<do some work>--
   ||              exec mystats_pkg.ms_stop(p_threshold=>1000);
   ||
   ||              3. Output statistics for "redo size" and "user commits" only
   ||              -------------------------------------------------------------
   ||              exec mystats_pkg.ms_start;
   ||              --<do some work>--
   ||              exec mystats_pkg.ms_stop(p_statnames=>mystats_pkg.statname_ntt('redo size', 'user commits'));
   ||
   ||              4. Output statistics for those containing the word 'memory'
   ||              -----------------------------------------------------------
   ||              exec mystats_pkg.ms_start;
   ||              --<do some work>--
   ||              exec mystats_pkg.ms_stop(p_statname_like=>'memory');
   ||
   ||              5. Output statistics for those with I/O, IO, i/o or io in the name
   ||              ------------------------------------------------------------------
   ||              exec mystats_pkg.ms_start;
   ||              --<do some work>--
   ||              exec mystats_pkg.ms_stop(p_statname_like=>'I/?O\s', p_use_regexp=>true);
   ||
   ||              6. Capture and output statistics and time model only (exclude latches)
   ||              ----------------------------------------------------------------------
   ||              exec mystats_pkg.ms_start(p_include_latches=>false);
   ||              --<do some work>--
   ||              exec mystats_pkg.ms_stop;
   ||
   ||              7. Output statistics only for those containing 'parallel'
   ||              -------------------------------------------------------------
   ||              exec mystats_pkg.ms_start(p_include_latches=>false, p_include_time_model=>false);
   ||              --<do some work>--
   ||              exec mystats_pkg.ms_stop(p_statname_like=>'parallel');
   ||
   || Notes:       1. Serveroutput must be on (and set higher than default);
   ||
   ||              2. See http://www.jlcomp.demon.co.uk/snapshot.html for original
   ||                 version.
   ||
   ||              3. A free-standing, SQL*Plus-script version of MyStats is also
   ||                 available. The script version works without creating any
   ||                 database objects.
   ||
   || Disclaimer:  http://www.oracle-developer.net/disclaimer.php
   ||
   || ----------------------------------------------------------------------------
   */

   type statname_ntt is table of varchar2(64);

   procedure ms_start( p_include_statistics in boolean default true,
                       p_include_latches    in boolean default true,
                       p_include_time_model in boolean default true );

   procedure ms_stop;

   procedure ms_stop( p_threshold in integer );

   procedure ms_stop( p_statnames in mystats_pkg.statname_ntt );

   procedure ms_stop( p_statname_like in varchar2,
                      p_use_regexp    in boolean default false );

end mystats_pkg;
/

create or replace package body mystats_pkg as

   -- A range of (sub)types for capturing statistics information...
   -- -------------------------------------------------------------
   subtype st_option_flag is varchar2(1);
   subtype st_stattype    is varchar2(6);
   subtype st_statname    is varchar2(64);
   subtype st_statvalue   is integer;
   subtype st_output      is varchar2(255);

   type rt_statistic is record
   ( type  st_stattype
   , name  st_statname
   , value st_statvalue );

   type aat_statistic is table of rt_statistic
      index by st_statname;

   type aat_mystats is table of aat_statistic
      index by pls_integer;

   -- This is the "mystats array" to hold two snapshots...
   -- ----------------------------------------------------
   ga_mystats aat_mystats;

   -- Array offsets into the main mystats array, used to
   -- determine the start and end points of a run...
   -- --------------------------------------------------
   c_run1 constant pls_integer := 1;
   c_run2 constant pls_integer := 2;

   -- Globals for elapsed time calculation...
   -- ---------------------------------------
   type rt_time is record
   ( ela_time integer
   , cpu_time integer );

   g_start_time rt_time;
   g_end_time   rt_time;

   -- Globals to capture snapshot options...
   g_include_statistics st_option_flag;
   g_include_latches    st_option_flag;
   g_include_time_model st_option_flag;

   ------------------------------------------------------------------------------
   procedure ms_options( p_threshold       in pls_integer,
                         p_statnames       in mystats_pkg.statname_ntt,
                         p_statname_like   in varchar2,
                         p_statname_regexp in varchar2 ) is
      v_filter varchar2(4000);
   begin
      dbms_output.put('- Statistics types : ');
      dbms_output.put('statistics=' || g_include_statistics || ', ');
      dbms_output.put('latches=' || g_include_latches || ', ');
      dbms_output.put_line('time model=' || g_include_time_model);
      if p_threshold is not null then
         v_filter := 'threshold=' || p_threshold;
      elsif p_statname_like is not null then
         v_filter := 'statnames like=' || p_statname_like || ', regular expression=N';
      elsif p_statname_regexp is not null then
         v_filter := 'statnames like=' || p_statname_regexp || ', regular expression=Y';
      elsif p_statnames is not null and p_statnames is not empty then
         v_filter := 'statnames in=';
         for i in 1 .. p_statnames.count loop
            v_filter := v_filter || p_statnames(i) || ',';
         end loop;
         v_filter := rtrim(v_filter, ',');
      else
         v_filter := 'None';
      end if;
      dbms_output.put_line('- Reporting filter : ' || v_filter);
   end ms_options;

   ------------------------------------------------------------------------------
   procedure ms_info is
   begin
      dbms_output.put_line('- MyStats v3.0 by Adrian Billington (http://www.oracle-developer.net)');
      dbms_output.put_line('- Based on the SNAP_MY_STATS utility by Jonathan Lewis');
   end ms_info;

   ------------------------------------------------------------------------------
   procedure ms_snap( p_run      in pls_integer,
                      p_mystats  in out nocopy aat_mystats,
                      p_time     in out rt_time ) is

      rc_stat sys_refcursor;
      type aat_statistic is table of rt_statistic
         index by pls_integer;
      aa_stats  aat_statistic;

      procedure snap_time is
      begin
         p_time.ela_time := dbms_utility.get_time;
         p_time.cpu_time := dbms_utility.get_cpu_time;
      end snap_time;

   begin

      if p_run = c_run2 then
         snap_time;
      end if;

      -- Dynamic SQL (combined with invoker rights in the spec) works around
      -- the need to have explicit select granted on the referenced v$ views.
      -- Of course, we still need access granted via a role or other privilege
      -- but I've always been able to get the latter and rarely the former...
      -- ---------------------------------------------------------------------
      open rc_stat for q'[select 'STAT' as type
                          ,      a.name
                          ,      b.value
                          from   v$statname a
                          ,      v$mystat   b
                          where  a.statistic# = b.statistic#
                          and    :g_include_statistics = 'Y'
                          union all
                          select 'LATCH'
                          ,      name
                          ,      gets
                          from   v$latch
                          where  :g_include_latches = 'Y'
                          union all
                          select 'TIME'
                          ,      'elapsed time'
                          ,      hsecs
                          from   v$timer
                          where  :g_include_time_model = 'Y'
                          union all
                          select 'TIME'
                          ,      stat_name
                          ,      value
                          from   v$sess_time_model
                          where  sid = sys_context('userenv','sid')
                          and    :g_include_time_model = 'Y']'
                   using g_include_statistics, g_include_latches, g_include_time_model, g_include_time_model;
      fetch rc_stat bulk collect into aa_stats;
      close rc_stat;
      for i in 1 .. aa_stats.count loop
         p_mystats(p_run)(aa_stats(i).name).type := aa_stats(i).type;
         p_mystats(p_run)(aa_stats(i).name).value := aa_stats(i).value;
      end loop;

      if p_run = c_run1 then
         snap_time;
      end if;

   end ms_snap;

   ------------------------------------------------------------------------------
   procedure ms_report( p_threshold       in pls_integer default null,
                        p_statnames       in mystats_pkg.statname_ntt default null,
                        p_statname_like   in varchar2 default null,
                        p_statname_regexp in varchar2 default null ) is

      v_name    st_statname;  --<-- offset for varchar2 associative arrays
      v_indx    pls_integer;  --<-- offset for pls_integer associative arrays
      v_type    st_stattype;  --<-- statistic type
      v_value   st_statvalue; --<-- snapshot value for a statistic

      -- Downside of using associative arrays is that we have to sort
      -- the output. So here's a couple of types and a variable to enable us
      -- to do that...
      -- -------------------------------------------------------------------
      type aat_mystats_output is table of st_output
         index by st_statname;
      type aat_mystats_sorted is table of aat_mystats_output
         index by pls_integer;
      aa_mystats_sorted aat_mystats_sorted;

      -- Procedure to add a statistic to the sorted mystats array...
      -- -----------------------------------------------------------
      procedure sort ( p_stattype in st_stattype,
                       p_statname in st_statname,
                       p_value    in number ) is
         v_offset pls_integer;
         v_output st_output;
      begin
         -- Workaround the offset limits of a PLS_INTEGER associative array...
         -- ------------------------------------------------------------------
         v_offset := least(abs(p_value),2147483647);
         v_output := rpad(p_stattype, 8) || rpad(p_statname, 64) ||
                     lpad(to_char(p_value,'999,999,999,999'),18);
         aa_mystats_sorted(v_offset)(p_statname) := v_output;
      end sort;

      -- Report formatting procedures...
      -- -------------------------------
      procedure div( p_divider in varchar2 default '-',
                     p_width   in pls_integer default 90 ) is
      begin
         dbms_output.put_line( rpad(p_divider, p_width, p_divider) );
      end div;

      procedure nl( p_newlines in pls_integer default 1 ) is
      begin
         for i in 1 .. p_newlines loop
            dbms_output.put_line(null);
         end loop;
      end nl;

      procedure sh ( p_title  in varchar2,
                     p_header in boolean default true ) is
      begin
         nl(2);
         div;
         dbms_output.put_line(p_title);
         div;
         if p_header then
            nl;
            dbms_output.put_line('Type    ' || rpad('Statistic Name',64) || lpad('Value',18));
            dbms_output.put_line(rpad('-',6,'-') || '  ' || rpad('-',64,'-') || '  ' || lpad('-',16,'-'));
         end if;
      end sh;

   begin

      -- Report header...
      -- ----------------
      nl;
      div('=');
      dbms_output.put_line('MyStats report : ' || to_char(sysdate,'dd-MON-YYYY hh24:mi:ss'));
      div('=');

      -- Summary timings...
      -- ------------------
      sh('1. Summary Timings');
      dbms_output.put_line(rpad('TIMER', 8) || rpad('snapshot interval (seconds)', 64) ||
                           lpad(to_char(round((g_end_time.ela_time-g_start_time.ela_time)/100,2), 'fm999,990.00'),18));
      dbms_output.put_line(rpad('TIMER', 8) || rpad('CPU time used (seconds)', 64) ||
                           lpad(to_char(round((g_end_time.cpu_time-g_start_time.cpu_time)/100,2), 'fm999,990.00'),18));

      -- Now sort the output according to difference. A fudge is that we have to sort
      -- it manually and also work around the offset limits of an associative array...
      -- -----------------------------------------------------------------------------
      v_name := ga_mystats(c_run1).first;
      while v_name is not null loop

         -- Retrieve stattype...
         -- --------------------
         v_type := ga_mystats(c_run1)(v_name).type;

         -- Calculate the value of the current statistic...
         -- -----------------------------------------------
         v_value := ga_mystats(c_run2)(v_name).value - ga_mystats(c_run1)(v_name).value;

         -- If it's greater than the threshold or a statistic we are interested in,
         -- then output it. The downside of using purely associative arrays is that
         -- we don't have any easy way of sorting. So we have to do it ourselves...
         -- -----------------------------------------------------------------------
         if (p_threshold is not null and abs(v_value) >= p_threshold)
         or (p_statnames is not empty and v_name member of p_statnames)
         or (p_statname_like is not null and v_name like '%'||p_statname_like||'%') or (p_statname_regexp is not null and regexp_like(v_name, p_statname_regexp, 'i'))
         then
            -- Fix for bug 1713403. If redo goes over 2Gb then it is reported as a negative
            -- number. Recommended workaround (prior to fix in 10g) is to use redo blocks written
            -- but this seems to be 0 in V$MYSTAT or V$SESSTAT. Output a bug message...
            -- ----------------------------------------------------------------------------------
            if v_name = 'redo size' and v_value < 0 then
               sort('BUG','redo size > 2gb gives -ve value. Use redo blocks written',0);
            else
               sort(v_type, v_name, v_value);
            end if;
         end if;


         -- Next statname please...
         -- -----------------------
         v_name := ga_mystats(c_run1).next(v_name);

      end loop;

      -- Now we can output the sorted snapshot...
      -- ----------------------------------------
      sh('2. Statistics Report');

      v_indx := aa_mystats_sorted.first;
      while v_indx is not null loop

         v_name := aa_mystats_sorted(v_indx).first;
         while v_name is not null loop
            dbms_output.put_line( aa_mystats_sorted(v_indx)(v_name) );
            v_name := aa_mystats_sorted(v_indx).next(v_name);
         end loop;

         v_indx := aa_mystats_sorted.next(v_indx);

      end loop;

      -- Options...
      -- -------
      sh('3. Options', false);
      ms_options(p_threshold, p_statnames, p_statname_like, p_statname_regexp);

      -- Info...
      -- -------
      sh('4. About', false);
      ms_info;

      nl;
      div('=');
      dbms_output.put_line('End of report');
      div('=');

   end ms_report;

   ------------------------------------------------------------------------------
   procedure ms_set_snap_options( p_include_statistics in boolean,
                                  p_include_latches    in boolean,
                                  p_include_time_model in boolean ) is
      function ms_set_option( p_option in boolean ) return varchar2 is
      begin
         return case
                   when p_option
                   then 'Y'
                   else 'N'
                end;
      end ms_set_option;
   begin
      g_include_statistics := ms_set_option(p_include_statistics);
      g_include_latches    := ms_set_option(p_include_latches);
      g_include_time_model := ms_set_option(p_include_time_model);
   end ms_set_snap_options;

   ------------------------------------------------------------------------------
   procedure ms_reset is
   begin
      ga_mystats.delete;
      g_start_time         := null;
      g_end_time           := null;
      g_include_statistics := null;
      g_include_latches    := null;
      g_include_time_model := null;
   end ms_reset;

   ------------------------------------------------------------------------------
   procedure ms_start( p_include_statistics in boolean default true,
                       p_include_latches    in boolean default true,
                       p_include_time_model in boolean default true ) is
   begin
      ms_reset;
      ms_set_snap_options(p_include_statistics, p_include_latches, p_include_time_model);
      ms_snap(c_run1, ga_mystats, g_start_time);
   end ms_start;

   ------------------------------------------------------------------------------
   procedure ms_stop_internal( p_threshold       in integer default null,
                               p_statnames       in mystats_pkg.statname_ntt default null,
                               p_statname_like   in varchar2 default null,
                               p_statname_regexp in varchar2 default null ) is
   begin
      if g_start_time.ela_time is not null then
         ms_snap(c_run2, ga_mystats, g_end_time);
         case
            when p_threshold is not null
            then ms_report(p_threshold => p_threshold);
            when p_statnames is not null
            then ms_report(p_statnames => p_statnames);
            when p_statname_like is not null
            then ms_report(p_statname_like => p_statname_like);
            when p_statname_regexp is not null
            then ms_report(p_statname_regexp => p_statname_regexp);
            else ms_report;
         end case;
         ms_reset;
      else
         raise_application_error(
            -20001, 'Error: must call ms_start before ms_stop.'
            );
      end if;
   end ms_stop_internal;

   ------------------------------------------------------------------------------
   procedure ms_stop is
   begin
      ms_stop_internal(p_threshold => 0);
   end ms_stop;

   ------------------------------------------------------------------------------
   procedure ms_stop( p_threshold in integer ) is
   begin
      ms_stop_internal(p_threshold => p_threshold);
   end ms_stop;

   ------------------------------------------------------------------------------
   procedure ms_stop( p_statnames in mystats_pkg.statname_ntt ) is
   begin
      ms_stop_internal(p_statnames => p_statnames);
   end ms_stop;

   ------------------------------------------------------------------------------
   procedure ms_stop( p_statname_like in varchar2,
                      p_use_regexp    in boolean default false ) is
   begin
      if p_use_regexp then
         ms_stop_internal(p_statname_regexp => p_statname_like);
      else
         ms_stop_internal(p_statname_like => p_statname_like);
      end if;
   end ms_stop;

end mystats_pkg;
/

-- create or replace public synonym mystats_pkg for mystats_pkg;
-- grant execute on mystats_pkg to public;
