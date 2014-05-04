DECLARE
      utc   VARCHAR2 (1000)
   := '#program name|test case name|message|arguments|result|assertion type
betwnstr|1|normal|normal|abcdefgh;3;5|cde|eq
betwnstr|1|zero start|zero start|abcdefgh;0;2|ab|eq
betwnstr|1|null start|null start|abcdefgh;!null;2|null|isnull
betwnstr|1|big start small end|big start small end|abcdefgh;10;5|null|isnull
betwnstr|1|null end|null end|abcdefgh;!3;!null|null|isnull'
;
BEGIN
   utgen.testpkg_from_string ('betwnstr',
      utc
	  /*,
      output_type_in=> utgen.c_file,
      dir_in=> 'd:\demo-seminar'
	  */
   );
END;
/

