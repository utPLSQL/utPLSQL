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
    l_result boolean;
  begin
    if a_actual is of (ut_data_value_varchar2) then
      l_result := regexp_like(treat(a_actual as ut_data_value_varchar2).data_value, pattern, modifiers);
    elsif a_actual is of (ut_data_value_clob) then
      l_result := regexp_like(treat(a_actual as ut_data_value_clob).data_value, pattern, modifiers);
    else 
      l_result := (self as ut_matcher).run_matcher(a_actual);
    end if;
    return l_result;
  end;

end;
/
