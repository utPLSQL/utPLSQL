CREATE OR REPLACE PROCEDURE gen_ut_betwnstr 
IS
   utc   VARCHAR2 (1000)
   := '#program name|overload|test case name|message|arguments|result|assertion type
betwnstr||normal|normal|abcdefgh;3;5|cde|eq
betwnstr||zero start|zero start|abcdefgh;0;2|abc|eq
betwnstr||null start|null start|abcdefgh;!null;2|null|isnull
betwnstr||null end|null end|abcdefgh;!3;!null|null|isnull';
BEGIN
   utconfig.setdir ('d:\openoracle\utplsql\examples');
   utconfig.showconfig;
   utgen.testpkg_from_string ('betwnstr',
      utc,
      output_type_in=> utgen.c_file,
      dir_in=> 'c:\temp'
   );
END;
