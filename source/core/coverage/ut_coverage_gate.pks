create or replace noneditionable package ut_coverage_gate authid current_user is
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

  -- Raised by assert_coverage when the measured coverage is below the threshold.
  ex_coverage_below_threshold exception;
  gc_coverage_below_threshold constant pls_integer := -20218;
  pragma exception_init(ex_coverage_below_threshold, -20218);

  -- Returns the line coverage percentage (0..100, 2 decimals) of the given
  -- coverage data. Uses the same formula as the Cobertura reporter:
  --   covered / (covered + uncovered), 0 when there is nothing to cover.
  -- Partially covered lines (partcovered_lines) are reported separately and
  -- do not count as covered, consistent with ut_coverage_cobertura_reporter.
  function coverage_pct(a_coverage_data ut_coverage.t_coverage) return number;

  -- Same as above, but fetches the coverage data first via
  -- ut_coverage.get_coverage_data. If a_coverage_run_id is not null, it
  -- overrides a_coverage_options.coverage_run_id. All other options
  -- (schemas, filters, mappings) come from a_coverage_options, so the gate
  -- evaluates exactly what the reporters would report.
  function coverage_pct(
    a_coverage_run_id  raw,
    a_coverage_options ut_coverage_options
  ) return number;

  -- Fails with ORA-20218 when coverage_pct(a_coverage_data) < a_min_pct.
  -- A null or negative a_min_pct is a documented no-op (gate disabled).
  -- a_message, when given, is prepended to the error text.
  procedure assert_coverage(
    a_coverage_data ut_coverage.t_coverage,
    a_min_pct       number,
    a_message       varchar2 := null
  );

  -- Same as above, fetching the coverage data first (see coverage_pct/2).
  procedure assert_coverage(
    a_coverage_run_id  raw,
    a_min_pct          number,
    a_coverage_options ut_coverage_options,
    a_message          varchar2 := null
  );

end;
/
