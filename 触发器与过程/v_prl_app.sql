create or replace view v_prl_app as
select f.entgid,
       f.flowgid,
       f.appgid,
       f.appcode,
       f.appname,
       f.appassign,
       f.apptype,
       f.appdate,
       f.appmemo
  from wf_prlyl_baoxiao_app f
union
select f.entgid,
       f.flowgid,
       f.appgid,
       f.appcode,
       f.appname,
       f.appassign,
       f.apptype,
       f.appdate,
       f.note
  from wf_prlyl_fee_app f
union
select f.entgid,
       f.flowgid,
       f.appgid,
       f.appcode,
       f.appname,
       f.appassign,
       f.apptype,
       f.appdate,
       f.note
  from wf_prlyl_pay_app f
union
select f.entgid,
       f.flowgid,
       f.appgid,
       f.appcode,
       f.appname,
       f.appassign,
       f.apptype,
       f.appdate,
       f.appmemo
  from wf_prlyl_cg_app f
union
select f.entgid,
       f.flowgid,
       f.appgid,
       f.appcode,
       f.appname,
       f.appassign,
       f.apptype,
       f.appdate,
       f.appmemo
  from wf_prlyl_chuchai_app f
union
select f.entgid,
       f.flowgid,
       f.appgid,
       f.appcode,
       f.appname,
       f.appassign,
       f.apptype,
       f.appdate,
       f.appmemo
  from wf_prlyl_contract_app f
union
select f.entgid,
       f.flowgid,
       f.appgid,
       f.appcode,
       f.appname,
       f.appassign,
       f.apptype,
       f.appdate,
       f.appmemo
  from wf_prlyl_stamp_app f;
