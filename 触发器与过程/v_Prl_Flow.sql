
create or replace view v_prl_flow as
select f.entgid,
       f.flowgid,
       f.modelgid,
       f.num,
       f.stat,
       f.fillusrgid,
       f.fillusrcode,
       f.fillusrname,
       f.fillusrdeptgid FillDeptGid,
       f.fillusrdeptcode FillDeptCode,
       f.fillusrdept filldeptname,
       f.askfee || '' FMemo
  from wf_prlYL_fee f
union
select f.entgid,
       f.flowgid,
       f.modelgid,
       f.num,
       f.stat,
       f.fillusrgid,
       f.fillusrcode,
       f.fillusrname,
       f.fillusrdeptgid FillDeptGid,
       f.fillusrdeptcode FillDeptCode,
       f.fillusrdept filldeptname,
       f.payfee || '' FMemo
  from wf_prlYL_pay f
union
select f.entgid,
       f.flowgid,
       f.modelgid,
       f.num,
       f.stat,
       f.fillusrgid,
       f.fillusrcode,
       f.fillusrname,
       f.filldeptgid,
       f.filldeptcode,
       f.filldeptname,
       f.sumfee || '' FMemo
  from wf_prlYL_baoxiao f
union
select f.entgid,
       f.flowgid,
       f.modelgid,
       f.num,
       f.stat,
       f.fillusrgid,
       f.fillusrcode,
       f.fillusrname,
       f.filldeptgid,
       f.filldeptcode,
       f.filldeptname,
       '' FMemo
  from wf_prlYL_chuchai f;