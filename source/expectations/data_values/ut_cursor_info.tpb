create or replace type body ut_cursor_info as
   constructor function ut_cursor_info(self     in out nocopy ut_cursor_info,
                                      a_cursor in out nocopy sys_refcursor)
      return self as result is
      l_cursor_number integer;
      l_columns_count pls_integer;
      l_columns_desc  dbms_sql.desc_tab3;
   begin
      self.cursor_info := ut_column_info_tab();
      l_cursor_number  := dbms_sql.to_cursor_number(a_cursor);
      dbms_sql.describe_columns3(l_cursor_number,
                                 l_columns_count,
                                 l_columns_desc);
      a_cursor := dbms_sql.to_refcursor(l_cursor_number);
   
      for i in 1 .. l_columns_count loop
         self.cursor_info.extend;
         self.cursor_info(cursor_info.last) := ut_column_info_rec(l_columns_desc(i).col_type,
                                                                  l_columns_desc(i).col_name,
                                                                  l_columns_desc(i).col_schema_name,
                                                                  l_columns_desc(i).col_type_name,
                                                                  l_columns_desc(i).col_precision,
                                                                  l_columns_desc(i).col_scale,
                                                                  l_columns_desc(i).col_max_len,
                                                                  true);
      end loop;
   
      return;
   end ut_cursor_info;
end;
/
