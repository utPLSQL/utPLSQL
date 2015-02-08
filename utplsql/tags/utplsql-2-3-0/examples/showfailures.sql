COLUMN suite format a42 heading '*********  SUITE  *********'

COLUMN package format a16 heading '*** PACKAGE ***'

COLUMN time_stamp format a18

COLUMN test format a80 fold_before heading ""

COLUMN junk fold_after heading ""

COLUMN junk2 fold_before  heading ""

SET pagesize 0

SET linesize 80

BREAK on suite noduplicates on package noduplicates on time_stamp noduplicates on junk noduplicates skip 6

SPOOL last_run_failures.txt

SELECT   '*********************  SUITE  ************ PACKAGE *********  Time
Stamp'
               junk,
         s.description suite, p.NAME PACKAGE,
         TO_CHAR (p.last_end, 'dd-mon-yy hh24:mi:ss') time_stamp,
         '-----------------------------' junk2,
         DECODE (
            p.last_end,
            NULL, 'Unable to Execute',
            NVL (o.description, 'Passed all
Tests')
         ) test
    FROM utr_outcome o, ut_package p, ut_suite s
   WHERE o.run_id(+) = p.last_run_id
     AND o.status(+) = 'FAILURE'
     AND s.id = p.suite_id
ORDER BY s.id, p.seq, p.last_end;

SPOOL off
