create or replace package test_annotation_parser is

  --%suite(ut_annotation_parser)
  --%suitepath(utplsql.ut3_tester.core.annotations)

  --%test(Treats procedure level annotations as package level, if mixed with comments)
  procedure test_proc_comments;
  --%test(Includes floating annotations between procedures and package)
  procedure include_floating_annotations;
  --%test(Parses complex annotations on procedures and functions)
  procedure parse_complex_with_functions;
  --%test(Parses package annotations without any procedure annotations)
  procedure no_procedure_annotation;
  --%test(Parses package level annotations with Accessible by)
  procedure parse_accessible_by;
  --%test(Parses package level annotations with multiline declaration)
  procedure complex_package_declaration;
  --%test(Parses complex text in annotation)
  procedure complex_text;
  --%test(Ignores content of multi-line comments)
  procedure ignore_annotations_in_comments;
  -- %test(ignore wrapped package source)
  procedure ignore_wrapped_package;
  --%test(Parses package level annotations with annotation params containing brackets)
  procedure brackets_in_desc;
  --%test(Parses annotation text even with spaces before brackets)
  procedure test_space_before_annot_params;
  -- %test(Parses source-code with Windows-style newline)
  procedure test_windows_newline;
  -- %test(parse annotations with very long procedure name)
  procedure test_annot_very_long_name;
  -- %test(Parses upper case annotations)
  procedure test_upper_annot;

  -- %test(empty source returns immediately without processing)
  procedure test_rmc_empty_source;
  -- %test(source with no multiline comment markers returned unchanged)
  procedure test_rmc_no_ml_comment_marker;
  -- %test(line entirely inside multiline comment is blanked)
  procedure test_rmc_line_inside_ml_comment;
  -- %test(closing delimiter mid-line falls through to scan remainder)
  procedure test_rmc_ml_comment_closed_midline;
  -- %test(fast path line with no slash dash or quote copied unchanged)
  procedure test_rmc_fast_path_no_tokens;
  -- %test(single-line block comment removed on same line)
  procedure test_rmc_ml_comment_single_line;
  -- %test(single-line comment preserved intact)
  procedure test_rmc_single_line_comment_preserved;
  -- %test(string literal containing comment markers not stripped)
  procedure test_rmc_string_literal_protects_markers;
  -- %test(string literal with escaped quotes handled correctly)
  procedure test_rmc_string_literal_escaped_quotes;
  -- %test(q-quoted string literal protects interior comment markers)
  procedure test_rmc_q_quoted_string_literal;
  -- %test(unclosed string literal copies remainder and exits scan)
  procedure test_rmc_unclosed_string_literal;
  -- %test(unclosed q-quoted string copies remainder and exits scan)
  procedure test_rmc_unclosed_q_string;
  -- %test(multiple block comments on single line all removed)
  procedure test_rmc_multiple_ml_comments_one_line;
  -- %test(comment markers after string with slash handled correctly)
  procedure test_rmc_comment_after_string_with_slash;
  --%test(Procedure header spanning multiple lines is handled correctly)
  procedure test_multiline_proc_header_lines;
  --%test(Non-comment line between annotation and procedure resets association)
  procedure test_non_comment_line_resets_block_lines;
  --%test(Comment with non-whitespace before dashes is not treated as annotation)
  procedure test_annotation_not_at_line_start_ignored_lines;
  --%test(Spaces between dashes and annotation qualifier are skipped correctly)
  procedure test_space_between_dashes_and_qualifier_lines;
  --%test(Percent sign not immediately after dashes is not treated as annotation)
  procedure test_percent_not_after_dashes_ignored_lines;

end test_annotation_parser;
/