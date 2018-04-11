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

  /**
  * Public functions
  */ 

  function get_extended_coverage(a_coverage_options ut_coverage_options) return ut_coverage.t_coverage is
    l_result_block           ut_coverage.t_coverage;
    l_result_profiler_enrich ut_coverage.t_coverage;
    l_object                 ut_coverage.t_full_name;
    l_line_no                binary_integer;
  begin
    -- Get raw data for both reporters, order is important as tmp table will skip headers and dont populate 
    -- tmp table for block again.
    l_result_profiler_enrich:= ut_coverage_proftab.get_coverage_data_profiler(a_coverage_options => a_coverage_options);
  
    l_result_block := ut_coverage_block.get_coverage_data_block(a_coverage_options => a_coverage_options);
  
    -- Enrich profiler results with some of the block results
    l_object := l_result_profiler_enrich.objects.first;
    while (l_object is not null)
     loop
      l_line_no := l_result_profiler_enrich.objects(l_object).lines.first;
      while (l_line_no is not null)
       loop
        if l_result_block.objects(l_object).lines.exists(l_line_no) then
         -- enrich line level stats
         l_result_profiler_enrich.objects(l_object).lines(l_line_no).partcove := l_result_block.objects(l_object).lines(l_line_no).partcove;
         -- enrich object level stats
         l_result_profiler_enrich.objects(l_object).partcovered_lines :=  nvl(l_result_profiler_enrich.objects(l_object).partcovered_lines,0) + l_result_block.objects(l_object).lines(l_line_no).partcove;    
        end if;
        --At the end go to next line
        l_line_no := l_result_profiler_enrich.objects(l_object).lines.next(l_line_no);
       end loop;
       --total level stats enrich
       l_result_profiler_enrich.partcovered_lines := nvl(l_result_profiler_enrich.partcovered_lines,0) + l_result_profiler_enrich.objects(l_object).partcovered_lines;
      -- At the end go to next object
      l_object := l_result_profiler_enrich.objects.next(l_object);
     end loop;
   
    return l_result_profiler_enrich;

  end get_extended_coverage; 
  
end;
/
