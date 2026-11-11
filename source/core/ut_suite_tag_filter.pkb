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
  * Constants used in the conversion to postfix notation
  */
  gc_operators constant ut_varchar2_list := ut_varchar2_list('|','&','!');
  gc_unary_operators constant ut_varchar2_list := ut_varchar2_list('!'); -- right side associative operator
  gc_binary_operators constant ut_varchar2_list := ut_varchar2_list('|','&'); -- left side associative operator
  gc_exception_msg constant varchar2(200) := 'Invalid tag expression';

  type t_precedence_table is table of number index by varchar2(1);
  g_precedence t_precedence_table;

  g_last_tag_expression varchar2(32767);
  g_last_postfix        ut_varchar2_list;

  function tokenize_tags_string(a_tags in varchar2) return ut_varchar2_list is
    l_tags_tokens ut_varchar2_list := ut_varchar2_list();
  begin
    if a_tags is not null then
      select regexp_substr(a_tags,'([^!()|&]+)|([!()|&])', 1, level) as string_parts
      bulk collect into l_tags_tokens
      from dual connect by regexp_substr (a_tags, '([^!()|&]+)|([!()|&])', 1, level) is not null;
    end if;

    return l_tags_tokens;
  end;

  function remove_whitespace(a_tag_expression varchar2) return varchar2 is
  begin
    return replace(replace(a_tag_expression, ' '), chr(9));
  end;

  /*
    To support a legacy tag notation
    , = OR
    - = NOT
    we replace those characters into
    new notation.
    | = OR
    & = AND
    !  = NOT
  */
  function replace_legacy_tag_notation(a_tags varchar2) return varchar2 is
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

      select '('||listagg( replace(t.column_value,'-','!'),'&')
        within group( order by column_value)||')'
      into l_tags_exclude
      from table(l_tags) t
      where t.column_value like '-%';


      l_return_tag:=
        case
          when l_tags_include <> '()' and l_tags_exclude <> '()'
            then l_tags_include || '&' || l_tags_exclude
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
    --Execute modified shunting algorithm
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
        --no open bracket left on the stack: unmatched right bracket
        if l_operator_stack.peek is null then
          raise_application_error(ut_utils.gc_invalid_tag_expression, gc_exception_msg);
        end if;
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

    --an empty expression, or one ending with an operator or a left bracket, is incomplete
    if not(l_expect_operator) then
      raise_application_error(ut_utils.gc_invalid_tag_expression, gc_exception_msg);
    end if;

    while l_operator_stack.peek is not null loop
        if l_operator_stack.peek in ('(',')') then
          raise_application_error(ut_utils.gc_invalid_tag_expression, gc_exception_msg);
        end if;
        l_rnp_tokens.extend;
        l_rnp_tokens(l_rnp_tokens.last):=l_operator_stack.pop;
    end loop;

    return l_rnp_tokens;
  end shunt_logical_expression;

  /*
    Returns a tag expression in postfix notation (Reverse Polish Notation).
    is_matching is called for each test with the same expression, so the result for the last expression is cached.
    Raises ut_utils.gc_invalid_tag_expression for an invalid expression.
  */
  function get_postfix_expression(a_tag_expression varchar2) return ut_varchar2_list is
    l_postfix ut_varchar2_list;
  begin
    if g_last_tag_expression = a_tag_expression then
      return g_last_postfix;
    end if;
    l_postfix := shunt_logical_expression(
      tokenize_tags_string( replace_legacy_tag_notation( a_tag_expression ) )
    );
    g_last_tag_expression := a_tag_expression;
    g_last_postfix        := l_postfix;
    return l_postfix;
  end;

  /*
    Evaluates a valid postfix expression against a list of tags, using a stack of operand values.
    The values follow the three-valued logic of SQL: "x member of a_tags" is null when a_tags has a null element
    and no element x, and "not null" is null, as in a SQL condition.
  */
  function evaluate_postfix(a_postfix ut_varchar2_list, a_tags ut_varchar2_list) return boolean is
    type t_boolean_stack is table of boolean index by pls_integer;
    l_stack t_boolean_stack;
    l_top   pls_integer := 0;
    l_token varchar2(32767);
  begin
    for i in 1 .. a_postfix.count loop
      l_token := a_postfix(i);
      case l_token
        when '!' then
          l_stack(l_top) := not l_stack(l_top);
        when '&' then
          l_top := l_top - 1;
          l_stack(l_top) := l_stack(l_top) and l_stack(l_top + 1);
        when '|' then
          l_top := l_top - 1;
          l_stack(l_top) := l_stack(l_top) or l_stack(l_top + 1);
        else
          l_top := l_top + 1;
          l_stack(l_top) :=
            case l_token
              when 'none' then a_tags is empty
              when 'any'  then a_tags is not empty
              else l_token member of a_tags
            end;
      end case;
    end loop;
    return l_stack(1);
  end;

  function is_matching(a_tags varchar2, a_tag_expression varchar2) return integer deterministic is
    l_tag_expression varchar2(32767) := remove_whitespace(a_tag_expression);
  begin
    return
      case
        when l_tag_expression is null
        then 1
        when evaluate_postfix( get_postfix_expression(l_tag_expression), ut_utils.string_to_table(a_tags, ',') )
        then 1
        else 0
      end;
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
