create or replace package body test_ut_test_cases is

  g_time_zone          varchar2(100);
  g_nls_parameters     ut3_develop.ut_key_value_pairs;

  c_discount_cases constant varchar2(4000) :=
    'Discount for REGULAR customer with order total 500 on 2026-03-15T14:30:00 is 0.05' || chr(10) ||
    'Discount for REGULAR customer with order total 1000 on 2026-04-01T09:00:00 is 0.1' || chr(10) ||
    'Discount for VIP customer with order total 50 on 2026-03-20T10:00:00 is 0.25' || chr(10) ||
    'Discount for REGULAR customer with order total null on 2026-02-28T23:59:59 is 0';

  -- the spec and body of a suite with the example of discussion #1326; a_annotations, a_spec and a_body make the variants
  procedure create_discount_suite(a_name varchar2, a_annotations varchar2, a_spec varchar2 := null, a_body varchar2 := null) is
  begin
    execute immediate replace(replace(replace(q'~create or replace package <name> as

  --%suite(Discount calculation)

  --%test(Discount for {a_customer_type} customer with order total {a_order_total} on {a_order_date} is {a_expected})
<annotations>
  procedure discount_by_customer_type(
    a_order_total   number,
    a_customer_type varchar2,
    a_order_date    date,
    a_promo_start   timestamp,
    a_promo_end     timestamp with time zone,
    a_expected      number
  );
<spec>
end;~', '<name>', a_name), '<annotations>', a_annotations), '<spec>', a_spec);
    execute immediate replace(replace(q'~create or replace package body <name> as

  procedure discount_by_customer_type(
    a_order_total   number,
    a_customer_type varchar2,
    a_order_date    date,
    a_promo_start   timestamp,
    a_promo_end     timestamp with time zone,
    a_expected      number
  ) is
  begin
    ut3_develop.ut.expect(
      get_discount(a_order_total, a_customer_type, a_order_date, a_promo_start, a_promo_end)
    ).to_equal( a_expected );
  end;
<body>
end;~', '<name>', a_name), '<body>', a_body);
  end;

  procedure create_test_case_suites is
    pragma autonomous_transaction;
    l_boolean_spec varchar2(4000);
    l_boolean_body varchar2(4000);
    l_wide_parameters varchar2(4000);
  begin
    execute immediate 'create or replace type test_case_pair force as object (amount number, half number)';
    execute immediate 'create or replace type test_case_numbers force as table of number';
    execute immediate 'create table test_case_rows (a_amount number, a_half number)';

    execute immediate q'~create or replace function get_discount(
  a_order_total   number,
  a_customer_type varchar2,
  a_order_date    date,
  a_promo_start   timestamp,
  a_promo_end     timestamp with time zone
) return number is
  l_discount number;
begin
  if a_customer_type = 'VIP' then
    l_discount := 0.2;
  elsif a_customer_type = 'REGULAR' then
    l_discount := case when a_order_total >= 1000 then 0.1 else 0 end;
  else
    raise_application_error(-20001, 'Unknown customer type: ' || a_customer_type);
  end if;
  if a_order_date >= a_promo_start and a_order_date < a_promo_end then
    l_discount := l_discount + 0.05;
  end if;
  return l_discount;
end;~';

    create_discount_suite(
      'tc_discount_json',
      q'~  --%testcase([500, "REGULAR", "2026-03-15T14:30:00", "2026-03-01T00:00:00.000000", "2026-03-31T23:59:59.999999+02:00", 0.05])
  --%testcase([1000, "REGULAR", "2026-04-01T09:00:00", "2026-03-01T00:00:00.000000", "2026-03-31T23:59:59.999999+02:00", 0.1])
  --%testcase({"a_order_total": 50, "a_customer_type": "VIP", "a_order_date": "2026-03-20T10:00:00", "a_promo_start": "2026-03-01T00:00:00.000000", "a_promo_end": "2026-03-31T23:59:59.999999-05:00", "a_expected": 0.25})
  --%testcase({"a_order_total": null, "a_customer_type": "REGULAR", "a_order_date": "2026-02-28T23:59:59", "a_promo_start": "2026-03-01T00:00:00.000000", "a_promo_end": "2026-03-31T23:59:59.999999+02:00", "a_expected": 0})~'
    );
    create_discount_suite(
      'tc_discount_source',
      '  --%testcasesource(discount_cases)',
      '  function discount_cases return json_array_t;',
      q'~
  function discount_cases return json_array_t is
  begin
    return json_array_t(q'[
      [
        [500, "REGULAR", "2026-03-15T14:30:00", "2026-03-01T00:00:00.000000", "2026-03-31T23:59:59.999999+02:00", 0.05],
        [1000, "REGULAR", "2026-04-01T09:00:00", "2026-03-01T00:00:00.000000", "2026-03-31T23:59:59.999999+02:00", 0.1],
        {
          "a_order_total": 50,
          "a_customer_type": "VIP",
          "a_order_date": "2026-03-20T10:00:00",
          "a_promo_start": "2026-03-01T00:00:00.000000",
          "a_promo_end": "2026-03-31T23:59:59.999999-05:00",
          "a_expected": 0.25
        },
        {
          "a_order_total": null,
          "a_customer_type": "REGULAR",
          "a_order_date": "2026-02-28T23:59:59",
          "a_promo_start": "2026-03-01T00:00:00.000000",
          "a_promo_end": "2026-03-31T23:59:59.999999+02:00",
          "a_expected": 0
        }
      ]
    ]');
  end;~'
    );
    create_discount_suite(
      'tc_discount_cursor',
      '  --%testcasesource(discount_cases)',
      '  function discount_cases return sys_refcursor;',
      q'~
  function discount_cases return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select 500                                                                                  as a_order_total,
             'REGULAR'                                                                            as a_customer_type,
             to_date('2026-03-15 14:30:00', 'yyyy-mm-dd hh24:mi:ss')                              as a_order_date,
             to_timestamp('2026-03-01 00:00:00.000000', 'yyyy-mm-dd hh24:mi:ss.ff')               as a_promo_start,
             to_timestamp_tz('2026-03-31 23:59:59.999999 +02:00', 'yyyy-mm-dd hh24:mi:ss.ff tzh:tzm') as a_promo_end,
             0.05                                                                                 as a_expected
        from dual
      union all
      select 1000, 'REGULAR',
             to_date('2026-04-01 09:00:00', 'yyyy-mm-dd hh24:mi:ss'),
             to_timestamp('2026-03-01 00:00:00.000000', 'yyyy-mm-dd hh24:mi:ss.ff'),
             to_timestamp_tz('2026-03-31 23:59:59.999999 +02:00', 'yyyy-mm-dd hh24:mi:ss.ff tzh:tzm'),
             0.1
        from dual
      union all
      select 50, 'VIP',
             to_date('2026-03-20 10:00:00', 'yyyy-mm-dd hh24:mi:ss'),
             to_timestamp('2026-03-01 00:00:00.000000', 'yyyy-mm-dd hh24:mi:ss.ff'),
             to_timestamp_tz('2026-03-31 23:59:59.999999 -05:00', 'yyyy-mm-dd hh24:mi:ss.ff tzh:tzm'),
             0.25
        from dual
      union all
      select null, 'REGULAR',
             to_date('2026-02-28 23:59:59', 'yyyy-mm-dd hh24:mi:ss'),
             to_timestamp('2026-03-01 00:00:00.000000', 'yyyy-mm-dd hh24:mi:ss.ff'),
             to_timestamp_tz('2026-03-31 23:59:59.999999 +02:00', 'yyyy-mm-dd hh24:mi:ss.ff tzh:tzm'),
             0
        from dual;
    return l_cursor;
  end;~'
    );

    execute immediate q'~create or replace package tc_inline as
  --%suite(Inline test cases)

  --%test(Half of {a_amount} is {a_half})
  --%testcase([2000, 1000])
  --%testcase({"a_half": 5, "a_amount": 10})
  --%testcase([3, 2])
  --%testcase({"A_AMOUNT": 8, "a_half": 4})
  --%testcase([1, 1])
  procedure half(a_amount number, a_half number);

  --%test(Text {1})
  --%testcase({"a_text": "it's \"quoted\"", "a_case": 1})
  --%testcase(["it's \"quoted\"", 2])
  --%testcase(["~' || unistr('\00e4\00f6\00fc\20ac') || q'~", 3])
  --%testcase(["\u00e4\u00f6\u00fc\u20ac", 4])
  procedure strings(a_text varchar2, a_case number);

  --%test(Default for {a_required})
  --%testcase({"a_required": 1})
  --%testcase({"A_REQUIRED": 2})
  --%testcase([3])
  procedure defaults(a_required number, a_optional varchar2 := 'default');

  --%test(Conversions)
  --%testcase(["0.05", 5])
  procedure conversions(a_number number, a_text varchar2);

  --%test(Flag {a_flag} is {a_label})
  --%testcase([true, "yes"])
  --%testcase({"a_flag": false, "a_label": "no"})
  --%testcase([null, "null"])
  --%testcase(["yes", "error"])
  procedure booleans(a_flag boolean, a_label varchar2);

  --%test(Objects)
  --%testcase([{"amount": 8, "half": 4}, [1, 2, 3]])
  --%testcase([{"AMOUNT": 6, "HALF": 3}, [1]])
  --%testcase([null, null])
  --%testcase([{"amount": 8}, [1]])
  --%testcase([{"amount": 8, "halfx": 4}, [1]])
  --%testcase([{"amount": 8, "half": 4}, 5])
  procedure objects(a_pair test_case_pair, a_numbers test_case_numbers);

  --%test(Unsupported type)
  --%testcase(["<a/>"])
  procedure unsupported(a_xml xmltype);

  --%test(Overloaded)
  --%testcase([1])
  procedure overloaded(a number);
  procedure overloaded(a varchar2, b number);

  --%test(Arguments that don't fit)
  --%testcase([{"amount": 1, "half": 1}])
  --%testcase([1])
  --%testcase([{"amount": "x", "half": 1}])
  procedure arguments_dont_fit(a_pair test_case_pair);

  --%test(Not JSON)
  --%testcase(1, 2)
  --%testcase([1, 2])
  procedure not_json(a_first number, a_second number);

  --%test(More types)
  --%testcase([1.5, "n\u00e4", "P1DT2H", "P1Y2M", "0AFF", "long text"])
  procedure more_types(a_double binary_double, a_national nvarchar2, a_ds interval day to second, a_ym interval year to month, a_raw raw, a_clob clob);

  --%test(No parameters)
  --%testcase([])
  --%testcase({})
  procedure no_parameters;

  type t_record is record (a number);
  type t_numbers is table of number;

  --%test(Record parameter)
  --%testcase([{"a": 1}])
  procedure record_parameter(a_record t_record);

  --%test(Package collection parameter)
  --%testcase([[1, 2]])
  procedure package_collection_parameter(a_numbers t_numbers);

  --%test(JSON object parameter)
  --%testcase([{"a": 1}])
  procedure json_object_parameter(a_object json_object_t);

  --%test(BLOB parameter)
  --%testcase(["0AFF"])
  procedure blob_parameter(a_blob blob);
end;~';
    execute immediate q'~create or replace package body tc_inline as
  procedure half(a_amount number, a_half number) is
  begin
    ut3_develop.ut.expect(a_amount / 2).to_equal(a_half);
  end;
  procedure strings(a_text varchar2, a_case number) is
  begin
    ut3_develop.ut.expect(a_text).to_equal(case when a_case <= 2 then 'it''s "quoted"' else unistr('\00e4\00f6\00fc\20ac') end);
  end;
  procedure defaults(a_required number, a_optional varchar2 := 'default') is
  begin
    ut3_develop.ut.expect(a_required).to_be_not_null();
    ut3_develop.ut.expect(a_optional).to_equal('default');
  end;
  procedure conversions(a_number number, a_text varchar2) is
  begin
    ut3_develop.ut.expect(a_number).to_equal(0.05);
    ut3_develop.ut.expect(a_text).to_equal('5');
  end;
  procedure booleans(a_flag boolean, a_label varchar2) is
  begin
    ut3_develop.ut.expect(case when a_flag then 'yes' when not a_flag then 'no' else 'null' end).to_equal(a_label);
  end;
  procedure objects(a_pair test_case_pair, a_numbers test_case_numbers) is
  begin
    if a_pair is null then
      ut3_develop.ut.expect(a_numbers is null).to_be_true();
    else
      ut3_develop.ut.expect(a_pair.amount / 2).to_equal(a_pair.half);
      ut3_develop.ut.expect(a_numbers.count).to_equal(a_pair.amount - 5);
    end if;
  end;
  procedure unsupported(a_xml xmltype) is
  begin
    null;
  end;
  procedure not_json(a_first number, a_second number) is
  begin
    ut3_develop.ut.expect(a_second).to_equal(2);
  end;
  procedure overloaded(a number) is
  begin
    null;
  end;
  procedure overloaded(a varchar2, b number) is
  begin
    null;
  end;
  procedure arguments_dont_fit(a_pair test_case_pair) is
  begin
    ut3_develop.ut.expect(a_pair.amount).to_equal(1);
  end;
  procedure more_types(a_double binary_double, a_national nvarchar2, a_ds interval day to second, a_ym interval year to month, a_raw raw, a_clob clob) is
  begin
    ut3_develop.ut.expect(a_double).to_equal(1.5d);
    ut3_develop.ut.expect(a_national = unistr('n\00e4')).to_be_true();
    ut3_develop.ut.expect(a_ds).to_equal(interval '1 02:00:00' day to second);
    ut3_develop.ut.expect(a_ym).to_equal(interval '1-2' year to month);
    ut3_develop.ut.expect(rawtohex(a_raw)).to_equal('0AFF');
    ut3_develop.ut.expect(a_clob).to_equal(to_clob('long text'));
  end;
  procedure no_parameters is
  begin
    null;
  end;
  procedure record_parameter(a_record t_record) is
  begin
    null;
  end;
  procedure package_collection_parameter(a_numbers t_numbers) is
  begin
    null;
  end;
  procedure json_object_parameter(a_object json_object_t) is
  begin
    null;
  end;
  procedure blob_parameter(a_blob blob) is
  begin
    null;
  end;
end;~';

    execute immediate q'~create or replace package tc_sources as
  function get_cases return json_array_t;
end;~';
    execute immediate q'~create or replace package body tc_sources as
  function get_cases return json_array_t is
  begin
    return json_array_t('[[4, 2], {"a_half": 5, "a_amount": 10}]');
  end;
end;~';

    execute immediate q'~create or replace package tc_json_source as
  --%suite(JSON sources)
  --%beforeall(fill_rows)

  c_limit constant number := 100;
  procedure fill_rows;

  --%test(Half of {a_amount} from table is {a_half})
  --%testcasesource(get_rows)
  procedure from_table(a_amount number, a_half number);
  function get_rows return json_array_t;

  --%test(From another package: half of {a_amount} is {a_half})
  --%testcasesource(tc_sources.get_cases)
  procedure from_other_package(a_amount number, a_half number);

  --%test(From owner and package: half of {a_amount} is {a_half})
  --%testcasesource(ut3_user.tc_sources.get_cases)
  procedure from_owner_and_package(a_amount number, a_half number);

  --%test(From a function with default arguments: half of {a_amount} is {a_half})
  --%testcasesource(get_with_default)
  procedure from_function_with_default(a_amount number, a_half number);
  function get_with_default(a_factor number := 2) return json_array_t;

  --%test(Built with the PL/SQL JSON API)
  --%testcasesource(get_built)
  procedure built(a_day date, a_limit number, a_moment timestamp with time zone);
  function get_built return json_array_t;

  --%test(Empty array)
  --%testcasesource(get_empty)
  procedure empty_array(a_value number);
  function get_empty return json_array_t;

  --%test(Null)
  --%testcasesource(get_null)
  procedure null_result(a_value number);
  function get_null return json_array_t;

  --%test(json_arrayagg over no rows)
  --%testcasesource(get_no_rows)
  procedure no_rows(a_value number);
  function get_no_rows return json_array_t;

  --%test(Object instead of array)
  --%testcasesource(get_object)
  procedure not_an_array(a_value number);
  function get_object return json_array_t;

  --%test(Scalar element)
  --%testcasesource(get_scalar)
  procedure scalar_element(a_value number);
  function get_scalar return json_array_t;

  --%test(Invalid JSON)
  --%testcasesource(get_invalid)
  procedure invalid_json(a_value number);
  function get_invalid return json_array_t;

  --%test(Wrong return type)
  --%testcasesource(get_number)
  procedure wrong_return_type(a_value number);
  function get_number return number;

  --%test(JSON as text)
  --%testcasesource(get_clob)
  procedure json_as_text(a_value number);
  function get_clob return clob;

  --%test(Missing function)
  --%testcasesource(get_nothing)
  procedure missing_function(a_value number);

  --%test(Failing function)
  --%testcasesource(get_failing)
  procedure failing_function(a_value number);
  function get_failing return json_array_t;

  --%test(Disabled)
  --%disabled
  --%testcasesource(get_failing)
  procedure disabled_source(a_value number);

  --%test(Values that don't fit)
  --%testcasesource(get_mismatching)
  procedure mismatching(a_number number, a_text varchar2);
  function get_mismatching return json_array_t;

  --%test(Long values)
  --%testcasesource(get_long)
  procedure long_values(a_text varchar2, a_note clob);
  function get_long return json_array_t;

  --%test
  --%testcasesource(get_one)
  procedure no_description(a_value number);
  function get_one return json_array_t;

  --%test(Overloaded)
  --%testcasesource(get_one)
  procedure overloaded(a_value number);
  procedure overloaded(a_value varchar2, a_other number);
end;~';
    execute immediate q'~create or replace package body tc_json_source as
  procedure fill_rows is
  begin
    insert into test_case_rows values (10, 5);
    insert into test_case_rows values (3, 2);
    insert into test_case_rows values (4, 2);
  end;
  procedure check_half(a_amount number, a_half number) is
  begin
    ut3_develop.ut.expect(a_amount / 2).to_equal(a_half);
  end;
  procedure from_table(a_amount number, a_half number) is
  begin
    check_half(a_amount, a_half);
  end;
  function get_rows return json_array_t is
    l_json clob;
  begin
    select json_arrayagg(json_object('a_amount' value a_amount, 'a_half' value a_half) order by a_amount returning clob)
      into l_json
      from test_case_rows;
    return json_array_t(nvl(l_json, '[]'));
  end;
  procedure from_other_package(a_amount number, a_half number) is
  begin
    check_half(a_amount, a_half);
  end;
  procedure from_owner_and_package(a_amount number, a_half number) is
  begin
    check_half(a_amount, a_half);
  end;
  procedure from_function_with_default(a_amount number, a_half number) is
  begin
    check_half(a_amount, a_half);
  end;
  function get_with_default(a_factor number := 2) return json_array_t is
  begin
    return json_array_t('[[' || 3 * a_factor || ', 3]]');
  end;
  procedure built(a_day date, a_limit number, a_moment timestamp with time zone) is
  begin
    ut3_develop.ut.expect(a_day).to_equal(trunc(sysdate));
    ut3_develop.ut.expect(a_limit).to_equal(c_limit);
    ut3_develop.ut.expect(a_moment).to_be_between(systimestamp - interval '1' minute, systimestamp);
  end;
  function get_built return json_array_t is
    l_cases json_array_t := json_array_t();
    l_case  json_object_t := json_object_t();
  begin
    l_case.put('a_day', trunc(sysdate));
    l_case.put('a_limit', c_limit);
    -- Oracle 19c has no put for TIMESTAMP WITH TIME ZONE; localtimestamp is a TIMESTAMP in the session time zone
    l_case.put('a_moment', localtimestamp);
    l_cases.append(l_case);
    return l_cases;
  end;
  procedure empty_array(a_value number) is
  begin
    null;
  end;
  function get_empty return json_array_t is
  begin
    return json_array_t();
  end;
  procedure null_result(a_value number) is
  begin
    null;
  end;
  function get_null return json_array_t is
  begin
    return null;
  end;
  procedure no_rows(a_value number) is
  begin
    null;
  end;
  function get_no_rows return json_array_t is
    l_json clob;
  begin
    select json_arrayagg(json_array(a_amount) returning clob) into l_json from test_case_rows where 1 = 0;
    -- json_arrayagg returns null when there are no rows, and json_array_t can't parse null
    return json_array_t(nvl(l_json, '[]'));
  end;
  procedure not_an_array(a_value number) is
  begin
    null;
  end;
  function get_object return json_array_t is
  begin
    return json_array_t('{"a_value": 1}');
  end;
  procedure scalar_element(a_value number) is
  begin
    null;
  end;
  function get_scalar return json_array_t is
  begin
    return json_array_t('[[1], 2]');
  end;
  procedure invalid_json(a_value number) is
  begin
    null;
  end;
  function get_invalid return json_array_t is
  begin
    return json_array_t('[[1],');
  end;
  procedure wrong_return_type(a_value number) is
  begin
    null;
  end;
  function get_number return number is
  begin
    return 1;
  end;
  procedure json_as_text(a_value number) is
  begin
    null;
  end;
  function get_clob return clob is
  begin
    return '[[1]]';
  end;
  procedure missing_function(a_value number) is
  begin
    null;
  end;
  procedure failing_function(a_value number) is
  begin
    null;
  end;
  function get_failing return json_array_t is
  begin
    raise_application_error(-20999, 'Test case source failed on purpose');
  end;
  procedure disabled_source(a_value number) is
  begin
    null;
  end;
  procedure mismatching(a_number number, a_text varchar2) is
  begin
    ut3_develop.ut.expect(a_number).to_equal(1);
  end;
  function get_mismatching return json_array_t is
  begin
    return json_array_t('[[1, "x"], ["abc", "x"], [1, "x", 3, 4], {"a_x": 1}, {"a_number": 1, "A_NUMBER": 1}, [1, {"a": 1}], {"a_text": "x"}]');
  end;
  procedure long_values(a_text varchar2, a_note clob) is
  begin
    ut3_develop.ut.expect(length(a_text)).to_equal(5000);
    ut3_develop.ut.expect(dbms_lob.getlength(a_note)).to_equal(100000);
  end;
  function get_long return json_array_t is
    l_note clob;
  begin
    for i in 1 .. 10 loop
      l_note := l_note || rpad('x', 10000, 'x');
    end loop;
    -- parsed as JSON text: Oracle 19c has no append for CLOB, and json_element_t.parse rejects a scalar
    return json_array_t('[["' || rpad('y', 5000, 'y') || '", "' || l_note || '"]]');
  end;
  procedure no_description(a_value number) is
  begin
    null;
  end;
  function get_one return json_array_t is
  begin
    return json_array_t('[[1]]');
  end;
  procedure overloaded(a_value number) is
  begin
    null;
  end;
  procedure overloaded(a_value varchar2, a_other number) is
  begin
    null;
  end;
end;~';

    $if dbms_db_version.version >= 23 $then
    l_boolean_spec := q'~
  --%test(Flag {a_flag} is {a_label})
  --%testcasesource(get_booleans)
  procedure booleans(a_flag boolean, a_label varchar2);
  function get_booleans return sys_refcursor;~';
    l_boolean_body := q'~
  procedure booleans(a_flag boolean, a_label varchar2) is
  begin
    ut3_develop.ut.expect(case when a_flag then 'yes' when not a_flag then 'no' else 'null' end).to_equal(a_label);
  end;
  function get_booleans return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select true a_flag, 'yes' a_label from dual union all
      select false, 'no' from dual union all
      select cast(null as boolean), 'null' from dual;
    return l_cursor;
  end;~';
    $end
    -- named arguments for 200 parameters are longer than the arguments of a test can be
    for i in 1 .. 200 loop
      l_wide_parameters := l_wide_parameters || case when i > 1 then ', ' end || 'c' || i || ' number';
    end loop;
    execute immediate replace(q'~create or replace package tc_cursor_source as
  --%suite(Cursor sources)
  --%beforeall(fill_rows)

  c_limit constant number := 100;
  procedure fill_rows;
  procedure delete_rows;

  --%test(Cursor case {label} with limit {a_limit})
  --%testcasesource(get_by_name)
  procedure by_name(a_day date, a_limit number, a_pair test_case_pair);
  function get_by_name return sys_refcursor;

  --%test(Position: half of {1} is {2})
  --%testcasesource(get_by_position)
  procedure by_position(a_amount number, a_half number);
  function get_by_position return sys_refcursor;

  --%test(Snapshot: half of {a_amount} is {a_half})
  --%testcasesource(get_rows)
  --%beforetest(delete_rows)
  procedure snapshot(a_amount number, a_half number);
  function get_rows return sys_refcursor;

  --%test(No rows)
  --%testcasesource(get_no_rows)
  procedure no_rows(a_value number);
  function get_no_rows return sys_refcursor;

  --%test(Unsupported column)
  --%testcasesource(get_xml)
  procedure unsupported_column(a_xml clob);
  function get_xml return sys_refcursor;

  --%test(Column that doesn't fit)
  --%testcasesource(get_wrong_column)
  procedure column_doesnt_fit(a_pair test_case_pair);
  function get_wrong_column return sys_refcursor;

  --%test(Many rows)
  --%testcasesource(get_many)
  procedure many_rows(a_value number);
  function get_many return sys_refcursor;

  --%test(Cursor types)
  --%testcasesource(get_types)
  procedure types(
    a_char char, a_nchar nchar, a_nvarchar nvarchar2, a_float binary_float, a_double binary_double,
    a_ltz timestamp with local time zone, a_ds interval day to second, a_ym interval year to month,
    a_clob clob, a_nclob nclob, a_blob blob, a_raw raw, a_numbers test_case_numbers
  );
  function get_types return sys_refcursor;

  --%test(Too many columns)
  --%testcasesource(get_wide)
  procedure too_many_columns(<wide_parameters>);
  function get_wide return sys_refcursor;

  --%test(Position count)
  --%testcasesource(get_three)
  procedure position_count(a_amount number, a_half number);
  function get_three return sys_refcursor;

  --%test(Misspelled column)
  --%testcasesource(get_misspelled)
  procedure misspelled_column(a_amount number, a_half number := 0);
  function get_misspelled return sys_refcursor;

  --%test(Missing column)
  --%testcasesource(get_amount)
  procedure missing_column(a_amount number, a_half number);
  function get_amount return sys_refcursor;

  --%test(Duplicate column)
  --%testcasesource(get_duplicate)
  procedure duplicate_column(a_amount number);
  function get_duplicate return sys_refcursor;

  --%test(Lower case {a_amount})
  --%testcasesource(get_lower_case)
  procedure lower_case_column(a_amount number, a_half number := 2);
  function get_lower_case return sys_refcursor;

  --%test(Overloaded)
  --%testcasesource(get_amount)
  procedure overloaded(a_amount number);
  procedure overloaded(a_amount varchar2, a_other number);
~' || l_boolean_spec || q'~
end;~', '<wide_parameters>', l_wide_parameters);
    execute immediate replace(q'~create or replace package body tc_cursor_source as
  procedure fill_rows is
  begin
    insert into test_case_rows values (10, 5);
    insert into test_case_rows values (3, 2);
    insert into test_case_rows values (4, 2);
  end;
  procedure delete_rows is
  begin
    delete from test_case_rows;
  end;
  procedure by_name(a_day date, a_limit number, a_pair test_case_pair) is
  begin
    ut3_develop.ut.expect(a_day).to_be_between(trunc(sysdate), trunc(sysdate) + 1);
    ut3_develop.ut.expect(a_limit).to_be_greater_or_equal(c_limit);
    ut3_develop.ut.expect(a_pair.amount / 2).to_equal(a_pair.half);
  end;
  function get_by_name return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select 'today' label, trunc(sysdate) a_day, c_limit a_limit, test_case_pair(8, 4) a_pair from dual
      union all
      select 'tomorrow', trunc(sysdate) + 1, c_limit * 2, test_case_pair(6, 3) from dual
      order by 1;
    return l_cursor;
  end;
  procedure by_position(a_amount number, a_half number) is
  begin
    ut3_develop.ut.expect(a_amount / 2).to_equal(a_half);
  end;
  function get_by_position return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select 4 x, 2 y from dual union all select 10, 5 from dual;
    return l_cursor;
  end;
  procedure snapshot(a_amount number, a_half number) is
  begin
    ut3_develop.ut.expect(a_amount).to_be_not_null();
    ut3_develop.ut.expect(a_half).to_be_not_null();
  end;
  function get_rows return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select a_amount, a_half from test_case_rows order by a_amount;
    return l_cursor;
  end;
  procedure no_rows(a_value number) is
  begin
    null;
  end;
  function get_no_rows return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select 1 a_value from dual where 1 = 0;
    return l_cursor;
  end;
  procedure unsupported_column(a_xml clob) is
  begin
    null;
  end;
  function get_xml return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select xmltype('<a/>') a_xml from dual;
    return l_cursor;
  end;
  procedure column_doesnt_fit(a_pair test_case_pair) is
  begin
    null;
  end;
  function get_wrong_column return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select 1 a_pair from dual;
    return l_cursor;
  end;
  procedure many_rows(a_value number) is
  begin
    ut3_develop.ut.expect(a_value).to_be_between(1, 300);
  end;
  function get_many return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select level a_value from dual connect by level <= 300;
    return l_cursor;
  end;
  procedure types(
    a_char char, a_nchar nchar, a_nvarchar nvarchar2, a_float binary_float, a_double binary_double,
    a_ltz timestamp with local time zone, a_ds interval day to second, a_ym interval year to month,
    a_clob clob, a_nclob nclob, a_blob blob, a_raw raw, a_numbers test_case_numbers
  ) is
  begin
    ut3_develop.ut.expect(a_char).to_equal('a  ');
    ut3_develop.ut.expect(a_nchar = n'b ').to_be_true();
    ut3_develop.ut.expect(a_nvarchar = n'c').to_be_true();
    ut3_develop.ut.expect(a_float = 1.5f).to_be_true();
    ut3_develop.ut.expect(a_double = 2.5d).to_be_true();
    ut3_develop.ut.expect(cast(a_ltz as timestamp)).to_equal(timestamp '2026-03-31 12:00:00');
    ut3_develop.ut.expect(a_ds).to_equal(interval '1 02:00:00' day to second);
    ut3_develop.ut.expect(a_ym).to_equal(interval '1-2' year to month);
    ut3_develop.ut.expect(a_clob).to_equal(to_clob('long'));
    ut3_develop.ut.expect(to_clob(a_nclob)).to_equal(to_clob('nlong'));
    ut3_develop.ut.expect(a_blob).to_equal(to_blob(hextoraw('0AFF')));
    ut3_develop.ut.expect(rawtohex(a_raw)).to_equal('0BEE');
    ut3_develop.ut.expect(a_numbers.count).to_equal(2);
  end;
  function get_types return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select cast('a' as char(3)) a_char, cast(n'b' as nchar(2)) a_nchar, cast(n'c' as nvarchar2(10)) a_nvarchar,
             cast(1.5 as binary_float) a_float, cast(2.5 as binary_double) a_double,
             cast(timestamp '2026-03-31 12:00:00' as timestamp with local time zone) a_ltz,
             interval '1 02:00:00' day to second a_ds, interval '1-2' year to month a_ym,
             to_clob('long') a_clob, to_nclob('nlong') a_nclob, to_blob(hextoraw('0AFF')) a_blob, hextoraw('0BEE') a_raw,
             test_case_numbers(1, 2) a_numbers
        from dual;
    return l_cursor;
  end;
  procedure too_many_columns(<wide_parameters>) is
  begin
    null;
  end;
  function get_wide return sys_refcursor is
    l_cursor sys_refcursor;
    l_select varchar2(32767);
  begin
    for i in 1 .. 200 loop
      l_select := l_select || case when i > 1 then ', ' end || i || ' c' || i;
    end loop;
    open l_cursor for 'select ' || l_select || ' from dual';
    return l_cursor;
  end;
  procedure position_count(a_amount number, a_half number) is
  begin
    null;
  end;
  function get_three return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select 4 x, 2 y, 0 z from dual;
    return l_cursor;
  end;
  procedure misspelled_column(a_amount number, a_half number := 0) is
  begin
    null;
  end;
  function get_misspelled return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select 4 a_amount, 2 a_halv from dual;
    return l_cursor;
  end;
  procedure missing_column(a_amount number, a_half number) is
  begin
    null;
  end;
  function get_amount return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select 4 a_amount from dual;
    return l_cursor;
  end;
  procedure duplicate_column(a_amount number) is
  begin
    null;
  end;
  function get_duplicate return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select 4 a_amount, 5 "a_amount" from dual;
    return l_cursor;
  end;
  procedure lower_case_column(a_amount number, a_half number := 2) is
  begin
    ut3_develop.ut.expect(a_amount / 2).to_equal(a_half);
  end;
  function get_lower_case return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for select 4 "a_amount" from dual;
    return l_cursor;
  end;
  procedure overloaded(a_amount number) is
  begin
    null;
  end;
  procedure overloaded(a_amount varchar2, a_other number) is
  begin
    null;
  end;
~' || l_boolean_body || q'~
end;~', '<wide_parameters>', l_wide_parameters);

    execute immediate q'~create or replace package tc_times as
  --%suite(Dates and times)

  --%test(JSON {1})
  --%testcase(["2026-03-31T12:00:00-05:00", "2026-03-31T12:00:00.123456", "2026-03-31T12:00:00", "2026-03-31T12:00:00Z"])
  --%testcase({"a_date": "2026-03-31T12:00:00 -05:00", "a_ts": "2026-03-31T12:00:00.123456", "a_tz": "2026-03-31T12:00:00", "a_ltz": "2026-03-31T12:00:00Z"})
  procedure json_strings(a_date date, a_ts timestamp, a_tz timestamp with time zone, a_ltz timestamp with local time zone);

  --%test(Cursor)
  --%testcasesource(get_times)
  procedure cursor_values(a_date date, a_ts timestamp, a_tz timestamp with time zone, a_ltz timestamp with local time zone);
  function get_times return sys_refcursor;

  --%test(Date only {1})
  --%testcase(["2026-03-15", "2026-03-15"])
  procedure date_only(a_date date, a_ts timestamp);

  --%test(Other format {1})
  --%testcase(["31.03.2026"])
  procedure other_format(a_date date);
end;~';
    execute immediate q'~create or replace package body tc_times as
  procedure check_values(a_date date, a_ts timestamp, a_tz timestamp with time zone, a_ltz timestamp with local time zone) is
  begin
    -- a time zone is dropped when the value is assigned to a DATE or TIMESTAMP, as in any PL/SQL assignment
    ut3_develop.ut.expect(to_char(a_date, 'yyyy-mm-dd hh24:mi:ss')).to_equal('2026-03-31 12:00:00');
    ut3_develop.ut.expect(to_char(a_ts, 'yyyy-mm-dd hh24:mi:ss.ff6')).to_equal('2026-03-31 12:00:00.123456');
    -- a value without time zone gets the session time zone; its offset on that date, not today (daylight saving time)
    ut3_develop.ut.expect(to_char(a_tz, 'yyyy-mm-dd hh24:mi:ss tzh:tzm')).to_equal(
      to_char(from_tz(timestamp '2026-03-31 12:00:00', sessiontimezone), 'yyyy-mm-dd hh24:mi:ss tzh:tzm')
    );
    ut3_develop.ut.expect(to_char(a_ltz, 'yyyy-mm-dd hh24:mi:ss')).to_equal(
      to_char(from_tz(timestamp '2026-03-31 12:00:00', '+00:00') at time zone sessiontimezone, 'yyyy-mm-dd hh24:mi:ss')
    );
  end;
  procedure json_strings(a_date date, a_ts timestamp, a_tz timestamp with time zone, a_ltz timestamp with local time zone) is
  begin
    check_values(a_date, a_ts, a_tz, a_ltz);
  end;
  procedure cursor_values(a_date date, a_ts timestamp, a_tz timestamp with time zone, a_ltz timestamp with local time zone) is
  begin
    check_values(a_date, a_ts, a_tz, a_ltz);
  end;
  function get_times return sys_refcursor is
    l_cursor sys_refcursor;
  begin
    open l_cursor for
      select to_timestamp_tz('2026-03-31 12:00:00 -05:00', 'yyyy-mm-dd hh24:mi:ss tzh:tzm') a_date,
             to_timestamp('2026-03-31 12:00:00.123456', 'yyyy-mm-dd hh24:mi:ss.ff6') a_ts,
             cast(timestamp '2026-03-31 12:00:00' as timestamp with time zone) a_tz,
             to_timestamp_tz('2026-03-31 12:00:00 +00:00', 'yyyy-mm-dd hh24:mi:ss tzh:tzm') a_ltz
        from dual;
    return l_cursor;
  end;
  procedure date_only(a_date date, a_ts timestamp) is
  begin
    ut3_develop.ut.expect(to_char(a_date, 'yyyy-mm-dd hh24:mi:ss')).to_equal('2026-03-15 00:00:00');
    ut3_develop.ut.expect(to_char(a_ts, 'yyyy-mm-dd hh24:mi:ss.ff3')).to_equal('2026-03-15 00:00:00.000');
  end;
  procedure other_format(a_date date) is
  begin
    null;
  end;
end;~';
  end;

  procedure drop_test_case_suites is
    pragma autonomous_transaction;
  begin
    for r in (
      select object_name, object_type
        from user_objects
       where object_name in (
               'TC_DISCOUNT_PLSQL', 'TC_DISCOUNT_JSON', 'TC_DISCOUNT_SOURCE', 'TC_DISCOUNT_CURSOR',
               'TC_INLINE', 'TC_SOURCES', 'TC_JSON_SOURCE', 'TC_CURSOR_SOURCE', 'TC_TIMES', 'GET_DISCOUNT'
             )
         and object_type in ('PACKAGE', 'FUNCTION')
    ) loop
      execute immediate 'drop ' || r.object_type || ' ' || r.object_name;
    end loop;
    execute immediate 'drop table test_case_rows purge';
    execute immediate 'drop type test_case_numbers';
    execute immediate 'drop type test_case_pair';
  end;

  -- other NLS settings and session time zone than usual, to show that test cases don't depend on them
  procedure set_other_session is
  begin
    g_time_zone := sessiontimezone;
    select ut3_develop.ut_key_value_pair(parameter, value)
      bulk collect into g_nls_parameters
      from nls_session_parameters
     where parameter in ('NLS_DATE_FORMAT', 'NLS_TIMESTAMP_FORMAT', 'NLS_TIMESTAMP_TZ_FORMAT', 'NLS_NUMERIC_CHARACTERS');
    execute immediate q'[alter session set time_zone = '+02:00']';
    execute immediate q'[alter session set nls_date_format = 'DD.MM.YYYY']';
    execute immediate q'[alter session set nls_timestamp_format = 'DD.MM.YYYY HH24:MI:SSXFF']';
    execute immediate q'[alter session set nls_timestamp_tz_format = 'DD.MM.YYYY HH24:MI:SSXFF TZR']';
    execute immediate q'[alter session set nls_numeric_characters = ',.']';
  end;

  procedure restore_session is
  begin
    execute immediate 'alter session set time_zone = ''' || g_time_zone || '''';
    for i in 1 .. g_nls_parameters.count loop
      execute immediate 'alter session set ' || g_nls_parameters(i).key || ' = ''' || g_nls_parameters(i).value || '''';
    end loop;
  end;

  function run_report(a_path varchar2) return clob is
    l_results ut3_develop.ut_varchar2_list;
  begin
    select * bulk collect into l_results from table(ut3_develop.ut.run(a_path));
    return ut3_tester_helper.main_helper.table_to_clob(l_results);
  end;

  -- the lines of the report that start with a_prefix, without execution times
  function report_lines(a_path varchar2, a_prefix varchar2) return varchar2 is
    l_results ut3_develop.ut_varchar2_list;
    l_result  varchar2(32767);
  begin
    select * bulk collect into l_results from table(ut3_develop.ut.run(a_path));
    for i in 1 .. l_results.count loop
      if ltrim(l_results(i)) like a_prefix || '%' then
        l_result := l_result || case when l_result is not null then chr(10) end
          || regexp_replace(trim(l_results(i)), ' \[[^]]*\]( \(FAILED - [0-9]+\))?$', '\1');
      end if;
    end loop;
    return l_result;
  end;

  procedure discount_json_arguments is
  begin
    ut.expect(report_lines('tc_discount_json', 'Discount for')).to_equal(c_discount_cases);
    ut.expect(run_report('tc_discount_json')).to_be_like('%4 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%');
  end;

  procedure discount_json_source is
  begin
    ut.expect(report_lines('tc_discount_source', 'Discount for')).to_equal(c_discount_cases);
    ut.expect(run_report('tc_discount_source')).to_be_like('%4 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%');
  end;

  procedure discount_cursor_source is
  begin
    ut.expect(report_lines('tc_discount_cursor', 'Discount for')).to_equal(c_discount_cases);
    ut.expect(run_report('tc_discount_cursor')).to_be_like('%4 tests, 0 failed, 0 errored, 0 disabled, 0 warning(s)%');
  end;

  procedure discount_independent_of_nls is
    l_lines varchar2(32767);
  begin
    set_other_session();
    for r in (
      select column_value suite
        from table(ut3_develop.ut_varchar2_list(
               'tc_discount_json', 'tc_discount_source', 'tc_discount_cursor'
             ))
    ) loop
      l_lines := report_lines(r.suite, 'Discount for');
      ut.expect(l_lines, r.suite).to_equal(c_discount_cases);
    end loop;
    restore_session();
  exception
    when others then
      restore_session();
      raise;
  end;

  procedure testcase_runs_each_case is
  begin
    ut.expect(report_lines('tc_inline.half', 'Half of')).to_equal(
      'Half of 2000 is 1000' || chr(10) ||
      'Half of 10 is 5' || chr(10) ||
      'Half of 3 is 2 (FAILED - 1)' || chr(10) ||
      'Half of 8 is 4' || chr(10) ||
      'Half of 1 is 1 (FAILED - 2)'
    );
  end;

  procedure testcase_by_path is
  begin
    ut.expect(run_report('tc_inline.half')).to_be_like('%5 tests, 2 failed, 0 errored%');
  end;

  procedure testcase_single_case_by_path is
  begin
    ut.expect(run_report('tc_inline.half[5]')).to_be_like('%Half of 1 is 1 [%1 tests, 1 failed, 0 errored%');
    ut.expect(run_report(':tc_inline.half[2]')).to_be_like('%Half of 10 is 5 [%1 tests, 0 failed, 0 errored%');
    ut.expect(run_report('tc_inline.half[4]')).to_be_like('%Half of 8 is 4 [%1 tests, 0 failed, 0 errored%');
  end;

  procedure testcase_number_on_package is
    l_results ut3_develop.ut_varchar2_list;
  begin
    select * bulk collect into l_results from table(ut3_develop.ut.run('tc_inline[2]'));
  end;

  procedure testcase_reported_names is
    l_results ut3_develop.ut_varchar2_list;
  begin
    ut.expect(run_report('tc_inline.half')).to_be_like('%Failures:%1) half[3]%2) half[5]%');

    select * bulk collect into l_results
      from table(ut3_develop.ut.run('tc_inline.half', ut3_develop.ut_junit_reporter()));
    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_results)).to_be_like(
      '%<testcase classname="tc_inline"%name="Half of 2000 is 1000"%' ||
      '%<testcase classname="tc_inline"%name="Half of 1 is 1"%'
    );

    select * bulk collect into l_results
      from table(ut3_develop.ut.run('tc_inline.half', ut3_develop.ut_teamcity_reporter()));
    ut.expect(ut3_tester_helper.main_helper.table_to_clob(l_results)).to_be_like(
      '%testStarted%name=''ut3_user.tc_inline.half|[1|]''%' ||
      '%testStarted%name=''ut3_user.tc_inline.half|[5|]''%'
    );
  end;

  procedure testcase_strings is
  begin
    ut.expect(report_lines('tc_inline.strings', 'Text')).to_equal(
      'Text it''s "quoted"' || chr(10) ||
      'Text it''s "quoted"' || chr(10) ||
      'Text ' || unistr('\00e4\00f6\00fc\20ac') || chr(10) ||
      'Text ' || unistr('\00e4\00f6\00fc\20ac')
    );
    ut.expect(run_report('tc_inline.strings')).to_be_like('%4 tests, 0 failed, 0 errored%');
  end;

  procedure testcase_defaults is
  begin
    ut.expect(run_report('tc_inline.defaults')).to_be_like('%Default for 1 [%Default for 2 [%Default for 3 [%3 tests, 0 failed, 0 errored%');
  end;

  procedure testcase_json_conversions is
  begin
    ut.expect(run_report('tc_inline.conversions')).to_be_like('%1 tests, 0 failed, 0 errored%');
  end;

  procedure testcase_json_booleans is
  begin
    ut.expect(run_report('tc_inline.booleans')).to_be_like(
      '%Flag true is yes [%Flag false is no [%Flag null is null [%Flag yes is error [%' ||
      'booleans[4]%Invalid JSON test case: true or false expected instead of "yes".%' ||
      '4 tests, 0 failed, 1 errored%'
    );
  end;

  procedure testcase_json_objects is
  begin
    ut.expect(run_report('tc_inline.objects')).to_be_like(
      '%objects[4]%ORA-40601%objects[5]%ORA-40601%' ||
      'objects[6]%Invalid JSON test case: a JSON array expected instead of 5.%6 tests, 0 failed, 3 errored%'
    );
  end;

  procedure testcase_json_unsupported_type is
  begin
    ut.expect(run_report('tc_inline.unsupported')).to_be_like(
      '%Invalid JSON test case: parameter A_XML has a data type that can''t be passed from JSON: XMLTYPE.%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure testcase_json_overloaded is
  begin
    ut.expect(run_report('tc_inline.overloaded')).to_be_like(
      '%Invalid JSON test case: JSON test cases can''t be used with the overloaded procedure OVERLOADED.%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure testcase_not_json is
  begin
    ut.expect(run_report('tc_inline.not_json')).to_be_like(
      '%Not JSON (1, 2) [%Annotation "--%testcase" has invalid arguments: a JSON array or object is expected. Annotation ignored.%' ||
      '1 tests, 0 failed, 0 errored, 0 disabled, 1 warning(s)%'
    );
  end;

  procedure testcase_arguments_dont_fit is
  begin
    ut.expect(run_report('tc_inline.arguments_dont_fit')).to_be_like(
      '%arguments_dont_fit[2]%Invalid JSON test case: a JSON object expected instead of 1.%' ||
      'arguments_dont_fit[3]%ORA-40603%3 tests, 0 failed, 2 errored%'
    );
  end;

  procedure source_json_after_beforeall is
  begin
    ut.expect(run_report('tc_json_source.from_table')).to_be_like(
      '%Half of 3 from table is 2 [% (FAILED - 1)%Half of 4 from table is 2 [%Half of 10 from table is 5 [%' ||
      '%1) from_table[1]%3 tests, 1 failed, 0 errored%'
    );
  end;

  procedure source_json_function_reference is
  begin
    ut.expect(run_report('tc_json_source.from_other_package')).to_be_like(
      '%From another package: half of 4 is 2 [%From another package: half of 10 is 5 [%2 tests, 0 failed, 0 errored%'
    );
    ut.expect(run_report('tc_json_source.from_owner_and_package')).to_be_like('%2 tests, 0 failed, 0 errored%');
    ut.expect(run_report('tc_json_source.from_function_with_default')).to_be_like(
      '%From a function with default arguments: half of 6 is 3 [%1 tests, 0 failed, 0 errored%'
    );
  end;

  procedure source_json_built is
  begin
    ut.expect(run_report('tc_json_source.built')).to_be_like('%1 tests, 0 failed, 0 errored%');
  end;

  procedure source_json_no_test_cases is
  begin
    for r in (select column_value test_name from table(ut3_develop.ut_varchar2_list('empty_array', 'null_result', 'no_rows'))) loop
      ut.expect(run_report('tc_json_source.' || r.test_name), r.test_name).to_be_like(
        '%The --%testcasesource function returned no test cases.%0 tests, 0 failed, 0 errored, 0 disabled, 1 warning(s)%'
      );
    end loop;
  end;

  procedure source_json_invalid_result is
  begin
    ut.expect(run_report('tc_json_source.not_an_array')).to_be_like(
      '%The --%testcasesource function failed.%ORA-40587%1 tests, 0 failed, 1 errored%'
    );
    ut.expect(run_report('tc_json_source.scalar_element')).to_be_like(
      '%The --%testcasesource function get_scalar returned element 2, which is neither a JSON array nor a JSON object.%' ||
      '1 tests, 0 failed, 1 errored%'
    );
    ut.expect(run_report('tc_json_source.invalid_json')).to_be_like(
      '%The --%testcasesource function failed.%ORA-40441%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_function_errors is
  begin
    ut.expect(run_report('tc_json_source.wrong_return_type')).to_be_like(
      '%The --%testcasesource function get_number must return json_array_t or sys_refcursor, not NUMBER.%1 tests, 0 failed, 1 errored%'
    );
    ut.expect(run_report('tc_json_source.json_as_text')).to_be_like(
      '%The --%testcasesource function get_clob must return json_array_t or sys_refcursor, not CLOB.%1 tests, 0 failed, 1 errored%'
    );
    ut.expect(run_report('tc_json_source.missing_function')).to_be_like(
      '%The --%testcasesource function get_nothing doesn''t exist or can''t be called without arguments.%1 tests, 0 failed, 1 errored%'
    );
    ut.expect(run_report('tc_json_source.failing_function')).to_be_like(
      '%The --%testcasesource function failed.%ORA-20999: Test case source failed on purpose%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_disabled is
  begin
    ut.expect(run_report('tc_json_source.disabled_source')).to_be_like('%1 tests, 0 failed, 0 errored, 1 disabled%');
  end;

  procedure testcase_json_more_types is
  begin
    ut.expect(run_report('tc_inline.more_types')).to_be_like('%1 tests, 0 failed, 0 errored%');
  end;

  procedure testcase_without_parameters is
  begin
    ut.expect(run_report('tc_inline.no_parameters')).to_be_like('%2 tests, 0 failed, 0 errored%');
  end;

  procedure testcase_json_record_parameter is
  begin
    ut.expect(run_report('tc_inline.record_parameter')).to_be_like(
      '%Invalid JSON test case: parameter A_RECORD has a data type that can''t be passed from JSON: TC_INLINE.T_RECORD.%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure testcase_json_package_types is
  begin
    ut.expect(run_report('tc_inline.package_collection_parameter')).to_be_like(
      '%parameter A_NUMBERS has a data type that can''t be passed from JSON: TC_INLINE.T_NUMBERS.%1 tests, 0 failed, 1 errored%'
    );
    ut.expect(run_report('tc_inline.json_object_parameter')).to_be_like(
      '%parameter A_OBJECT has a data type that can''t be passed from JSON: JSON_OBJECT_T.%1 tests, 0 failed, 1 errored%'
    );
    ut.expect(run_report('tc_inline.blob_parameter')).to_be_like(
      '%parameter A_BLOB has a data type that can''t be passed from JSON: BLOB.%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_json_overloaded is
  begin
    ut.expect(run_report('tc_json_source.overloaded')).to_be_like(
      '%Invalid JSON test case: JSON test cases can''t be used with the overloaded procedure OVERLOADED.%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_cursor_types is
  begin
    ut.expect(run_report('tc_cursor_source.types')).to_be_like(
      '%Cursor types (a  , b , c, 1.5, 2.5, %, long, nlong, <value>, 0BEE, <%TEST_CASE_NUMBERS>) [%1 tests, 0 failed, 0 errored%'
    );
  end;

  procedure source_cursor_too_many_columns is
  begin
    ut.expect(run_report('tc_cursor_source.too_many_columns')).to_be_like(
      '%The --%testcasesource function get_wide returned more columns than can be passed to the test procedure.%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_cursor_position_count is
  begin
    ut.expect(run_report('tc_cursor_source.position_count')).to_be_like(
      '%The --%testcasesource function get_three returned 3 column(s) and none is named like a parameter, but the test procedure has 2 parameter(s);%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_cursor_misspelled_column is
  begin
    ut.expect(run_report('tc_cursor_source.misspelled_column')).to_be_like(
      '%The --%testcasesource function get_misspelled returned column A_HALV, which is no parameter of the test procedure and isn''t used in the description.%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_cursor_missing_column is
  begin
    ut.expect(run_report('tc_cursor_source.missing_column')).to_be_like(
      '%The --%testcasesource function get_amount returned no column for parameter A_HALF, which has no default value.%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_cursor_duplicate_column is
  begin
    ut.expect(run_report('tc_cursor_source.duplicate_column')).to_be_like(
      '%The --%testcasesource function get_duplicate returned columns A_AMOUNT and a_amount for the same parameter A_AMOUNT.%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_cursor_lower_case_column is
  begin
    ut.expect(run_report('tc_cursor_source.lower_case_column')).to_be_like('%Lower case 4 [%1 tests, 0 failed, 0 errored%');
  end;

  procedure source_cursor_overloaded is
  begin
    ut.expect(run_report('tc_cursor_source.overloaded')).to_be_like(
      '%The --%testcasesource function get_amount can''t be used with the overloaded procedure OVERLOADED.%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_json_values_dont_fit is
  begin
    ut.expect(run_report('tc_json_source.mismatching')).to_be_like(
      '%mismatching[2]%ORA-01722%' ||
      'mismatching[3]%Invalid JSON test case: 4 value(s) given, but the procedure has 2 parameter(s).%' ||
      'mismatching[4]%Invalid JSON test case: the procedure has no parameter a_x.%' ||
      'mismatching[5]%Invalid JSON test case: parameter A_NUMBER is given twice.%' ||
      'mismatching[6]%' ||
      'mismatching[7]%Invalid JSON test case: no value for parameter A_NUMBER, which has no default value.%' ||
      '7 tests, 0 failed, 6 errored%'
    );
  end;

  procedure source_json_long_values is
  begin
    ut.expect(run_report('tc_json_source.long_values')).to_be_like('%1 tests, 0 failed, 0 errored%');
  end;

  procedure source_no_description is
  begin
    ut.expect(run_report('tc_json_source.no_description')).to_be_like('%no_description[1] [%1 tests, 0 failed, 0 errored%');
  end;

  procedure source_cursor_by_name is
  begin
    ut.expect(report_lines('tc_cursor_source.by_name', 'Cursor case')).to_equal(
      'Cursor case today with limit 100' || chr(10) ||
      'Cursor case tomorrow with limit 200'
    );
    ut.expect(run_report('tc_cursor_source.by_name')).to_be_like('%2 tests, 0 failed, 0 errored%');
  end;

  procedure source_cursor_by_position is
  begin
    ut.expect(run_report('tc_cursor_source.by_position')).to_be_like(
      '%Position: half of 4 is 2 [%Position: half of 10 is 5 [%2 tests, 0 failed, 0 errored%'
    );
  end;

  procedure source_cursor_snapshot is
  begin
    ut.expect(run_report('tc_cursor_source.snapshot')).to_be_like('%3 tests, 0 failed, 0 errored%');
  end;

  procedure source_cursor_no_rows is
  begin
    ut.expect(run_report('tc_cursor_source.no_rows')).to_be_like(
      '%The --%testcasesource function returned no test cases.%0 tests, 0 failed, 0 errored, 0 disabled, 1 warning(s)%'
    );
  end;

  procedure source_cursor_unsupported_column is
  begin
    ut.expect(run_report('tc_cursor_source.unsupported_column')).to_be_like(
      '%The --%testcasesource function get_xml returned column A_XML, which has a data type that can''t be passed to the test: XMLTYPE.%' ||
      '1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_cursor_column_doesnt_fit is
  begin
    ut.expect(run_report('tc_cursor_source.column_doesnt_fit')).to_be_like(
      '%The --%testcasesource function get_wrong_column returned column A_PAIR of type NUMBER, which can''t be passed to parameter A_PAIR of type %.TEST_CASE_PAIR.%1 tests, 0 failed, 1 errored%'
    );
  end;

  procedure source_cursor_many_rows is
  begin
    ut.expect(run_report('tc_cursor_source.many_rows')).to_be_like('%300 tests, 0 failed, 0 errored%');
  end;

  $if dbms_db_version.version >= 23 $then
  procedure source_cursor_booleans is
  begin
    ut.expect(run_report('tc_cursor_source.booleans')).to_be_like(
      '%Flag true is yes [%Flag false is no [%Flag null is null [%3 tests, 0 failed, 0 errored%'
    );
  end;
  $end

  procedure times_json_and_cursor_alike is
  begin
    set_other_session();
    ut.expect(run_report('tc_times.json_strings'), 'JSON').to_be_like('%2 tests, 0 failed, 0 errored%');
    ut.expect(run_report('tc_times.cursor_values'), 'cursor').to_be_like('%1 tests, 0 failed, 0 errored%');
    restore_session();
  exception
    when others then
      restore_session();
      raise;
  end;

  procedure times_date_only is
  begin
    set_other_session();
    ut.expect(run_report('tc_times.date_only')).to_be_like('%1 tests, 0 failed, 0 errored%');
    restore_session();
  exception
    when others then
      restore_session();
      raise;
  end;

  procedure times_invalid_format is
  begin
    ut.expect(run_report('tc_times.other_format')).to_be_like(
      '%other_format[1]%ORA-01%1 tests, 0 failed, 1 errored%'
    );
  end;

end;
/
