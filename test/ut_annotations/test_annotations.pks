create or replace package test_annotations is

  --%suite(annotations)
  --%suitepath(utplsql.core)

  --%test(Parse procedure level annotations with annotations mixed with comments)
  procedure test1;
  --%test(Parse package level annotations with annotations "in the air")
  procedure test2;
  --%test(Parse complex package)
  procedure test3;
  --%test(Parse package level annotations)
  procedure test4;
  --%test(Parse package level annotations)
  procedure test5;
  --%test(Parse package level annotations Accessible by)
  procedure test6;
  --%test(Parse package level annotations with multiline declaration)
  procedure test7;
  --%test(Parse package level annotations)
  procedure test8;
  --%test(Parse package level annotations with multiline comment)
  procedure test9;

  --%test(Ignore Wrapped Package And Does Not Raise Exception)
  --%beforetest(cre_wrapped_pck)
  --%aftertest(drop_wrapped_pck)
  procedure ignore_wrapped_package;

  procedure cre_wrapped_pck;
  procedure drop_wrapped_pck;

  --%test(Parse package level annotations with annotation params containing brackets)
  procedure brackets_in_desc;
  
  --%test(Test space before annotation params)
  procedure test_space_Before_Annot_Params;

  -- %test(Test annotations with windows newline)
  procedure test_windows_newline;

  -- %test(Test annotation function with very long name)
  procedure test_annot_very_long_name;

end test_annotations;
/
