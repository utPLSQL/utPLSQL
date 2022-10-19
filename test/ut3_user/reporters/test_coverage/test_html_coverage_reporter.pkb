create or replace package body test_html_coverage_reporter is

  procedure report_on_file is
    l_expected  varchar2(32767);
    l_actual    clob;
    l_block_cov clob;
    l_name      varchar2(250);
    l_charset   varchar2(100) := 'ISO-8859-1';
  begin
    --Arrange
    l_name := ut3_tester_helper.coverage_helper.covered_package_name;
    if ut3_tester_helper.coverage_helper.block_coverage_available then
      l_block_cov := '(including <span class="yellow"><b>1</b> lines partially covered</span> ) ';
    end if;
    l_expected := '%<meta %charset='||l_charset||'" />%<h3>UT3_DEVELOP.'||upper(l_name)||'</h3>' ||
      '%<b>2</b> relevant lines. <span class="green"><b>1</b> lines covered</span> ' ||
      l_block_cov || 'and <span class="red"><b>1</b> lines missed%';

    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_develop.test_dummy_coverage',
              a_reporter=> ut3_develop.ut_coverage_html_reporter(),
              a_source_files => ut3_develop.ut_varchar2_list( 'test/ut3_develop.]'||l_name||q'[.pkb' ),
              a_test_files => ut3_develop.ut_varchar2_list( ),
              a_client_character_set => ']'||l_charset||q'['
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;

  procedure setup_long_lines is
    pragma autonomous_transaction;
  begin

    execute immediate q'[create or replace type string_array is table of varchar2(5 char);]';
    execute immediate q'[
      create or replace function f return integer is
         l_string_array string_array;
         l_count        integer;
      begin
         -- line is 1912 chars long, 1911 characters seem to be the max. line length that works (@formatter:off)
         l_string_array := string_array('aahed', 'aalii', 'aargh', 'aarti', 'abaca', 'abaci', 'abacs', 'abaft', 'abaka', 'abamp', 'aband', 'abash', 'abask', 'abaya', 'abbas', 'abbed', 'abbes', 'abcee', 'abeam', 'abear', 'abele', 'abers', 'abets', 'abies', 'abler', 'ables', 'ablet', 'ablow', 'abmho', 'abohm', 'aboil', 'aboma', 'aboon', 'abord', 'abore', 'abram', 'abray', 'abrim', 'abrin', 'abris', 'absey', 'absit', 'abuna', 'abune', 'abuts', 'abuzz', 'abyes', 'abysm', 'acais', 'acari', 'accas', 'accoy', 'acerb', 'acers', 'aceta', 'achar', 'ached', 'aches', 'achoo', 'acids', 'acidy', 'acing', 'acini', 'ackee', 'acker', 'acmes', 'acmic', 'acned', 'acnes', 'acock', 'acold', 'acred', 'acres', 'acros', 'acted', 'actin', 'acton', 'acyls', 'adaws', 'adays', 'adbot', 'addax', 'added', 'adder', 'addio', 'addle', 'adeem', 'adhan', 'adieu', 'adios', 'adits', 'adman', 'admen', 'admix', 'adobo', 'adown', 'adoze', 'adrad', 'adred', 'adsum', 'aduki', 'adunc', 'adust', 'advew', 'adyta', 'adzed', 'adzes', 'aecia', 'aedes', 'aegis', 'aeons', 'aerie', 'aeros', 'aesir', 'afald', 'afara', 'afars', 'afear', 'aflaj', 'afore', 'afrit', 'afros', 'agama', 'agami', 'agars', 'agast', 'agave', 'agaze', 'agene', 'agers', 'agger', 'aggie', 'aggri', 'aggro', 'aggry', 'aghas', 'agila', 'agios', 'agism', 'agist', 'agita', 'aglee', 'aglet', 'agley', 'agloo', 'aglus', 'agmas', 'agoge', 'agone', 'agons', 'agood', 'agora', 'agria', 'agrin', 'agros', 'agued', 'agues', 'aguna', 'aguti', 'aheap', 'ahent', 'ahigh', 'ahind', 'ahing', 'ahint', 'ahold', 'ahull', 'ahuru', 'aidas', 'aided', 'aides', 'aidoi', 'aidos', 'aiery', 'aigas', 'aight', 'ailed', 'aimed', 'aimer', 'ainee', 'ainga', 'aioli', 'aired', 'airer', 'airns', 'airth', 'airts', 'aitch', 'aitus', 'aiver', 'aiyee', 'aizle', 'ajies', 'ajiva', 'ajuga', 'ajwan', 'akees', 'akela', 'akene', 'aking', 'akita', 'akkas', 'alaap', 'alack', 'alamo', 'aland', 'alane', 'alang', 'a');
         select count(*) into l_count from table(l_string_array);
         return l_count;
      end;]';

    execute immediate q'[
      create or replace package test_f is
         --%suite

         --%test
         procedure fail_ut_coverage_html_reporter;
      end;]';

    execute immediate q'[
      create or replace package body test_f is
         procedure fail_ut_coverage_html_reporter is
         begin
            ut3_develop.ut.expect(f()).to_be_greater_or_equal(1);
         end;
      end;
      ]';
  end;

  procedure cleanup_long_lines is
    pragma autonomous_transaction;
  begin
    execute immediate 'drop package test_f';
    execute immediate 'drop function f';
    execute immediate 'drop type string_array force';
  end;

  procedure report_long_lines is
    l_expected  varchar2(32767);
    l_actual    clob;
    l_name      varchar2(250);
  begin
    --Arrange
    l_expected := '%l_string_array := string_array%';

    l_actual :=
      ut3_tester_helper.coverage_helper.run_tests_as_job(
        q'[
            ut3_develop.ut.run(
              a_path => 'ut3_user.test_f',
              a_reporter=> ut3_develop.ut_coverage_html_reporter(),
              a_include_objects => ut3_develop.ut_varchar2_list( 'UT3_USER.F' )
            )
          ]'
        );
    --Assert
    ut.expect(l_actual).to_be_like(l_expected);
  end;


end test_html_coverage_reporter;
/
