create or replace noneditionable package body ut_suite_tag_filter is
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

  /**
  * Constants use in postfix and infix transformations
  */
  gc_operators constant ut_varchar2_list := ut_varchar2_list('|','&','!');
  gc_unary_operators constant ut_varchar2_list := ut_varchar2_list('!'); -- right side associative operator
  gc_binary_operators constant ut_varchar2_list := ut_varchar2_list('|','&'); -- left side associative operator
  gc_reserved_tag_words constant ut_varchar2_list := ut_varchar2_list('none','any');
  gc_exception_msg constant varchar2(200) := 'Invalid tag expression';

  type t_precedence_table is table of number index by varchar2(1);
  g_precedence t_precedence_table;

  --last tag expression and its condition, see create_where_filter
  g_last_tag_expression varchar2(4000);
  g_last_tags_filter   varchar2(32767);

  function tokenize_tags_string(a_tags in varchar2) return ut_varchar2_list is
    l_tags_tokens ut_varchar2_list := ut_varchar2_list();
  begin
    --Tokenize a string into operators and tags
    select regexp_substr(a_tags,'([^!()|&]+)|([!()|&])', 1, level) as string_parts
    bulk collect into l_tags_tokens
    from dual connect by regexp_substr (a_tags, '([^!()|&]+)|([!()|&])', 1, level) is not null;

    return l_tags_tokens;
  end;

  /*
    To support a legact tag notation
    , = OR
    - = NOT
    we will perform a replace of that characters into
    new notation.
    | = OR
    & = AND
    !  = NOT
  */
  function replace_legacy_tag_notation(a_tags varchar2
  ) return varchar2 is
    l_tags ut_varchar2_list := ut_utils.string_to_table(a_tags,',');
    l_tags_include varchar2(4000);
    l_tags_exclude varchar2(4000);
    l_return_tag varchar2(4000);
  begin
    if instr(a_tags,',') > 0 or instr(a_tags,'-') > 0 then

      select '('||listagg( t.column_value,'|')
        within group( order by column_value)||')'
      into l_tags_include
      from table(l_tags) t
      where t.column_value not like '-%';

      select '('||listagg( replace(t.column_value,'-','!'),' & ')
        within group( order by column_value)||')'
      into l_tags_exclude
      from table(l_tags) t
      where t.column_value like '-%';


      l_return_tag:=
        case
          when l_tags_include <> '()' and l_tags_exclude <> '()'
            then l_tags_include || ' & ' || l_tags_exclude
          when l_tags_include <> '()'
            then l_tags_include
          when l_tags_exclude <> '()'
            then l_tags_exclude
        end;
    else
      l_return_tag := a_tags;
    end if;
    return l_return_tag;
  end;

  /*
    https://stackoverflow.com/questions/29634992/shunting-yard-validate-expression
  */
  function shunt_logical_expression(a_tags in ut_varchar2_list) return ut_varchar2_list is
    l_operator_stack ut_stack := ut_stack();
    l_rnp_tokens ut_varchar2_list := ut_varchar2_list();
    l_token varchar2(32767);
    l_expect_operand boolean := true;
    l_expect_operator boolean := false;
    l_idx pls_integer;
  begin
    l_idx := a_tags.first;
    --Exuecute modified shunting algorithm
    WHILE (l_idx is not null) loop
      l_token := a_tags(l_idx);
      if (l_token member of gc_operators and l_token member of gc_binary_operators) then
        if not(l_expect_operator) then
          raise_application_error(ut_utils.gc_invalid_tag_expression, gc_exception_msg);
        end if;
        while l_operator_stack.top > 0 and (g_precedence(l_operator_stack.peek) > g_precedence(l_token))  loop
          l_rnp_tokens.extend;
          l_rnp_tokens(l_rnp_tokens.last) := l_operator_stack.pop;
        end loop;
        l_operator_stack.push(a_tags(l_idx));
        l_expect_operand := true;
        l_expect_operator:= false;
      elsif (l_token member of gc_operators and l_token member of gc_unary_operators) then
        if not(l_expect_operand) then
          raise_application_error(ut_utils.gc_invalid_tag_expression, gc_exception_msg);
        end if;
        l_operator_stack.push(a_tags(l_idx));
        l_expect_operand := true;
        l_expect_operator:= false;
      elsif l_token = '(' then
        if not(l_expect_operand) then
          raise_application_error(ut_utils.gc_invalid_tag_expression, gc_exception_msg);
        end if;
        l_operator_stack.push(a_tags(l_idx));
        l_expect_operand := true;
        l_expect_operator:= false;
      elsif l_token = ')' then
        if not(l_expect_operator) then
          raise_application_error(ut_utils.gc_invalid_tag_expression, gc_exception_msg);
        end if;
        while l_operator_stack.peek <> '(' loop
          l_rnp_tokens.extend;
          l_rnp_tokens(l_rnp_tokens.last) := l_operator_stack.pop;
        end loop;
        l_operator_stack.pop; --Pop the open bracket and discard it
        l_expect_operand := false;
        l_expect_operator:= true;
      else
        if not(l_expect_operand) then
          raise_application_error(ut_utils.gc_invalid_tag_expression, gc_exception_msg);
        end if;
        l_rnp_tokens.extend;
        l_rnp_tokens(l_rnp_tokens.last) :=l_token;
        l_expect_operator := true;
        l_expect_operand := false;
      end if;

      l_idx := a_tags.next(l_idx);
    end loop;

    while l_operator_stack.peek is not null loop
        if l_operator_stack.peek in ('(',')') then
          raise_application_error(ut_utils.gc_invalid_tag_expression, gc_exception_msg);
        end if;
        l_rnp_tokens.extend;
        l_rnp_tokens(l_rnp_tokens.last):=l_operator_stack.pop;
    end loop;

    return l_rnp_tokens;
  end shunt_logical_expression;

  function conv_postfix_to_infix_sql(a_postfix_exp in ut_varchar2_list,a_tags_column_name in varchar2)
    return varchar2 is
    l_infix_stack ut_stack := ut_stack();
    l_right_side varchar2(32767);
    l_left_side varchar2(32767);
    l_infix_exp varchar2(32767);
    l_member_token varchar2(20) := ' member of '||a_tags_column_name;
    l_idx pls_integer;
  begin
    l_idx := a_postfix_exp.first;
    while ( l_idx is not null) loop
      --If the token we got is a none or any keyword
      if a_postfix_exp(l_idx) member of gc_reserved_tag_words then

        l_infix_stack.push(
          case
            when a_postfix_exp(l_idx) = 'none' then '('||a_tags_column_name||' is empty or '||a_tags_column_name||' is null)'
          else a_tags_column_name||' is not empty'
          end
          );
      --If token is operand but also single tag
      elsif regexp_count(a_postfix_exp(l_idx),'[!()|&]') = 0 then
        l_infix_stack.push(q'[']'||a_postfix_exp(l_idx)||q'[']'||l_member_token);
      --If token is unary operator not
      elsif a_postfix_exp(l_idx) member of gc_unary_operators then
        l_right_side := l_infix_stack.pop;
        l_infix_exp := a_postfix_exp(l_idx)||'('||l_right_side||')';
        l_infix_stack.push(l_infix_exp);
      --If token is binary operator
      elsif a_postfix_exp(l_idx) member of gc_binary_operators then
        l_right_side := l_infix_stack.pop;
        l_left_side := l_infix_stack.pop;
        l_infix_exp := '('||l_left_side||a_postfix_exp(l_idx)||l_right_side||')';
        l_infix_stack.push(l_infix_exp);
      end if;
      l_idx := a_postfix_exp.next(l_idx);
    end loop;

    return l_infix_stack.pop;
  end conv_postfix_to_infix_sql;

  /*
    Generates a condition on a collection named "tags" from a tag expression.
    Raises ut_utils.gc_invalid_tag_expression for an invalid expression.
  */
  function create_where_filter(a_tag_expression varchar2, a_tags_var_name varchar2) return varchar2 is
    l_tags_filter varchar2(4000);
  begin
    -- if calculated already, return previously calculated value. Cache of input tag filter expression evaluation
    if g_last_tag_expression = a_tag_expression then
      return g_last_tags_filter;
    end if;
    l_tags_filter := replace(replace_legacy_tag_notation(a_tag_expression),' ');
    l_tags_filter := conv_postfix_to_infix_sql(shunt_logical_expression(tokenize_tags_string(l_tags_filter)),a_tags_var_name);
    l_tags_filter := replace(l_tags_filter, '|',' or ');
    l_tags_filter := replace(l_tags_filter ,'&',' and ');
    l_tags_filter := replace(l_tags_filter ,'!','not');
    g_last_tag_expression := a_tag_expression;
    g_last_tags_filter    := l_tags_filter;
    return l_tags_filter;
  end;

  function is_matching(a_tags varchar2, a_tag_expression varchar2) return integer deterministic is
    l_result        integer;
    c_tags_col_name varchar2(10) := 'l_tags';
  begin
    execute immediate
      'declare ' ||
      '  '||c_tags_col_name||' ut_varchar2_list := :a_tags; ' ||
      'begin ' ||
      '  :a_result := case when '||create_where_filter(a_tag_expression, c_tags_col_name)||' then 1 else 0 end; ' ||
      'end;'
      using in ut_utils.string_to_table(a_tags, ','), out l_result;
    return l_result;
  end;


begin
    --Define operators precedence
    g_precedence('!'):=4;
    g_precedence('&'):=3;
    g_precedence('|'):=2;
    g_precedence(')'):=1;
    g_precedence('('):=1;
  
end ut_suite_tag_filter;
/
