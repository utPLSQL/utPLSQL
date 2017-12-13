CREATE OR REPLACE PACKAGE BODY ut_block_coverage IS
   /*
   utPLSQL - Version X.X.X.X
   Copyright 2016 - 2017 utPLSQL Project
   
   Licensed under the Apache License, Version 2.0 (the "License"):
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at
   
       http://www.apache.org/licenses/LICENSE-2.0
   
   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   */

   g_coverage_id INTEGER;

   TYPE t_unit_line_call IS RECORD(
       blocks         BINARY_INTEGER DEFAULT 0
      ,covered_blocks BINARY_INTEGER DEFAULT 0
      ,partcovered    BINARY_INTEGER DEFAULT 0);

   TYPE t_unit_line_calls IS TABLE OF t_unit_line_call INDEX BY BINARY_INTEGER;

   TYPE t_source_lines IS TABLE OF BINARY_INTEGER;

   -- The source query has two important transformations done in it.
   -- the flag: to_be_skipped ='Y' is set for a line of code that is badly reported by DBMS_PROFILER as executed 0 times.
   -- This includes lines that are:
   --   - PACKAGE, PROCEDURE, FUNCTION definition line,
   --   - BEGIN, END  of a block
   -- Another transformation is adjustment of line number for TRIGGER body.
   -- DBMS_PROFILER is reporting line numbers for triggers not as defined in DBA_SOURCE, its usign line numbers as defined in DBA_TRIGGERS
   -- the DBA_TRIGGERS does not contain the trigger specification lines, only lines that define the trigger body.
   -- the query adjusts the line numbers for triggers by finding first occurrence of begin|declare|compound in the trigger body line.
   -- The subquery is optimized by:
   -- - COALESCE function -> it will execute only for TRIGGERS
   -- - scalar subquery cache -> it will only execute once for one trigger source code.
   FUNCTION get_cov_sources_sql(a_coverage_options ut_coverage_options) RETURN VARCHAR2 IS
      l_result    VARCHAR2(32767);
      l_full_name VARCHAR2(100);
      l_view_name VARCHAR2(200) := ut_metadata.get_dba_view('dba_source');
   BEGIN
      IF a_coverage_options.file_mappings IS NOT NULL AND
         a_coverage_options.file_mappings.count > 0 THEN
         l_full_name := 'f.file_name';
      ELSE
         l_full_name := 'lower(s.owner||''.''||s.name)';
      END IF;
      l_result := '
      select full_name, owner, name, line, to_be_skipped, text
        from (
          select ' || l_full_name || q'[ as full_name,
                 s.owner,
                 s.name,
                 s.line -
                 coalesce(
                   case when type!='TRIGGER' then 0 end,
                   (select min(t.line) - 1
                      from ]' || l_view_name || q'[ t
                     where t.owner = s.owner and t.type = s.type and t.name = s.name
                       and regexp_like( t.text, '[A-Za-z0-9$#_]*(begin|declare|compound).*','i'))
                 ) as line,
                 s.text,
                 'N' as to_be_skipped
            from ]' || l_view_name || q'[ s]';
      IF a_coverage_options.file_mappings IS NOT empty THEN
         l_result := l_result || '
            join table(:file_mappings) f
              on s.name  = f.object_name
             and s.type  = f.object_type
             and s.owner = f.object_owner
           where 1 = 1';
      ELSIF a_coverage_options.include_objects IS NOT empty THEN
         l_result := l_result || '
           where (s.owner, s.name) in (select il.owner, il.name from table(:include_objects) il)';
      ELSE
         l_result := l_result || '
           where s.owner in (select upper(t.column_value) from table(:l_schema_names) t)';
      END IF;
      l_result := l_result || q'[
             and s.type not in ('PACKAGE', 'TYPE', 'JAVA SOURCE')
             --Exclude calls to utPLSQL framework, Unit Test packages and objects from a_exclude_list parameter of coverage reporter
             and (s.owner, s.name) not in (select el.owner, el.name from table(:l_skipped_objects) el)
             )
       where line > 0]';
      RETURN l_result;
   END;

   --' /*Not mess formatter*/

   FUNCTION get_cov_sources_cursor(a_coverage_options ut_coverage_options)
      RETURN SYS_REFCURSOR IS
      l_cursor       SYS_REFCURSOR;
      l_skip_objects ut_object_names;
      l_schema_names ut_varchar2_rows;
      l_sql          VARCHAR2(32767);
   BEGIN
      l_schema_names := coalesce(a_coverage_options.schema_names,
                                 ut_varchar2_rows(sys_context('USERENV', 'CURRENT_SCHEMA')));
      IF NOT ut_coverage_helper.is_develop_mode() THEN
         --skip all the utplsql framework objects and all the unit test packages that could potentially be reported by coverage.
         l_skip_objects := ut_utils.get_utplsql_objects_list() MULTISET UNION ALL
                           coalesce(a_coverage_options.exclude_objects, ut_object_names());
      END IF;
      l_sql := get_cov_sources_sql(a_coverage_options);
      IF a_coverage_options.file_mappings IS NOT empty THEN
         OPEN l_cursor FOR l_sql
            USING a_coverage_options.file_mappings, l_skip_objects;
      ELSIF a_coverage_options.include_objects IS NOT empty THEN
         OPEN l_cursor FOR l_sql
            USING a_coverage_options.include_objects, l_skip_objects;
      ELSE
         OPEN l_cursor FOR l_sql
            USING l_schema_names, l_skip_objects;
      END IF;
      RETURN l_cursor;
   END;

   PROCEDURE populate_tmp_table(a_coverage_options ut_coverage_options) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
      l_cov_sources_crsr SYS_REFCURSOR;
      l_cov_sources_data ut_coverage_helper.t_coverage_sources_tmp_rows;
   BEGIN
   
      IF NOT ut_coverage_helper.is_tmp_table_populated() OR
         ut_coverage_helper.is_develop_mode() THEN
         ut_coverage_helper.cleanup_tmp_table();
      
         l_cov_sources_crsr := get_cov_sources_cursor(a_coverage_options);
      
         LOOP
            FETCH l_cov_sources_crsr BULK COLLECT
               INTO l_cov_sources_data LIMIT 1000;
         
            ut_coverage_helper.insert_into_tmp_table(l_cov_sources_data);
         
            EXIT WHEN l_cov_sources_crsr%NOTFOUND;
         END LOOP;
      
         CLOSE l_cov_sources_crsr;
      END IF;
      COMMIT;
   END;

   /**
   * Public functions
   */
   PROCEDURE coverage_start IS
   BEGIN
      dbms_plsql_code_coverage.create_coverage_tables(force_it => TRUE);
      g_coverage_id := dbms_plsql_code_coverage.start_coverage(run_comment => 'utPLSQL Code coverage run ' ||
                                                                              ut_utils.to_string(systimestamp));
   END;

   PROCEDURE coverage_stop IS
   BEGIN
      dbms_plsql_code_coverage.stop_coverage;
   END;

   FUNCTION get_raw_coverage_data(a_object_owner VARCHAR2
                                 ,a_object_name  VARCHAR2) RETURN t_unit_line_calls IS
      TYPE coverage_row IS RECORD(
          line           BINARY_INTEGER
         ,blocks         BINARY_INTEGER
         ,covered_blocks BINARY_INTEGER);
      TYPE coverage_rows IS TABLE OF coverage_row;
      l_tmp_data coverage_rows;
      l_results  t_unit_line_calls;
   
      l_debug NUMBER;
   BEGIN
      SELECT ccb.line
            ,COUNT(ccb.block) totalblocks
            ,SUM(ccb.covered) AS coveredblocks BULK COLLECT
      INTO   l_tmp_data
      FROM   dbmspcc_units ccu
      LEFT   OUTER JOIN dbmspcc_blocks ccb
      ON     ccu.run_id = ccb.run_id
      AND    ccu.object_id = ccb.object_id
      WHERE  ccu.owner = a_object_owner
      AND    ccu.name = a_object_name
      AND    ccu.run_id = g_coverage_id
      GROUP  BY ccb.line
      ORDER  BY 1;
   
      l_debug := l_tmp_data.count;
   
      FOR i IN 1 .. l_tmp_data.count
      LOOP
         l_results(l_tmp_data(i).line).blocks := l_tmp_data(i).blocks;
         l_results(l_tmp_data(i).line).covered_blocks := l_tmp_data(i).covered_blocks;
         l_results(l_tmp_data(i).line).partcovered := CASE
                                                         WHEN (l_tmp_data(i).blocks > 1) AND
                                                              (l_tmp_data(i).blocks > l_tmp_data(i)
                                                              .covered_blocks) THEN
                                                          1
                                                         ELSE
                                                          0
                                                      END;
      END LOOP;
      RETURN l_results;
   END;

   PROCEDURE coverage_resume IS
   BEGIN
      NULL;
   END;

   PROCEDURE coverage_pause IS
   BEGIN
      NULL;
   END;

   FUNCTION get_coverage_data(a_coverage_options ut_coverage_options)
      RETURN ut_coverage.t_coverage IS
      l_line_calls          t_unit_line_calls;
      l_result              ut_coverage.t_coverage;
      l_new_unit            ut_coverage.t_unit_coverage;
      line_no               BINARY_INTEGER;
      l_source_objects_crsr ut_coverage_helper.t_tmp_table_objects_crsr;
      l_source_object       ut_coverage_helper.t_tmp_table_object;
   BEGIN
   
      --prepare global temp table with sources
      populate_tmp_table(a_coverage_options);
   
      l_source_objects_crsr := ut_coverage_helper.get_tmp_table_objects_cursor();
      LOOP
         FETCH l_source_objects_crsr
            INTO l_source_object;
         EXIT WHEN l_source_objects_crsr%NOTFOUND;
      
         --get coverage data
         l_line_calls := get_raw_coverage_data(l_source_object.owner, l_source_object.name);
      
         --if there is coverage, we need to filter out the garbage (badly indicated data from dbms_profiler)
         IF l_line_calls.count > 0 THEN
            --remove lines that should not be indicted as meaningful
            FOR i IN 1 .. l_source_object.to_be_skipped_list.count
            LOOP
               IF l_source_object.to_be_skipped_list(i) IS NOT NULL THEN
                  l_line_calls.delete(l_source_object.to_be_skipped_list(i));
               END IF;
            END LOOP;
         END IF;
      
         --if there are no file mappings or object was actually captured by profiler
         IF a_coverage_options.file_mappings IS NULL OR l_line_calls.count > 0 THEN
         
            --populate total stats
            l_result.total_lines := l_result.total_lines + l_source_object.lines_count;
         
            --populate object level coverage stats
            IF NOT l_result.objects.exists(l_source_object.full_name) THEN
               l_result.objects(l_source_object.full_name) := l_new_unit;
               l_result.objects(l_source_object.full_name).owner := l_source_object.owner;
               l_result.objects(l_source_object.full_name).name := l_source_object.name;
               l_result.objects(l_source_object.full_name).total_lines := l_source_object.lines_count;
            END IF;
            --map to results
            line_no := l_line_calls.first;
            IF line_no IS NULL THEN
               l_result.uncovered_lines := l_result.uncovered_lines +
                                           l_source_object.lines_count;
               l_result.objects(l_source_object.full_name).uncovered_lines := l_source_object.lines_count;
            ELSE
               LOOP
                  EXIT WHEN line_no IS NULL;
               
                  --total stats
               
                  --Get total blocks ,blocks covered, blocks not covered
                  l_result.total_blocks     := NVL(l_result.total_blocks, 0) + l_line_calls(line_no)
                                              .blocks;
                  l_result.covered_blocks   := NVL(l_result.covered_blocks, 0) + l_line_calls(line_no)
                                              .covered_blocks;
                  l_result.uncovered_blocks := NVL(l_result.uncovered_blocks, 0) +
                                               (l_line_calls(line_no).blocks - l_line_calls(line_no)
                                                .covered_blocks);
               
                  --If line is not partially covered add as full line cover
                  IF l_line_calls(line_no).partcovered = 1 THEN
                     l_result.partcovered_lines := l_result.partcovered_lines + 1;
                  ELSE
                     l_result.covered_lines := l_result.covered_lines + 1;
                  END IF;
               
                  -- Use nvl as be default is null
                  --Increase total blocks
                  l_result.objects(l_source_object.full_name).total_blocks := NVL(l_result.objects(l_source_object.full_name)
                                                                                  .total_blocks,
                                                                                  0) + l_line_calls(line_no)
                                                                             .blocks;
               
                  --Total uncovered blocks is a line blocks minus covered blocsk
                  l_result.objects(l_source_object.full_name).uncovered_blocks := NVL(l_result.objects(l_source_object.full_name)
                                                                                      .uncovered_blocks,
                                                                                      0) +
                                                                                  (l_line_calls(line_no)
                                                                                   .blocks - l_line_calls(line_no)
                                                                                   .covered_blocks);
               
                  --If we have any coverted blocks in line
                  IF l_line_calls(line_no).covered_blocks > 0 THEN
                  
                     l_result.executions := l_result.executions + 1;
                     --object level stats
                  
                     IF l_line_calls(line_no).partcovered = 1 THEN
                        l_result.objects(l_source_object.full_name).partcovered_lines := l_result.objects(l_source_object.full_name)
                                                                                         .partcovered_lines + 1;
                     
                     ELSE
                        l_result.objects(l_source_object.full_name).covered_lines := l_result.objects(l_source_object.full_name)
                                                                                     .covered_lines + 1;
                     
                     END IF;
                  
                     l_result.objects(l_source_object.full_name).covered_blocks := NVL(l_result.objects(l_source_object.full_name)
                                                                                       .covered_blocks,
                                                                                       0) + l_line_calls(line_no)
                                                                                  .covered_blocks;
                  
                     l_result.objects(l_source_object.full_name).executions := NVL(l_result.objects(l_source_object.full_name)
                                                                                   .executions,
                                                                                   0) + 1;
                     l_result.objects(l_source_object.full_name).lines(line_no).execution := 1;
                  
                  ELSIF l_line_calls(line_no).covered_blocks = 0 THEN
                     l_result.uncovered_lines := l_result.uncovered_lines + 1;
                     l_result.objects(l_source_object.full_name).uncovered_lines := l_result.objects(l_source_object.full_name)
                                                                                    .uncovered_lines + 1;
                     l_result.objects(l_source_object.full_name).lines(line_no).execution := 0;
                  
                  END IF;
               
                  l_result.objects(l_source_object.full_name).lines(line_no).partcove := l_line_calls(line_no)
                                                                                         .partcovered;
               
                  line_no := l_line_calls.next(line_no);
               END LOOP;
            END IF;
         END IF;
      
      END LOOP;
   
      CLOSE l_source_objects_crsr;
   
      RETURN l_result;
   END get_coverage_data;

END;
/
