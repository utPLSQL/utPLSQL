/* Formatted on 2001/09/14 10:34 (RevealNet Formatter v4.4.1) */
CREATE OR REPLACE PACKAGE BODY ututp
IS
   /* UTP##NNN */
   FUNCTION name (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    c_abbrev
             || utconfig.delimiter
             || utp_in.id;
   END;

   FUNCTION name (id_in IN ut_utp.id%TYPE)
      RETURN VARCHAR2
   IS
      rec   ut_utp%ROWTYPE;
   BEGIN
      rec := onerow (id_in);
      RETURN name (rec);
   END;

   /* schema.UTP##NNN */
   FUNCTION qualified_name (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    utp_in.owner
             || '.'
             || name (utp_in);
   END;

   FUNCTION qualified_name (id_in IN ut_utp.id%TYPE)
      RETURN VARCHAR2
   IS
      rec   ut_utp%ROWTYPE;
   BEGIN
      rec := onerow (id_in);
      RETURN qualified_name (rec);
   END;

   FUNCTION setup_procedure (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    utp_in.owner
             || '.'
             || name (utp_in)
             || '.'
             || utplsql.c_setup;
   END;

   FUNCTION teardown_procedure (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN    utp_in.owner
             || '.'             
             || name (utp_in)
             || '.'
             || utplsql.c_teardown;
   END;

   FUNCTION prefix (utp_in IN ut_utp%ROWTYPE)
      RETURN VARCHAR2
   IS
   BEGIN
      RETURN utp_in.prefix;
   END;

   FUNCTION onerow (
      owner_in     IN   ut_utp.owner%TYPE,
      program_in   IN   ut_utp.program%TYPE
   )
      RETURN ut_utp%ROWTYPE
   IS
      retval      ut_utp%ROWTYPE;
      empty_rec   ut_utp%ROWTYPE;
   BEGIN
      SELECT *
        INTO retval
        FROM ut_utp
       WHERE owner = NVL (UPPER (owner_in), USER)
         AND program = UPPER (program_in);
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN empty_rec;
   END;

   PROCEDURE get_onerow (
      owner_in                IN       ut_utp.owner%TYPE
     ,program_in              IN       ut_utp.program%TYPE
     ,id_out                  OUT      ut_utp.ID%TYPE
     ,description_out         OUT      ut_utp.description%TYPE 
     ,filename_out            OUT      ut_utp.filename%TYPE
     ,program_directory_out   OUT      ut_utp.program_directory%TYPE 
     ,directory_out           OUT      ut_utp.DIRECTORY%TYPE
     ,name_out                OUT      ut_utp.NAME%TYPE 
     ,utp_owner_out           OUT      ut_utp.utp_owner%TYPE 
     ,prefix_out              OUT      ut_utp.prefix%TYPE 
   )
   is
   rec ut_utp%rowtype;
   begin
   rec := onerow (owner_in, program_in);
   id_out := rec.id;
     if rec.id is not null then
description_out   := rec.description;     
filename_out    := rec.filename;       
program_directory_out  := rec.program_directory;
directory_out    := rec.directory;      
name_out     := rec.name;          
utp_owner_out   := rec.utp_owner;       
prefix_out  := rec.prefix;           

   end if;
   end get_onerow;
   
 FUNCTION exists (
      owner_in     IN   ut_utp.owner%TYPE,
      program_in   IN   ut_utp.program%TYPE
   )
      RETURN Boolean
   IS
      retval      char(1);
      
   BEGIN
      SELECT 'x'
        INTO retval
        FROM ut_utp
       WHERE owner = NVL (UPPER (owner_in), USER)
         AND program = UPPER (program_in);
      RETURN true;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN false;
   END;
      
   FUNCTION onerow (utp_id_in IN ut_utp.id%TYPE)
      RETURN ut_utp%ROWTYPE
   IS
      retval      ut_utp%ROWTYPE;
      empty_rec   ut_utp%ROWTYPE;
   BEGIN
      SELECT *
        INTO retval
        FROM ut_utp
       WHERE id = utp_id_in;
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN empty_rec;
   END;

   FUNCTION id (name_in IN VARCHAR2)
      RETURN ut_utp.id%TYPE
   IS
      l_delimiter   ut_config.delimiter%TYPE   := utconfig.delimiter;
      l_loc         PLS_INTEGER;
      retval        ut_utp.id%TYPE;
   BEGIN
      l_loc := INSTR (name_in, l_delimiter);

      IF l_loc = 0
      THEN
         RETURN NULL;
      ELSE
         RETURN to_number (SUBSTR (name_in,   l_loc
                                  + LENGTH (l_delimiter))
                );
      END IF;
   /* Use new formula; no query required
      SELECT id
        INTO retval
        FROM ut_utp
       WHERE name = UPPER (name_in);
      RETURN retval;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
         */
   END;

   PROCEDURE ADD (
      program_in        IN   ut_utp.program%TYPE := NULL,
      owner_in          IN   ut_utp.owner%TYPE := NULL,
      description_in    IN   ut_utp.description%TYPE := NULL,
      filename_in       IN   ut_utp.filename%TYPE := NULL,
      frequency_in      IN   ut_utp.frequency%TYPE := NULL,
      program_map_in    IN   ut_utp.program_map%TYPE := NULL,
      declarations_in   IN   ut_utp.declarations%TYPE
            := NULL,
      setup_in          IN   ut_utp.setup%TYPE := NULL,
      teardown_in       IN   ut_utp.teardown%TYPE := NULL,
      exceptions_in       IN   ut_utp.exceptions%TYPE := NULL,
      program_directory_in       IN   ut_utp.program_directory%TYPE := NULL,
      directory_in       IN   ut_utp.directory%TYPE := NULL,
      name_in       IN   ut_utp.name%TYPE := NULL,
      utp_owner_in       IN   ut_utp.utp_owner%TYPE := NULL,
      prefix_in       IN   ut_utp.prefix%TYPE := NULL,      
      id_out OUT ut_utp.id%TYPE
   )
   IS
      &start81 
      PRAGMA autonomous_transaction;
      &end81
      l_id   ut_utp.id%TYPE;
	  l_program ut_utp.name%type := program_in;
   BEGIN
   if l_program not like '"%' then l_program := upper (l_program); end if; 
      SELECT ut_utp_seq.NEXTVAL
        INTO l_id
        FROM DUAL;

      INSERT INTO ut_utp
                  (id, program,
                   owner, description, filename,
                   frequency, program_map, declarations,
                   setup, teardown, program_directory, directory,
                   name, utp_owner, prefix
                                        )
           VALUES (l_id, l_program,
                   NVL (owner_in, USER), description_in, filename_in,
                   frequency_in, program_map_in, declarations_in,
                   setup_in, teardown_in, program_directory_in, directory_in,
                   name_in, utp_owner_in, prefix_in
                                        );

      &start81 
      COMMIT;
      
   &end81
      id_out := l_id;
   EXCEPTION
      WHEN OTHERS
      THEN
         IF utrerror.uterrcode = utrerror.assertion_failure
         THEN
            &start81 ROLLBACK; &end81
            RAISE;
         ELSE
            &start81 ROLLBACK; &end81
            utrerror.report_define_error (
               c_abbrev,
                  'UTP for '
               || program_in
               || ' Owner '
               || owner_in
            );
         END IF;
   END;

   PROCEDURE ADD (
      program_in        IN   ut_utp.program%TYPE := NULL,
      owner_in          IN   ut_utp.owner%TYPE := NULL,
      description_in    IN   ut_utp.description%TYPE := NULL,
      filename_in       IN   ut_utp.filename%TYPE := NULL,
      frequency_in      IN   ut_utp.frequency%TYPE := NULL,
      program_map_in    IN   ut_utp.program_map%TYPE := NULL,
      declarations_in   IN   ut_utp.declarations%TYPE
            := NULL,
      setup_in          IN   ut_utp.setup%TYPE := NULL,
      teardown_in       IN   ut_utp.teardown%TYPE := NULL,
      exceptions_in       IN   ut_utp.exceptions%TYPE := NULL,
      program_directory_in       IN   ut_utp.program_directory%TYPE := NULL,
      directory_in       IN   ut_utp.directory%TYPE := NULL,
      name_in       IN   ut_utp.name%TYPE := NULL,
      utp_owner_in       IN   ut_utp.utp_owner%TYPE := NULL,
      prefix_in       IN   ut_utp.prefix%TYPE := NULL 
   ) is l_id ut_utp.id%TYPE; begin
   add (program_in        => program_in,
      owner_in          => owner_in,
      description_in    => description_in,
      filename_in       => filename_in,
      frequency_in      => frequency_in,
      program_map_in    => program_map_in,
      declarations_in   => declarations_in,
      setup_in          => setup_in,
      teardown_in       => teardown_in,
      exceptions_in     => exceptions_in,
      program_directory_in  => program_directory_in,
      directory_in       => directory_in,
      name_in       => name_in,
      utp_owner_in       => utp_owner_in,
      prefix_in       => prefix_in, 
   id_out => l_id);
   end;
   
   PROCEDURE rem (name_in IN VARCHAR2)
   IS
   BEGIN
      rem (id (name_in));
   END;

   PROCEDURE rem (id_in IN ut_utp.id%TYPE)
   IS
      &start81 
      PRAGMA autonomous_transaction;
   &end81
   BEGIN
      DELETE FROM ut_utp
            WHERE id = id_in;

      &start81 
      COMMIT;
   &end81 
   EXCEPTION
      WHEN OTHERS
      THEN
         IF utrerror.uterrcode = utrerror.assertion_failure
         THEN
            &start81 ROLLBACK; &end81
            RAISE;
         ELSE
            &start81 ROLLBACK; &end81
            utrerror.report_define_error (c_abbrev,    'UTP '
                                                    || id_in);
         END IF;
   END;
   
   PROCEDURE upd (
      id_in         IN   ut_utp.id%TYPE,
      program_directory_in       IN   ut_utp.program_directory%TYPE := NULL,
      directory_in       IN   ut_utp.directory%TYPE := NULL,
      name_in       IN   ut_utp.name%TYPE := NULL,
      utp_owner_in       IN   ut_utp.utp_owner%TYPE := NULL,
      filename_in       IN   ut_utp.filename%TYPE := NULL,
      prefix_in       IN   ut_utp.prefix%TYPE := NULL  
   )
   IS
      &start81 
      PRAGMA autonomous_transaction;
      &end81
	  l_name ut_utp.name%type := name_in;
   BEGIN
   if l_name not like '"%' then l_name := upper (l_name); end if; 
      update ut_utp
        set filename = filename_in,
        program_directory = program_directory_in,
        directory = directory_in,
        name = l_name,
        utp_owner = utp_owner_in,
        prefix = prefix_in
       where id = id_in;
      &start81 
      COMMIT;
      
   &end81
   EXCEPTION
      WHEN OTHERS
      THEN
            &start81 ROLLBACK; &end81
            utrerror.report_define_error (
               c_abbrev,
                  'UTP update for UTP '
               || id_in
            );
   END;

   FUNCTION utps (program_like_in IN VARCHAR2 := '%')
      RETURN utconfig.refcur_t
   IS
      retval   utconfig.refcur_t;
   BEGIN
      OPEN retval FOR
         SELECT *
           FROM ut_utp
          WHERE program LIKE UPPER (program_like_in);
      RETURN retval;
   EXCEPTION
      WHEN OTHERS
      THEN
         RETURN retval;
   END;
END ututp;
/

