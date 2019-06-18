create or replace package body utplsql is

  procedure global_setup is
  begin
    --we need to have dbms_output enable for our tests
    --TODO - move this to utPLSQL-cli once cli has support for it.
    dbms_output.enable(null);
  end;

end;
/
