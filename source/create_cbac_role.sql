/*
  utPLSQL - Version 3
  Copyright 2016 - 2026 utPLSQL Project

  Licensed under the Apache License, Version 2.0 (the "License").
  You may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

  Creates the code based access control (CBAC) role that gives invoker rights framework packages
  access to framework tables, which are not granted to the users calling the framework.
  The role is granted to the framework owner, as Oracle only allows granting a role to a program unit
  when the role is granted to the owner of that program unit.
  Each framework owner gets its own role, so packages of one utPLSQL installation cannot access tables of another one.
  The role is created only if it does not exist yet, so the installation can be repeated without uninstalling first.
*/

prompt Creating role &&ut3_owner._cbac_modify_objects_role and granting it to &&ut3_owner

declare
  e_role_exists exception;
  pragma exception_init(e_role_exists, -1921);
begin
  execute immediate 'create role &&ut3_owner._cbac_modify_objects_role';
exception
  when e_role_exists then
    null;
end;
/

grant &&ut3_owner._cbac_modify_objects_role to &&ut3_owner;
