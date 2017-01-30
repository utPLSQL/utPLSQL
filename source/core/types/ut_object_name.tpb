create or replace type body ut_object_name as
  map member function identity return varchar2 is
  begin
    return owner||'.'||name;
  end;
end;
/
