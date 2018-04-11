create or replace package body ut_coverage_block is
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

  
  type t_source_lines is table of binary_integer;

  /**
  * Public functions
  */

  function get_coverage_data_block(a_coverage_options ut_coverage_options) return ut_coverage.t_coverage is
    l_line_calls          ut_coverage_helper.t_unit_line_calls;
    l_result              ut_coverage.t_coverage;
    l_new_unit            ut_coverage.t_unit_coverage;
    l_line_no               binary_integer;
    l_source_objects_crsr ut_coverage_helper.t_tmp_table_objects_crsr;
    l_source_object       ut_coverage_helper.t_tmp_table_object;
  begin
    --prepare global temp table with sources
    ut_coverage.populate_tmp_table(a_coverage_options,ut_coverage.get_cov_sources_sql(a_coverage_options,'N'));
    
    l_source_objects_crsr := ut_coverage_helper.get_tmp_table_objects_cursor();
    loop
      fetch l_source_objects_crsr
        into l_source_object;
      exit when l_source_objects_crsr%notfound;
    
      --get coverage data
      l_line_calls := ut_block_coverage_helper.get_raw_coverage_data_block(l_source_object.owner, l_source_object.name);
      --if there is coverage, we need to filter out the garbage (badly indicated data)
      if l_line_calls.count > 0 then
        --remove lines that should not be indicted as meaningful
        for i in 1 .. l_source_object.to_be_skipped_list.count loop
          if l_source_object.to_be_skipped_list(i) is not null then
            l_line_calls.delete(l_source_object.to_be_skipped_list(i));
          end if;
        end loop;
      end if;
    
      --if there are no file mappings or object was actually captured by profiler
      if a_coverage_options.file_mappings is null or l_line_calls.count > 0 then
      
        --populate total stats
        l_result.total_lines := nvl(l_result.total_lines,0) + l_source_object.lines_count;
      
        --populate object level coverage stats
        if not l_result.objects.exists(l_source_object.full_name) then
          l_result.objects(l_source_object.full_name) := l_new_unit;
          l_result.objects(l_source_object.full_name).owner := l_source_object.owner;
          l_result.objects(l_source_object.full_name).name := l_source_object.name;
          l_result.objects(l_source_object.full_name).total_lines := l_source_object.lines_count;
        end if;
        --map to results
        l_line_no := l_line_calls.first;
        if l_line_no is null then
          l_result.uncovered_lines := l_result.uncovered_lines + l_source_object.lines_count;
          l_result.objects(l_source_object.full_name).uncovered_lines := l_source_object.lines_count;
        else
          loop
            exit when l_line_no is null;
          
            --turn the block coverage into a line coverage format to allow for reading.
            --whenever the linst is a part covered treat that line as a hit and execution but only part covered
          
            --total stats        
            --Get total blocks ,blocks covered, blocks not covered this will be used for PCT calc
            l_result.total_blocks     := nvl(l_result.total_blocks, 0) + l_line_calls(l_line_no).blocks;
            l_result.covered_blocks   := nvl(l_result.covered_blocks, 0) + l_line_calls(l_line_no).covered_blocks;
            l_result.uncovered_blocks := nvl(l_result.uncovered_blocks, 0) +
                                         (l_line_calls(l_line_no).blocks - l_line_calls(l_line_no).covered_blocks);
          
            --If line is partially covered add as part line cover and covered for line reporter
            if l_line_calls(l_line_no).partcovered = 1 then
              l_result.partcovered_lines := l_result.partcovered_lines + 1;
            end if;
          
            if l_line_calls(l_line_no).covered_blocks > 0 then
              l_result.covered_lines := l_result.covered_lines + 1;
            end if;
          
            -- Use nvl as be default is null and screw the calcs
            --Increase total blocks
            l_result.objects(l_source_object.full_name).lines(l_line_no).no_blocks := l_line_calls(l_line_no).blocks;
            l_result.objects(l_source_object.full_name).lines(l_line_no).covered_blocks := l_line_calls(l_line_no).covered_blocks;
            l_result.objects(l_source_object.full_name).total_blocks := nvl(l_result.objects(l_source_object.full_name)
                                                                            .total_blocks
                                                                           ,0) + l_line_calls(l_line_no).blocks;
          
            --Total uncovered blocks is a line blocks minus covered blocsk
            l_result.objects(l_source_object.full_name).uncovered_blocks := nvl(l_result.objects(l_source_object.full_name)
                                                                                .uncovered_blocks
                                                                               ,0) +
                                                                            (l_line_calls(l_line_no).blocks - l_line_calls(l_line_no)
                                                                             .covered_blocks);
          
            --If we have any covered blocks in line
            if l_line_calls(l_line_no).covered_blocks > 0 then            
              --If any block is covered then we have a hit on that line
              l_result.executions := l_result.executions + 1;
              --object level stats
              --If its part covered then mark it else treat as full cov
              if l_line_calls(l_line_no).partcovered = 1 then
                l_result.objects(l_source_object.full_name).partcovered_lines := l_result.objects(l_source_object.full_name)
                                                                                 .partcovered_lines + 1;
              end if;
              l_result.objects(l_source_object.full_name).covered_lines := l_result.objects(l_source_object.full_name)
                                                                             .covered_lines + 1;
                         
              --How many blocks we covered
              l_result.objects(l_source_object.full_name).covered_blocks := nvl(l_result.objects(l_source_object.full_name)
                                                                                .covered_blocks
                                                                               ,0) + l_line_calls(l_line_no)
                                                                           .covered_blocks;
            
              --Object line executions
              l_result.objects(l_source_object.full_name).executions := nvl(l_result.objects(l_source_object.full_name)
                                                                            .executions
                                                                           ,0) + 1;
            
              l_result.objects(l_source_object.full_name).lines(l_line_no).executions := 1;
            
              --Whenever there is no covered block treat as uncovered (query returns only lines where the blocks are in code so we
              --dont have a false results here when there is no blocks
            elsif l_line_calls(l_line_no).covered_blocks = 0 then
              l_result.uncovered_lines := l_result.uncovered_lines + 1;
              l_result.objects(l_source_object.full_name).uncovered_lines := l_result.objects(l_source_object.full_name)
                                                                             .uncovered_lines + 1;
              l_result.objects(l_source_object.full_name).lines(l_line_no).executions := 0;
            end if;
            --increase part covered counter (+ 1/0)
            l_result.objects(l_source_object.full_name).lines(l_line_no).partcove := l_line_calls(l_line_no).partcovered;
            l_line_no := l_line_calls.next(l_line_no);
          end loop;
        end if;
      end if;
    
    end loop;
  
    close l_source_objects_crsr;
  
    return l_result;
  end get_coverage_data_block; 
  
end;
/
