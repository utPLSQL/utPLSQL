-- 26 Dec 2001  Dan Spencer   Created

-- 31 Jul 2002  Chris Rimmer  Fixed so that records in foreign schemas work



CREATE OR REPLACE PACKAGE utreceq &start81 AUTHID CURRENT_USER &end81
IS

   PROCEDURE add(

      pkg_name_in IN ut_package.name%TYPE ,

      record_in  IN ut_receq.name%TYPE ,

      rec_owner_in  IN ut_receq.created_by%TYPE := USER

   );



   PROCEDURE compile(

      pkg_name_in     IN ut_package.name%TYPE

   );



   PROCEDURE rem(

      name_in  IN ut_receq.name%TYPE,

      rec_owner_in   IN ut_receq.created_by%TYPE := USER,

      for_package_in IN BOOLEAN := FALSE

   );



END utreceq;

/

