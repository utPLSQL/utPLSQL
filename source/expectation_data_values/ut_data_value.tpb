create or replace type body ut_data_value as
  final member procedure init(self in out nocopy ut_data_value, a_type varchar2, a_is_null number, a_value_string varchar2) is
  begin
    self.type := a_type;
    self.is_null := a_is_null;
    self.value_string := a_value_string;
  end;
end;
/
