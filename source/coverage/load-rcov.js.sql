PROMPT Loading file: "rcov.js"
set define off
declare
  c_file_name constant varchar2(250) := 'rcov.js';
  l_file_part varchar2(32757);
  l_file_clob clob;
begin
  dbms_lob.createtemporary(l_file_clob , true);
  l_file_part := q'{
$(function() {
  $("#report_table").tablesorter({
    widgets: ['zebra'],
    textExtraction: 'complex'
  });

  $('.filter').change(function(){
    var ff = $('#file_filter').val(),
        cf = $('#coverage_filter').val();
    $('table#report_table tbody tr').each(function(i){
      if ((this.className.split(" ").indexOf(ff) > -1) && (this.className.split(" ").indexOf(cf) > -1)) {
        this.style.display = "";
      } else {
        this.style.display = "none";
      };
      restripe();
    });
  });

});

function restripe() {
  i = 0;
  $('table#report_table tbody tr').each(function(){
    if (this.style.display != "none") {
      i += 1;
      classes = this.className.split(" ");
      if ($.inArray("even",classes) != -1) {
        classes.splice($.inArray("even",classes),1);
      } else if ($.inArray("odd",classes) != -1) {
        classes.splice($.inArray("odd",classes),1);
      }
      if (i % 2 === 0) {
        this.className = classes.join(" ") + " odd";
      } else {
        this.className = classes.join(" ") + " even";
      }
    }
  });
}

// Fix IE's lack of support for indexOf (!)
if (!Array.indexOf) { Array.prototype.indexOf = function(obj){ for(var i=0; i<this.length; i++){ if(this[i]==obj){return i;} } return -1; };}
}';

  dbms_lob.writeappend(l_file_clob, length(l_file_part), l_file_part);

  insert
    into ut_coverage_templates( file_name, file_content, is_static )
    values ( c_file_name, l_file_clob, 'Y' );
  commit;
end;
/
