@str2list.pkg

@filepath.pkg

BEGIN
   p.l ('Str2List Test Using Direct Collection Access');
   fileio.setpath ('a;b;c;d;efg;;');
   str2list.showlist ('fileio', 'dirs');
END;
/

@filepath2.pkg

BEGIN
   p.l ('Str2List Test Using API');
   fileio.setpath ('a;b;c;d;efg;;');
   str2list.showlist ('fileio', 'first', 'next', 'val', 'p.l');
END;
/
   