create or replace type body ut_output_buffer_base is
  /*
  utPLSQL - Version 3
  Copyright 2016 - 2021 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License"):
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
  */

  member procedure init(self in out nocopy ut_output_buffer_base, a_output_id raw := null, a_self_type varchar2 := null) is
    pragma autonomous_transaction;
    l_exists int;
  begin
    cleanup_buffer();
    self.self_type := coalesce(a_self_type,self.self_type);
    self.output_id := coalesce(a_output_id, self.output_id, sys_guid());
    self.start_date := coalesce(self.start_date, sysdate);
    select /*+ no_parallel */ count(*) into l_exists from ut_output_buffer_info_tmp where output_id = self.output_id;
    if ( l_exists > 0 ) then
      update  /*+ no_parallel */ ut_output_buffer_info_tmp set start_date = self.start_date where output_id = self.output_id;
    else
      insert /*+ no_parallel */ into ut_output_buffer_info_tmp(output_id, start_date) values (self.output_id, self.start_date);
    end if;
    commit;
    dbms_lock.allocate_unique( self.output_id, self.lock_handle);
    self.is_closed := 0;
  end;

  member procedure lock_buffer(a_timeout_sec number := null) is
    l_status integer;
  begin
    l_status := dbms_lock.request( self.lock_handle, dbms_lock.x_mode, 5, false );
    if l_status != 0 then
      raise_application_error(-20000, 'Cannot allocate lock for output buffer of reporter. lock request status = '||l_status||', lock handle = '||self.lock_handle||', self.output_id ='||self.output_id);
    end if;
  end;

  member procedure close(self in out nocopy ut_output_buffer_base) is
    l_status integer;
  begin
    l_status := dbms_lock.release( self.lock_handle );
    if l_status != 0 then
      raise_application_error(-20000, 'Cannot release lock for output buffer of reporter. Lock_handle = '||self.lock_handle||' status = '||l_status);
    end if;
    self.is_closed := 1;
  end;


  member procedure remove_buffer_info(self in ut_output_buffer_base) is
      pragma autonomous_transaction;
    begin
      delete from ut_output_buffer_info_tmp a
       where a.output_id = self.output_id;
      commit;
    end;

  member function timeout_producer_not_started( a_producer_started boolean, a_already_waited_sec number, a_init_wait_sec number ) return boolean
  is
    l_result boolean := false;
  begin
    if not a_producer_started and a_already_waited_sec >= a_init_wait_sec then
      if a_init_wait_sec > 0 then
        self.remove_buffer_info();
        raise_application_error(
          ut_utils.gc_out_buffer_timeout,
          'Timeout occurred while waiting for report data producer to start. Waited for: '||ut_utils.to_string( a_already_waited_sec )||' seconds.'
        );
      else
        l_result := true;
      end if;
    end if;
    return l_result;
  end;

  member function timeout_producer_not_finished(a_producer_finished boolean, a_already_waited_sec number, a_timeout_sec number) return boolean
  is
    l_result boolean := false;
  begin
    if not a_producer_finished and a_timeout_sec is not null and a_already_waited_sec >= a_timeout_sec then
      if a_timeout_sec > 0 then
        self.remove_buffer_info();
        raise_application_error(
          ut_utils.gc_out_buffer_timeout,
          'Timeout occurred while waiting for more data from producer. Waited for: '||ut_utils.to_string( a_already_waited_sec )||' seconds.'
        );
      else
        l_result := true;
      end if;
    end if;
    return l_result;
  end;

  member function get_lock_status return integer is
    l_result integer;
    l_release_status integer;
  begin
    l_result := dbms_lock.request( self.lock_handle, dbms_lock.s_mode, 0, false );
    if l_result = 0 then
      l_release_status := dbms_lock.release( self.lock_handle );
    end if;
    return l_result;
  end;

  member function get_lines_cursor(a_initial_timeout number := null, a_timeout_sec number := null) return sys_refcursor is
    l_lines sys_refcursor;
  begin
    open l_lines for
      select /*+ no_parallel */ text, item_type
        from table(self.get_lines(a_initial_timeout, a_timeout_sec));
    return l_lines;
  end;

  member procedure lines_to_dbms_output(self in ut_output_buffer_base, a_initial_timeout number := null, a_timeout_sec number := null) is
    l_data      sys_refcursor;
    l_clob      clob;
    l_item_type varchar2(32767);
    l_lines     ut_varchar2_list;
  begin
    l_data := self.get_lines_cursor(a_initial_timeout, a_timeout_sec);
    loop
      fetch l_data into l_clob, l_item_type;
      exit when l_data%notfound;
      if dbms_lob.getlength(l_clob) > 32767 then
        l_lines := ut_utils.clob_to_table(l_clob);
        for i in 1 .. l_lines.count loop
          dbms_output.put_line(l_lines(i));
        end loop;
      else
        dbms_output.put_line(l_clob);
      end if;
    end loop;
    close l_data;
  end;

  member procedure cleanup_buffer(self in ut_output_buffer_base, a_retention_time_sec natural := null) is
    gc_buffer_retention_sec  constant naturaln := coalesce(a_retention_time_sec, 60 * 60 * 24 * 5); -- 5 days
    l_retention_days         number := gc_buffer_retention_sec / (60 * 60 * 24);
    l_max_retention_date     date := sysdate - l_retention_days;
    pragma autonomous_transaction;
  begin
    delete from ut_output_buffer_info_tmp i where i.start_date <= l_max_retention_date;
    commit;
  end;

end;
/