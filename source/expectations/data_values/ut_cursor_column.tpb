create or replace type body ut_cursor_column as
   
   member procedure init(self in out nocopy ut_cursor_column,
     a_col_name varchar2, a_col_schema_name varchar2,
     a_col_type_name varchar2, a_col_max_len integer, a_parent_name varchar2 := null, a_hierarchy_level integer := 1,
     a_col_position integer, a_col_type varchar2, a_collection integer) is
   begin
      self.parent_name      := a_parent_name;
      self.hierarchy_level  := a_hierarchy_level;
      self.column_position  := a_col_position;
      self.column_len       := a_col_max_len;
      self.column_name      := TRIM( BOTH '''' FROM a_col_name);
      self.column_type_name := a_col_type_name;
      self.access_path      := case when self.parent_name is null then self.column_name else self.parent_name||'/'||self.column_name end;
      self.xml_valid_name   := '"'||self.column_name||'"';
      self.transformed_name := case when self.parent_name is null then 
                                self.xml_valid_name
                             else 
                                '"'||ut_compound_data_helper.get_fixed_size_hash(self.parent_name||self.column_name)||'"'
                             end;
      self.column_type      := a_col_type;
      self.column_schema    := a_col_schema_name;
      self.is_sql_diffable  := case when lower(self.column_type) = 'user_defined_type' then 
                                0 
                              else 
                                ut_utils.boolean_to_int(ut_compound_data_helper.is_sql_compare_allowed(self.column_type))
                              end;
      --TODO : Part of the constructor same as has nested ??
      self.is_collection   := a_collection;
      --TODO : fix that as is nasty hardcode
      self.has_nested_col := case when lower(self.column_type) = 'user_defined_type' and self.is_collection = 0 then 1 else 0 end;
   end;
   
   --TODO : Scenarios : 
   --namedcollection xmltype getclobhash
   --collection  xml type get clob hash
   -- user defined type
   
   constructor function ut_cursor_column( self in out nocopy ut_cursor_column,
     a_col_name varchar2, a_col_schema_name varchar2,
     a_col_type_name varchar2, a_col_max_len integer, a_parent_name varchar2 := null, a_hierarchy_level integer := 1,
     a_col_position integer, a_col_type in varchar2, a_collection integer) return self as result is
   begin
     init(a_col_name, a_col_schema_name, a_col_type_name, a_col_max_len, a_parent_name,a_hierarchy_level, a_col_position, a_col_type, a_collection);
   return;
   end;
end;
/
