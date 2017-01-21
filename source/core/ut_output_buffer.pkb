create or replace package body ut_output_buffer is

  procedure send_line(a_reporter_id varchar2, a_text varchar2) is
    l_text_list  ut_varchar2_list;
    pragma autonomous_transaction;
  begin
    if a_reporter_id is not null and a_text is not null then
      if length(a_text) > ut_utils.gc_max_storage_varchar2_len then
        l_text_list := ut_utils.clob_to_table(a_text, ut_utils.gc_max_storage_varchar2_len);
        forall i in 1 .. l_text_list.count
          insert into ut_output_buffer_tmp(reporter_id, message_id, text)
          values (a_reporter_id, ut_output_buffer_id_seq.nextval, l_text_list(i));
      else
        insert into ut_output_buffer_tmp(reporter_id, message_id, text)
        values (a_reporter_id, ut_output_buffer_id_seq.nextval, a_text);
      end if;
      commit;
    end if;
  end;

  procedure close(a_reporter_id varchar2) is
    pragma autonomous_transaction;
  begin
    insert into ut_output_buffer_tmp(reporter_id, message_id, is_finished)
    values (a_reporter_id, ut_output_buffer_id_seq.nextval, 1);
    commit;
  end;

  function get_lines(a_reporter_id varchar2, a_timeout_sec naturaln := gc_max_wait_sec) return ut_varchar2_list pipelined is
    pragma autonomous_transaction;
    l_results        ut_varchar2_list;
    l_wait_wait_time number(10,1) := 0;
    c_sleep_time     number(1,1) := 0.1; --sleep for 100 ms between checks
    l_finished       boolean := false;
  begin
    loop
      delete from (
        select *
          from ut_output_buffer_tmp where reporter_id = a_reporter_id order by message_id
        )
      returning text bulk collect into l_results;

      --nothing fetched from output, wait and try again
      if l_results.count = 0 then
        dbms_lock.sleep(c_sleep_time);
        l_wait_wait_time := l_wait_wait_time + c_sleep_time;
      else
        commit;
        for i in 1 .. l_results.count loop
          if l_results(i) is not null then
            pipe row(l_results(i));
          else
            l_finished := true;
            exit;
          end if;
        end loop;
      end if;
      exit when l_wait_wait_time >= a_timeout_sec or l_finished;
    end loop;
    return;
  end;

  procedure purge(a_reporters ut_reporters) is
  begin
    delete from ut_output_buffer_tmp t
     where t.reporter_id in (select r.reporter_id from table(a_reporters) r);
  end;

end;
/
