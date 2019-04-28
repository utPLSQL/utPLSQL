create or replace package test_user is

  --%suite
  --%suitepath(utplsql)

  --%beforeall
  procedure global_setup;
  
end;
/
