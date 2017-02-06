create or replace type body ut_match as

  constructor function ut_match(self in out nocopy ut_match, a_pattern in varchar2, a_modifiers in varchar2 default null) return self as result is
  begin
    if a_pattern is not null then
     self.additional_info := 'pattern '''||a_pattern||'''';
     if a_modifiers is not null then
       self.additional_info := self.additional_info ||', modifiers '''||a_modifiers||'''';
     end if;
    end if;
    self.name      := 'match';
    self.pattern   := a_pattern;
    self.modifiers := a_modifiers;
    return;
  end;

  overriding member function run_matcher(self in out nocopy ut_match, a_actual ut_data_value) return boolean is
  begin
    return
      case
        when a_actual is of (ut_data_value_varchar2)
        then regexp_like(treat(a_actual as ut_data_value_varchar2).data_value, pattern, modifiers)
        when a_actual is of (ut_data_value_clob)
        then regexp_like(treat(a_actual as ut_data_value_clob).data_value, pattern, modifiers)
        else (self as ut_matcher).run_matcher(a_actual)
      end;
  end;

end;
/
