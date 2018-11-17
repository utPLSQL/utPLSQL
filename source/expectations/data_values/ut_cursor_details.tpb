create or replace type body ut_cursor_details as

    member function get_anytype_attribute_count(a_anytype anytype) return pls_integer is
         l_attribute_typecode pls_integer;
         l_schema_name        varchar2(32767);
         l_version            varchar2(32767);
         l_type_name          varchar2(32767);
         l_attributes         pls_integer;
         l_prec               pls_integer;
         l_scale              pls_integer;
         l_len                pls_integer;
         l_csid               pls_integer;
         l_csfrm              pls_integer;
      begin
         l_attribute_typecode := a_anytype.getinfo(prec        => l_prec,
                                                   scale       => l_scale,
                                                   len         => l_len,
                                                   csid        => l_csid,
                                                   csfrm       => l_csfrm,
                                                   schema_name => l_schema_name,
                                                   type_name   => l_type_name,
                                                   version     => l_version,
                                                   numelems    => l_attributes);
         return l_attributes;
      end;
   
  member function get_user_defined_type(a_owner varchar2, a_type_name varchar2)
      return anytype is
      l_anydata  anydata;
      l_anytype  anytype;
      l_typecode pls_integer;
   
   begin
      execute immediate 'declare
                         l_v ' || a_owner || '.' ||
                        a_type_name || ';
                       begin
                         :anydata := anydata.convertobject(l_v);
                       end;'
         using in out l_anydata;
   
      l_typecode := l_anydata.gettype(l_anytype);
   
      return l_anytype;
   end;   

  constructor function ut_cursor_details(self     in out nocopy ut_cursor_details,
                                      a_cursor in out nocopy sys_refcursor)
      return self as result is
      l_cursor_number integer;
      l_columns_count pls_integer;
      l_columns_desc  dbms_sql.desc_tab3;
      l_attribute_typecode pls_integer;
      l_aname              varchar2(32767);
      l_prec               pls_integer;
      l_scale              pls_integer;
      l_len                pls_integer;
      l_csid               pls_integer;
      l_csfrm              pls_integer;
      l_attr_elt_type      anytype;
      l_anytype  anytype;
        
   begin
      self.cursor_info := ut_cursor_column_tab();
      l_cursor_number  := dbms_sql.to_cursor_number(a_cursor);
      dbms_sql.describe_columns3(l_cursor_number,
                                 l_columns_count,
                                 l_columns_desc);
      a_cursor := dbms_sql.to_refcursor(l_cursor_number);
   
      for cur in 1 .. l_columns_count loop
         self.cursor_info.extend;
         self.cursor_info(cursor_info.last) := ut_cursor_column(  l_columns_desc(cur).col_name,
                                                                  l_columns_desc(cur).col_schema_name,
                                                                  l_columns_desc(cur).col_type_name,
                                                                  l_columns_desc(cur).col_precision,
                                                                  l_columns_desc(cur).col_scale,
                                                                  l_columns_desc(cur).col_max_len,
                                                                  null,
                                                                  1,
                                                                  cur,
                                                                  ut_curr_usr_compound_helper.get_column_type(l_columns_desc(cur).col_type,false)
                                                                  );
        if l_columns_desc(cur).col_type = dbms_sql.user_defined_type then
          l_anytype := get_user_defined_type(l_columns_desc(cur).col_schema_name , l_columns_desc(cur).col_type_name );
          for i in 1 .. get_anytype_attribute_count(l_anytype) loop
           l_attribute_typecode := l_anytype.getattreleminfo(pos           => i, --First attribute
                                                           prec          => l_prec,
                                                           scale         => l_scale,
                                                           len           => l_len,
                                                           csid          => l_csid,
                                                           csfrm         => l_csfrm,
                                                           attr_elt_type => l_attr_elt_type,
                                                           aname         => l_aname);
      
          self.cursor_info.extend;
          self.cursor_info(cursor_info.last) := ut_cursor_column( l_aname,
                                                                  null,
                                                                  null,
                                                                  l_prec,
                                                                  l_scale,
                                                                  l_len,
                                                                  l_columns_desc(i).col_name,
                                                                  2,
                                                                  i,
                                                                  ut_curr_usr_compound_helper.get_column_type(l_attribute_typecode,true)
                                                                  );          
          end loop;
        end if;
      end loop;
      
      return;
   end;
end;
/
