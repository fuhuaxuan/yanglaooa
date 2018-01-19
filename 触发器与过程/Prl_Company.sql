
create or replace view Prl_Company as  
select d.entgid, d.gid, d.code2 code, d.name, 10 stat
  from dept d
 where length(d.code2) = 4
   and lower(d.code2) <> 'dept'
   order by d.code2;
