create or replace package body test_file_mapper is

  procedure default_mappings is
    l_actual   ut3_develop.ut_file_mappings;
    l_expected ut3_develop.ut_file_mappings;
  begin
    --Arrange
    l_expected := ut3_develop.ut_file_mappings(
      ut3_develop.ut_file_mapping('C:\tests\helpers\core.pkb',sys_context('USERENV', 'CURRENT_USER'),'CORE','PACKAGE BODY'),
      ut3_develop.ut_file_mapping('tests/helpers/test_file_mapper.pkb',sys_context('USERENV', 'CURRENT_USER'),'TEST_FILE_MAPPER','PACKAGE BODY')
    );
    --Act
    l_actual := ut3_develop.ut_file_mapper.build_file_mappings(
        ut3_develop.ut_varchar2_list(
        'C:\tests\helpers\core.pkb',
        'tests/helpers/test_file_mapper.pkb'
      )
    );
    --Assert
    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

  procedure specific_owner is
    l_actual   ut3_develop.ut_file_mappings;
    l_expected ut3_develop.ut_file_mappings;
  begin
    --Arrange
    l_expected := ut3_develop.ut_file_mappings(
      ut3_develop.ut_file_mapping('C:\source\core\types\ut_file_mapping.tpb','UT3_DEVELOP','UT_FILE_MAPPING','TYPE BODY'),
      ut3_develop.ut_file_mapping('source/core/ut_file_mapper.pkb','UT3_DEVELOP','UT_FILE_MAPPER','PACKAGE BODY')
    );
    --Act
    l_actual := ut3_develop.ut_file_mapper.build_file_mappings(
      'UT3_DEVELOP',
      ut3_develop.ut_varchar2_list(
        'C:\source\core\types\ut_file_mapping.tpb',
        'source/core/ut_file_mapper.pkb'
      )
    );
    --Assert
    ut.expect(anydata.convertCollection(l_actual)).to_equal(anydata.convertCollection(l_expected));
  end;

end;
/
