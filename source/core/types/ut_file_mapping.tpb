create or replace type body ut_file_mapping as
  map member function pk return varchar2 is
  begin
    return file_name;
  end;
end;
/
