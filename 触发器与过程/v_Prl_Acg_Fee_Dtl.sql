
create or replace view v_prl_acg_fee_Dtl as
select a.code AcgCode,
       a.name AcgName,
       decode(wf.stat, 3, '�����', '������') stat,
       p.*,
       t.EXECNAME || ':' || t.name dname,
       wm.modelgid,
       wm.code ModelCode
  from prl_acg a,
       (select f.entgid,
               f.flowgid,
               f.num,
               f.createdate,
               f.acgtwogid acggid,
               f.companygid comgid,
               f.companyname comName,
               nvl(confirmfee, askfee) applyFee,
               '���õ�' atype,
               f.Memo,
               f.target
          from wf_PrlYL_fee f
         where f.stat not in ('13', '100', '��ֹ')
        union
        select f.entgid,
               f.flowgid,
               f.Num,
               f.createdate,
               fd.acggid acggid,
               f.comgid comgid,
               f.comName,
               fd.applyFee,
               '���˱�����' atype,
               f.Memo,
               '' target
          from wf_PrlYL_baoxiao f,
               (select d.entgid,
                       d.flowgid,
                       d.acggid,
                       sum(nvl(d.ApplyFee, 0)) applyFee
                  from wf_PrlYL_baoxiao_dtl d
                 group by d.entgid, d.flowgid, d.acggid) fd
         where f.entgid = fd.entgid
           and f.flowgid = fd.flowgid
           and f.stat not in ('��ֹ')
           and f.istake is null
        union
        select f.entgid,
               f.flowgid,
               f.Num,
               f.createdate,
               f.acgtwogid acggid,
               f.companygid comgid,
               f.companyname comName,
               nvl(payfee, 0) applyFee,
               '���' atype,
               f.Memo,
               '' target
          from wf_PrlYL_PAY f
         where f.stat not in ('13', '100', '��ֹ')) p,
       wf_flow wf,
       wf_model wm,
       (select max(t.createdate) createdate, t.entgid, t.flowgid
          from v_wf_task t
         where t.entgid = getentgid
           and t.stat <= 3
           and t.ismcf = 0
         group by t.entgid, t.flowgid) d,
       v_wf_task t
 where a.entgid = p.entgid
   and p.entgid = wf.entgid
   and p.entgid = d.entgid
   and p.entgid = t.ENTGID
   and p.entgid = wm.entgid
   and wm.modelgid = wf.modelgid
   and a.gid = p.acggid
   and p.flowgid = wf.flowgid
   and p.flowgid = t.flowgid
   and p.flowgid = d.flowgid
   and d.createdate = t.createdate
   and wf.stat < 4;