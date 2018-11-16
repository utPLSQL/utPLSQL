create or replace type body ut_column_info_rec as

   member function get_anytype_attributes_info(a_anytype anytype, a_col_name varchar2)
      return ut_column_info_tab is
      l_result             ut_column_info_tab := ut_column_info_tab();
      l_attribute_typecode pls_integer;
      l_aname              varchar2(32767);
      l_prec               pls_integer;
      l_scale              pls_integer;
      l_len                pls_integer;
      l_csid               pls_integer;
      l_csfrm              pls_integer;
      l_attr_elt_type      anytype;
   
      function get_anytype_attribute_count(a_anytype anytype) return pls_integer is
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
   
   begin
      for i in 1 .. get_anytype_attribute_count(a_anytype) loop
         l_attribute_typecode := a_anytype.getattreleminfo(pos           => i, --First attribute
                                                           prec          => l_prec,
                                                           scale         => l_scale,
                                                           len           => l_len,
                                                           csid          => l_csid,
                                                           csfrm         => l_csfrm,
                                                           attr_elt_type => l_attr_elt_type,
                                                           aname         => l_aname);
      
         l_result.extend;
         l_result(l_result.last) := ut_column_info_rec(l_attribute_typecode,
                                                      l_aname,
                                                      null,
                                                      null,
                                                      l_prec,
                                                      l_scale,
                                                      l_len,
                                                      false,
                                                      a_col_name);
      end loop;
      return l_result;
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

   overriding member procedure init(self              in out nocopy ut_column_info_rec,
                                    a_col_type        binary_integer,
                                    a_col_name        varchar2,
                                    a_col_schema_name varchar2,
                                    a_col_type_name   varchar2,
                                    a_col_prec        integer,
                                    a_col_scale       integer,
                                    a_col_max_len     integer,
                                    a_dbms_sql_desc   boolean := false,
                                    a_parent_name     varchar2) is
      l_anytype anytype;
   begin
      self.column_prec     := a_col_prec;
      self.column_len      := a_col_max_len;
      self.column_scale    := a_col_scale;
      self.column_name     := TRIM(BOTH '''' FROM a_col_name);
      self.xml_valid_name  := '"'||self.column_name||'"';
      self.hashed_name     := case when a_parent_name is not null then 
                                   ut_compound_data_helper.get_hash(utl_raw.cast_to_raw(a_parent_name||self.column_name))
                                   else 
                                     null
                                    end;
      self.column_type     := a_col_type_name;
      self.column_schema   := a_col_schema_name;
      self.is_sql_diffable := 0;
      self.is_collection   := ut_utils.boolean_to_int(ut_curr_usr_compound_helper.is_collection(a_col_schema_name,a_col_type_name));
      self.is_user_defined := 1;
   
      l_anytype           := get_user_defined_type(a_col_schema_name, a_col_type_name);
      self.nested_details := get_anytype_attributes_info(l_anytype, self.column_name);
   end;

   constructor function ut_column_info_rec(self             in out nocopy ut_column_info_rec,
                                          a_col_type        binary_integer,
                                          a_col_name        varchar2,
                                          a_col_schema_name varchar2,
                                          a_col_type_name   varchar2,
                                          a_col_prec        integer,
                                          a_col_scale       integer,
                                          a_col_max_len     integer,
                                          a_dbms_sql_desc   boolean := false,
                                          a_parent_name     varchar2 := null)
      return self as result is
   begin
      if a_col_type = dbms_sql.user_defined_type then
        self.init(a_col_type, a_col_name, a_col_schema_name, a_col_type_name,a_col_prec,a_col_scale,a_col_max_len);
      else
         (self as ut_column_info).init(a_col_type,
                                      a_col_name,
                                      a_col_schema_name,
                                      a_col_type_name,a_col_prec,a_col_scale,a_col_max_len,
                                      a_dbms_sql_desc,
                                      a_parent_name);
      end if;
      return;
   end;
end;
/
