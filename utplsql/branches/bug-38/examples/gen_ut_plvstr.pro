CREATE OR REPLACE PROCEDURE gen_ut_plvstr 
IS
   utc   VARCHAR2 (1000)
   := '#program name|overload#|test case name|message|arguments|result|assertion type
betwn|1|normal|normal|abcdefgh;3;5;TRUE|cde|eq
betwn|1|zero start|zero start|abcdefgh;0;2;TRUE|abc|eq
betwn|1|null start|null start|abcdefgh;!null;2;TRUE|null|isnull
betwn|1|null end|null end|abcdefgh;!3;!null;TRUE|null|isnull';
BEGIN
   utconfig.setdir ('d:\openoracle\utplsql\examples');
   utconfig.showconfig;
   utgen.testpkg_from_string ('plvstr',
      utc,
      output_type_in=> utgen.c_file,
      dir_in=> 'd:\openoracle\utplsql\examples',
      schema_in => 'PLVPRO',
      only_if_in_grid_in => TRUE
   );
END;
