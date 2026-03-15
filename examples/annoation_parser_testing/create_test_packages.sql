declare
  c_packages        constant pls_integer := 1000;
  c_procs_per_pkg   constant pls_integer := 20;

  l_spec   varchar2(32767);
  l_body   varchar2(32767);
  l_pkg    varchar2(30);
  l_errors pls_integer := 0;

  procedure append_to_source(a_source in out nocopy varchar2, a_text varchar2) is
  begin
    a_source := a_source || a_text;
  end;

  procedure append_line(a_source in out nocopy varchar2, a_text varchar2 default null) is
  begin
    a_source := a_source || a_text || chr(10);
  end;

begin

 for r in (
    select object_name
      from user_objects
     where object_name like 'TST_GEN_PKG_%'
       and object_type = 'PACKAGE'
     order by object_name
  ) loop
    begin
      execute immediate 'drop package ' || r.object_name;
    exception
      when others then
        dbms_output.put_line('ERROR dropping ' || r.object_name || ': ' || sqlerrm);
    end;
  end loop;
  dbms_output.put_line('Existing packages dropped.');

  for p in 1 .. c_packages loop
    l_pkg  := 'TST_GEN_PKG_' || lpad(p, 4, '0');
    l_spec := null;
    l_body := null;

    -- Package spec
    append_line(l_spec, 'create or replace package ' || l_pkg || ' as');
    append_line(l_spec);
    append_line(l_spec, '  --%suite(Generated suite ' || p || ')');
    append_line(l_spec, '  --%suitepath(generated.vol_test)');

    if mod(p, 3) = 0 then
      append_line(l_spec, '  --%displayname(Suite display name for pkg ' || p || ')');
    end if;
    if mod(p, 5) = 0 then
      append_line(l_spec, '  --%rollback(manual)');
    end if;

    append_line(l_spec);
    append_line(l_spec, '  --%beforeall');
    append_line(l_spec, '  procedure setup_suite;');
    append_line(l_spec);
    append_line(l_spec, '  --%afterall');
    append_line(l_spec, '  procedure teardown_suite;');
    append_line(l_spec);
    append_line(l_spec, '  --%beforeeach');
    append_line(l_spec, '  procedure setup_test;');
    append_line(l_spec);
    append_line(l_spec, '  --%aftereach');
    append_line(l_spec, '  procedure teardown_test;');
    append_line(l_spec);

    for i in 1 .. c_procs_per_pkg loop
      declare
        l_proc varchar2(30) := 'test_proc_' || lpad(i, 3, '0');
      begin
        if mod(i - 1, 5) = 0 then
          append_line(l_spec, '  --%context(context_' || ceil(i/5) || ')');
          append_line(l_spec);
        end if;

        if mod(i, 4) = 0 then
          append_line(l_spec, '  /* multi-line comment for ' || l_proc || ' */');
        end if;

        append_line(l_spec, '  --%test(Test ' || i || ' in pkg ' || p || ')');

        if mod(i, 3) = 0 then
          append_line(l_spec, '  --%tags(tag_' || mod(i,5) || ',smoke)');
        end if;
        if mod(i, 6) = 0 then
          append_line(l_spec, '  --%throws(-20001)');
        end if;
        if mod(i, 8) = 0 then
          append_line(l_spec, '  --%disabled(generated disabled test ' || i || ')');
        end if;
        if mod(i, 5) = 0 then
          append_line(l_spec, '  --%beforetest(setup_test)');
          append_line(l_spec, '  --%aftertest(teardown_test)');
        end if;

        append_line(l_spec, '  -- regular comment');
        append_line(l_spec, '  procedure ' || l_proc || ';');
        append_line(l_spec);

        if mod(i, 5) = 0 then
          append_line(l_spec, '  --%endcontext');
          append_line(l_spec);
        end if;
      end;
    end loop;

    append_line(l_spec, 'end ' || l_pkg || ';');

    -- -----------------------------------------------------------------------
    -- Package body
    -- -----------------------------------------------------------------------
    append_line(l_body, 'create or replace package body ' || l_pkg || ' as');
    append_line(l_body);

    for stub in (
      select column_value as proc_name
        from table(ut_varchar2_list(
          'setup_suite','teardown_suite',
          'setup_test','teardown_test'
        ))
    ) loop
      append_line(l_body, '  procedure ' || stub.proc_name || ' is');
      append_line(l_body, '  begin');
      append_line(l_body, '    null;');
      append_line(l_body, '  end ' || stub.proc_name || ';');
      append_line(l_body);
    end loop;

    for i in 1 .. c_procs_per_pkg loop
      declare
        l_proc varchar2(30) := 'test_proc_' || lpad(i, 3, '0');
      begin
        append_line(l_body, '  procedure ' || l_proc || ' is');
        append_line(l_body, '  begin');
        if mod(i, 4) = 0 then
          append_line(l_body, '    ut.expect(''/* not a comment */'').to_equal(''/* not a comment */'');');
        elsif mod(i, 4) = 1 then
          append_line(l_body, '    ut.expect(' || i || ').to_be_greater_than(0);');
        elsif mod(i, 4) = 2 then
          append_line(l_body, '    ut.expect(q''[-- not a comment]'').to_equal(q''[-- not a comment]'');');
        else
          append_line(l_body, '    ut.expect(''test_' || i || ''').not_to_be_null();');
        end if;
        append_line(l_body, '  end ' || l_proc || ';');
        append_line(l_body);
      end;
    end loop;

    append_line(l_body, 'end ' || l_pkg || ';');

    -- Execute DDL — with error capture so one bad package doesn't stop all
    begin
      execute immediate l_spec;
      execute immediate l_body;
    exception
      when others then
        l_errors := l_errors + 1;
        dbms_output.put_line('ERROR on ' || l_pkg || ': ' || sqlerrm);
    end;

    if mod(p, 100) = 0 then
      dbms_output.put_line('Created ' || p || ' packages...');
    end if;

  end loop;

  dbms_output.put_line('----------------------------------------');
  dbms_output.put_line('Done. packages=' || c_packages ||
                        '  errors=' || l_errors);

  -- quick sanity check
  declare
    l_count pls_integer;
  begin
    select count(*) into l_count
      from user_objects
     where object_name like 'TST_GEN_PKG_%'
       and object_type = 'PACKAGE';
    dbms_output.put_line('Packages in user_objects: ' || l_count);
  end;
end;
/
