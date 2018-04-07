create or replace package body ut_coverage_extended is
  /*
  utPLSQL - Version 3
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

  function get_cov_sources_sql(a_coverage_options ut_coverage_options) return varchar2 is
    l_result varchar2(32767);
    l_full_name varchar2(100);
    l_view_name      varchar2(200) := ut_metadata.get_dba_view('dba_source');
  begin
    if a_coverage_options.file_mappings is not null and a_coverage_options.file_mappings.count > 0 then
      l_full_name := 'f.file_name';
    else
      l_full_name := 'lower(s.owner||''.''||s.name)';
    end if;
    l_result := '
      select full_name, owner, name, line, to_be_skipped, text
        from (
          select '||l_full_name||q'[ as full_name,
                 s.owner,
                 s.name,
                 s.line -
                 coalesce(
                   case when type!='TRIGGER' then 0 end,
                   (select min(t.line) - 1
                      from ]'||l_view_name||q'[ t
                     where t.owner = s.owner and t.type = s.type and t.name = s.name
                       and regexp_like( t.text, '[A-Za-z0-9$#_]*(begin|declare|compound).*','i'))
                 ) as line,
                 s.text, 'N' as to_be_skipped
            from ]'||l_view_name||q'[ s]';
            
    if a_coverage_options.file_mappings is not empty then
      l_result := l_result || '
            join table(:file_mappings) f
              on s.name  = f.object_name
             and s.type  = f.object_type
             and s.owner = f.object_owner
           where 1 = 1';
    elsif a_coverage_options.include_objects is not empty then
      l_result := l_result || '
           where (s.owner, s.name) in (select il.owner, il.name from table(:include_objects) il)';
    else
      l_result := l_result || '
           where s.owner in (select upper(t.column_value) from table(:l_schema_names) t)';
    end if;
    l_result := l_result || q'[
             and s.type not in ('PACKAGE', 'TYPE', 'JAVA SOURCE')
             --Exclude calls to utPLSQL framework, Unit Test packages and objects from a_exclude_list parameter of coverage reporter
             and (s.owner, s.name) not in (select el.owner, el.name from table(:l_skipped_objects) el)
             )
       where line > 0]';
    return l_result;
  end;


  /**
  * Public functions
  */
  
  /* Function extend coverage  
  P - profiler line result, C - coverage line result, X-result
  Dla ka?dej linii:X=greatest(P,nvl(C,0))
  Czyli:
  If P is null - line is irrelevant
  If P or X > 0 - line is covered
  */
  

  function get_extended_coverage(a_coverage_options ut_coverage_options) return ut_coverage.t_coverage is
    l_result              ut_coverage.t_coverage;
    l_result_block        ut_coverage.t_coverage;
    l_result_profiler     ut_coverage.t_coverage;
    l_source_objects_crsr ut_coverage_helper.t_tmp_table_objects_crsr;
    l_source_object       ut_coverage_helper.t_tmp_table_object;
    l_new_unit            ut_coverage.t_unit_coverage;
    l_line_no             binary_integer;
  begin
    l_result_block := ut_coverage_block.get_coverage_data_block(a_coverage_options => a_coverage_options);
    l_result_profiler:= ut_coverage_proftab.get_coverage_data_profiler(a_coverage_options => a_coverage_options);
    
    
    ut_coverage.populate_tmp_table(a_coverage_options,get_cov_sources_sql(a_coverage_options));
    
    l_source_objects_crsr := ut_coverage_helper.get_tmp_table_objects_cursor();
    loop
      fetch l_source_objects_crsr
        into l_source_object;
      exit when l_source_objects_crsr%notfound;
      --check if we have a hits in any of reporters
      if l_result_block.total_lines > 0 or l_result_profiler.total_lines > 0 then
        --update total stats
        l_result.total_lines := nvl(l_result.total_lines,0) + l_source_object.lines_count;
        l_result.total_blocks := l_result_block.total_blocks;
        l_result.uncovered_blocks := l_result_block.uncovered_blocks;
        l_result.covered_blocks := l_result_block.covered_blocks;
        l_result.partcovered_lines := l_result_block.partcovered_lines;
        
        --populate object level coverage stats
        if not l_result.objects.exists(l_source_object.full_name) then
          l_result.objects(l_source_object.full_name) := l_new_unit;
          l_result.objects(l_source_object.full_name).owner := l_source_object.owner;
          l_result.objects(l_source_object.full_name).name := l_source_object.name;
          l_result.objects(l_source_object.full_name).total_lines := l_source_object.lines_count;
          l_result.objects(l_source_object.full_name).total_blocks := l_result_block.objects(l_source_object.full_name).total_blocks;
          l_result.objects(l_source_object.full_name).uncovered_blocks := l_result_block.objects(l_source_object.full_name).uncovered_blocks;
          l_result.objects(l_source_object.full_name).covered_blocks := l_result_block.objects(l_source_object.full_name).covered_blocks;
          l_result.objects(l_source_object.full_name).partcovered_lines := l_result_block.objects(l_source_object.full_name).partcovered_lines;       
        end if;
        
        l_line_no := coalesce(l_result_block.objects(l_source_object.full_name).lines.first,
                            l_result_profiler.objects(l_source_object.full_name).lines.first);
        
        if l_line_no is null then
          l_result.uncovered_lines := l_result.uncovered_lines + l_source_object.lines_count;
          l_result.objects(l_source_object.full_name).uncovered_lines := l_source_object.lines_count;
        else
         loop
            exit when l_line_no is null;           
            -- object level stats
            
            -- Failing on non existing data for block objects.Check if exists and then use it
            l_result.objects(l_source_object.full_name).lines(l_line_no).executions := greatest(l_result_block.objects(l_source_object.full_name).lines(l_line_no).executions,
                                                                                              l_result_profiler.objects(l_source_object.full_name).lines(l_line_no).executions);
            l_result.objects(l_source_object.full_name).lines(l_line_no).no_blocks := NVL(l_result_block.objects(l_source_object.full_name).lines(l_line_no).no_blocks,0);
            l_result.objects(l_source_object.full_name).lines(l_line_no).covered_blocks := NVL(l_result_block.objects(l_source_object.full_name).lines(l_line_no).covered_blocks,0);
            l_result.objects(l_source_object.full_name).lines(l_line_no).partcove := l_result_block.objects(l_source_object.full_name).lines(l_line_no).partcove;                 
            -- total level stats
            
            -- Recalculate total lines
            if l_result.objects(l_source_object.full_name).lines(l_line_no).executions > 0 then
             -- total level stats
             l_result.executions := l_result.executions + l_result.objects(l_source_object.full_name).lines(l_line_no).executions;
             l_result.covered_lines := l_result.covered_lines + 1;            
             -- object level stats
            l_result.objects(l_source_object.full_name).covered_lines := l_result.objects(l_source_object.full_name)
                                                                             .uncovered_lines + 1;
            elsif l_result.objects(l_source_object.full_name).lines(l_line_no).executions = 0 then
             -- total level stats
             l_result.uncovered_lines := l_result.uncovered_lines + 1;
             -- object level stats
             l_result.objects(l_source_object.full_name).uncovered_lines := l_result.objects(l_source_object.full_name)
                                                                           .uncovered_lines + 1;
            end if;
            
            l_line_no := coalesce(l_result_block.objects(l_source_object.full_name).lines.next(l_line_no),
                            l_result_profiler.objects(l_source_object.full_name).lines.next(l_line_no));
               
         end loop;
       end if;
      end if;
    
    end loop;
    close l_source_objects_crsr;
    return l_result;

  end get_extended_coverage; 
  
end;
/
