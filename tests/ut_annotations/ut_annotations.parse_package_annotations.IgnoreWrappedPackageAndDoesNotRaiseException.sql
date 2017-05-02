begin
  DBMS_DDL.CREATE_WRAPPED(
q'[
CREATE OR REPLACE PACKAGE tst_wrapped_pck IS
  PROCEDURE dummy;
END;
]'
  );
end;
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
