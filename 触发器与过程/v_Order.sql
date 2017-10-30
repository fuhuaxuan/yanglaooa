
CREATE OR REPLACE VIEW v_Order AS
select f.entgid, f.flowgid, f.num, f.stat
  from wf_prlYL_baoxiao f
union
select f.entgid, f.flowgid, f.num, f.stat
  from wf_prlYL_fee f
union
select f.entgid, f.flowgid, f.num, f.stat
  from wf_prlYL_pay f
union
select f.entgid, f.flowgid, f.num, f.stat
  from wf_prlYL_stamp f
union
select f.entgid, f.flowgid, f.num, f.stat
  from wf_prlYL_chuchai f;