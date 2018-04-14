create or replace package body ut_coverage_profiler is
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
  function get_coverage_data(a_coverage_options ut_coverage_options) return ut_coverage.t_coverage is
    l_line_calls          ut_coverage_helper.t_unit_line_calls;
    l_result              ut_coverage.t_coverage;
    l_new_unit            ut_coverage.t_unit_coverage;
    l_line_no             binary_integer;
    l_source_objects_crsr ut_coverage_helper.t_tmp_table_objects_crsr;
    l_source_object       ut_coverage_helper.t_tmp_table_object;
  begin

    --prepare global temp table with sources
    ut_coverage.populate_tmp_table(a_coverage_options,ut_coverage.get_cov_sources_sql(a_coverage_options,'Y'));

    l_source_objects_crsr := ut_coverage_helper.get_tmp_table_objects_cursor();
    loop
      fetch l_source_objects_crsr into l_source_object;
      exit when l_source_objects_crsr%notfound;

      --get coverage data
      l_line_calls := ut_coverage_helper_profiler.get_raw_coverage_data( l_source_object.owner, l_source_object.name);

      --if there is coverage, we need to filter out the garbage (badly indicated data from dbms_profiler)
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
          l_result.objects(l_source_object.full_name).name  := l_source_object.name;
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

            if l_line_calls(l_line_no).calls > 0 then
              --total stats
              l_result.covered_lines := l_result.covered_lines + 1;
              l_result.executions := l_result.executions + l_line_calls(l_line_no).calls;
              --object level stats
              l_result.objects(l_source_object.full_name).covered_lines := l_result.objects(l_source_object.full_name).covered_lines + 1;
              l_result.objects(l_source_object.full_name).executions := l_result.objects(l_source_object.full_name).executions + l_line_calls(l_line_no).calls;
            elsif l_line_calls(l_line_no).calls = 0 then
              l_result.uncovered_lines := l_result.uncovered_lines + 1;
              l_result.objects(l_source_object.full_name).uncovered_lines := l_result.objects(l_source_object.full_name).uncovered_lines + 1;
            end if;
            l_result.objects(l_source_object.full_name).lines(l_line_no).executions := l_line_calls(l_line_no).calls;

            l_line_no := l_line_calls.next(l_line_no);
          end loop;
        end if;
      end if;

    end loop;

    close l_source_objects_crsr;

    return l_result;
  end get_coverage_data;
  
end;
/
