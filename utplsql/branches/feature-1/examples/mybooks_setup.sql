/****************************************************************************************

   Author      :  Venky Mangapillai
   Created     :  Mar'2002
   Description :  This is the Prerequest program for UTPSQL test package called UT_MYBOOKS_PKG 

****************************************************************************************/

CREATE TABLE mybooks (
  book_id 	NUMBER,
  book_nm	VARCHAR2(30),
  publish_dt    DATE
)
/
ALTER TABLE mybooks ADD CONSTRAINT mybooks_pk PRIMARY KEY (book_id)
/
TRUNCATE TABLE mybooks
/
INSERT INTO mybooks VALUES (1,'Sports History','01-JAN-2002');
INSERT INTO mybooks VALUES (2,'World History','02-JAN-2002');
INSERT INTO mybooks VALUES (3,'Medicine History','03-JAN-2002');
INSERT INTO mybooks VALUES (4,'Market History','04-JAN-2002');
INSERT INTO mybooks VALUES (5,'Weather History','05-JAN-2002');

CREATE OR REPLACE PACKAGE mybooks_pkg AS
TYPE mybooks_rec IS REF CURSOR RETURN mybooks%ROWTYPE;

FUNCTION sel_book_func(bookid NUMBER) RETURN mybooks_rec;
PROCEDURE sel_book_proc(bookid NUMBER, rc OUT mybooks_rec);
FUNCTION  sel_booknm(bookid NUMBER) RETURN VARCHAR2;
PROCEDURE ins(bookid NUMBER, booknm VARCHAR2,publishdt DATE);
PROCEDURE upd(bookid NUMBER, booknm VARCHAR2,publishdt DATE);
PROCEDURE del(bookid NUMBER);

END;
/
CREATE OR REPLACE PACKAGE BODY mybooks_pkg AS
FUNCTION sel_book_func(bookid NUMBER) RETURN mybooks_rec IS
  rc mybooks_rec;
BEGIN
    OPEN rc FOR SELECT * FROM mybooks WHERE book_id = bookid;
    RETURN(rc);
END;

FUNCTION  sel_booknm(bookid NUMBER) RETURN VARCHAR2 IS
  booknm  VARCHAR2(30);
BEGIN
  SELECT book_nm INTO booknm FROM mybooks WHERE book_id = bookid;
  RETURN(booknm);
END;

PROCEDURE ins(bookid NUMBER, booknm VARCHAR2,publishdt DATE) IS
BEGIN
   INSERT INTO mybooks VALUES (bookid,booknm,publishdt);
   COMMIT;
END;

PROCEDURE upd(bookid NUMBER, booknm VARCHAR2,publishdt DATE) IS
BEGIN
   UPDATE mybooks SET book_nm=booknm, publish_dt=publishdt WHERE book_id = bookid;
   COMMIT;
END;

PROCEDURE del(bookid NUMBER) IS
BEGIN
   DELETE FROM mybooks WHERE book_id = bookid;
   COMMIT;
END;

PROCEDURE sel_book_proc(bookid NUMBER, rc OUT mybooks_rec) IS
BEGIN
    OPEN rc FOR SELECT * FROM mybooks WHERE book_id = bookid;
END;

END;
/
show errors
