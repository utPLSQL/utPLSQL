CREATE or replace PACKAGE tst_wrapped_pck wrapped 
a000000
369
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
9
a9 c6
BFZG852xhrH+ZghWHu3GpsAjsYwwgwFtmJ7hfy/pO3MYPpTk1jvUXeLLSBs48Y66RPOZmSwO
tdAK4wIZubhyoYqfNPukcsRhJHrcsdmQU6c7MJt96TjbQty7bG3LvKuFVGWjizd5GkTmJ7dk
Ktg41QYvCqco0ZidUx+EE+yoSt2ucz1rQYcomGbMx3gS4Xj7Vm8=
/

declare
  l_pck_annotation ut_annotations.typ_annotated_package;
begin
  l_pck_annotation := ut_annotations.get_package_annotations(user, 'TST_WRAPPED_PCK');
  if l_pck_annotation.procedure_annotations.count = 0 and l_pck_annotation.package_annotations.count = 0 then
    :test_result := ut_utils.tr_success;
  end if;
end;
/

drop package tst_wrapped_pck;
