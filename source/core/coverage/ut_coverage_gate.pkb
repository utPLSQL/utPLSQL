create or replace noneditionable package body ut_coverage_gate is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  -- Formats a percentage with exactly 2 decimals and a dot separator,
  -- regardless of the session NLS_NUMERIC_CHARACTERS, so that the error
  -- message stays deterministic and parseable by CI tooling.
  function format_pct(a_value number) return varchar2 is
  begin
    return to_char(round(a_value, 2), 'FM999999990D00', 'NLS_NUMERIC_CHARACTERS=''. ''');
  end;

  function coverage_pct(a_coverage_data ut_coverage.t_coverage) return number is
    l_total binary_integer := nvl(a_coverage_data.covered_lines, 0)
                           + nvl(a_coverage_data.uncovered_lines, 0);
  begin
    if l_total = 0 then
      return 0;
    end if;
    return round(100 * a_coverage_data.covered_lines / l_total, 2);
  end;

  function coverage_pct(
    a_coverage_run_id  raw,
    a_coverage_options ut_coverage_options
  ) return number is
    l_options ut_coverage_options := a_coverage_options;
    l_data    ut_coverage.t_coverage;
  begin
    if a_coverage_run_id is not null then
      l_options.coverage_run_id := a_coverage_run_id;
    end if;
    l_data := ut_coverage.get_coverage_data(l_options);
    return coverage_pct(l_data);
  end;

  procedure assert_coverage(
    a_coverage_data ut_coverage.t_coverage,
    a_min_pct       number,
    a_message       varchar2 := null
  ) is
    l_pct number;
    l_msg varchar2(4000);
  begin
    if a_min_pct is null or a_min_pct < 0 then
      return;
    end if;
    l_pct := coverage_pct(a_coverage_data);
    if l_pct < a_min_pct then
      l_msg := 'Coverage ' || format_pct(l_pct)
            || '% is below required ' || format_pct(a_min_pct) || '%';
      if a_message is not null then
        l_msg := a_message || ': ' || l_msg;
      end if;
      raise_application_error(gc_coverage_below_threshold, l_msg);
    end if;
  end;

  procedure assert_coverage(
    a_coverage_run_id  raw,
    a_min_pct          number,
    a_coverage_options ut_coverage_options,
    a_message          varchar2 := null
  ) is
    l_options ut_coverage_options := a_coverage_options;
  begin
    if a_min_pct is null or a_min_pct < 0 then
      return;
    end if;
    if a_coverage_run_id is not null then
      l_options.coverage_run_id := a_coverage_run_id;
    end if;
    assert_coverage(ut_coverage.get_coverage_data(l_options), a_min_pct, a_message);
  end;

end;
/
