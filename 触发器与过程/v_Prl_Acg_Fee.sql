
create or replace view v_prl_acg_fee as	
select c.EntGid,	
       c.Gid,	
       c.Year,	
       c.COMPANYGid ComGid,	
       o.name ComName,	
       c.ACGGID,	
       a.code AcgCode,	
       a.name AcgName,	
       nvl(c.LeftBudgutFee, 0) LeftFee,	
       nvl(f.applyFee, 0) + nvl(b.applyFee, 0) + nvl(p.applyFee, 0) YesFee,	
       nvl(f.applyFee, 0) FYesFee,	
       nvl(b.applyFee, 0) BYesFee,	
       nvl(p.applyFee, 0) PYesFee,	
       nvl(f1.applyFee, 0) + nvl(b1.applyFee, 0) + nvl(p1.applyFee, 0) AllFee,	
       nvl(f1.applyFee, 0) FAllFee,	
       nvl(b1.applyFee, 0) BAllFee,	
       nvl(p1.applyFee, 0) PAllFee	
  from PRL_ACG_COMPANY c,	
       prl_acg a,	
       prl_company o,	
       (select f.entgid,	
               to_char(f.createdate, 'YYYY') Year,	
               f.acgtwogid acggid,	
               f.companygid comgid,	
               sum(nvl(confirmfee, askfee)) applyFee,	
               '费用单' atype	
          from wf_PrlYL_fee f, wf_flow wf	
         where f.entgid = wf.entgid	
           and f.flowgid = wf.flowgid	
           and wf.stat < 3	
           and f.stat not in ('13', '100', '终止')	
         group by f.entgid,	
                  f.acgtwogid,	
                  f.companygid,	
                  to_char(f.createdate, 'YYYY')) f,	
       (select f.entgid,	
               to_char(f.createdate, 'YYYY') Year,	
               f.acgtwogid acggid,	
               f.companygid comgid,	
               sum(nvl(confirmfee, askfee)) applyFee,	
               '费用单' atype	
          from wf_PrlYL_fee f, wf_flow wf	
         where f.entgid = wf.entgid	
           and f.flowgid = wf.flowgid	
           and wf.stat = 3	
           and f.stat not in ('13', '100', '终止')	
         group by f.entgid,	
                  f.acgtwogid,	
                  f.companygid,	
                  to_char(f.createdate, 'YYYY')) f1,	
       (select f.entgid,	
               to_char(f.createdate, 'YYYY') Year,	
               fd.acggid acggid,	
               f.comgid comgid,	
               sum(nvl(ApplyFee, 0)) applyFee,	
               '个人报销单' atype	
          from wf_PrlYL_baoxiao f, wf_PrlYL_baoxiao_dtl fd, wf_flow wf	
         where f.entgid = wf.entgid	
           and f.entgid = fd.entgid	
           and f.flowgid = wf.flowgid	
           and f.flowgid = fd.flowgid	
           and wf.stat < 3	
           and f.stat not in ('终止')	
           and f.istake is null	
         group by f.entgid,	
                  fd.acggid,	
                  f.comgid,	
                  to_char(f.createdate, 'YYYY')) b,	
       (select f.entgid,	
               to_char(f.createdate, 'YYYY') Year,	
               fd.acggid acggid,	
               f.comgid comgid,	
               sum(nvl(ApplyFee, 0)) applyFee,	
               '个人报销单' atype	
          from wf_PrlYL_baoxiao f, wf_PrlYL_baoxiao_dtl fd, wf_flow wf	
         where f.entgid = wf.entgid	
           and f.entgid = fd.entgid	
           and f.flowgid = wf.flowgid	
           and f.flowgid = fd.flowgid	
           and wf.stat = 3	
           and f.stat not in ('终止')	
           and f.istake is null	
         group by f.entgid,	
                  fd.acggid,	
                  f.comgid,	
                  to_char(f.createdate, 'YYYY')) b1,	
       (select f.entgid,	
               to_char(f.createdate, 'YYYY') Year,	
               f.acgtwogid acggid,	
               f.companygid comgid,	
               sum(nvl(payfee, 0)) applyFee,	
               '付款单' atype	
          from wf_PrlYL_PAY f, wf_flow wf	
         where f.entgid = wf.entgid	
           and f.flowgid = wf.flowgid	
           and wf.stat < 3	
           and f.stat not in ('13', '100', '终止')	
           and f.feeflowgid is null	
         group by f.entgid,	
                  f.acgtwogid,	
                  f.companygid,	
                  to_char(f.createdate, 'YYYY')) p,	
       (select f.entgid,	
               to_char(f.createdate, 'YYYY') Year,	
               f.acgtwogid acggid,	
               f.companygid comgid,	
               sum(nvl(payfee, 0)) applyFee,	
               '付款单' atype	
          from wf_PrlYL_PAY f, wf_flow wf	
         where f.entgid = wf.entgid	
           and f.flowgid = wf.flowgid	
           and wf.stat = 3	
           and f.stat not in ('13', '100', '终止')	
           and f.feeflowgid is null	
         group by f.entgid,	
                  f.acgtwogid,	
                  f.companygid,	
                  to_char(f.createdate, 'YYYY')) p1	
 where c.entgid = a.entgid	
   and c.entgid = o.entgid	
   and c.acggid = a.gid	
   and c.companygid = o.gid	
   and c.entgid = f.entgid(+)	
   and c.Year = f.year(+)	
   and c.COMPANYGid = f.comgid(+)	
   and c.acggid = f.acggid(+)	
   and c.entgid = b.entgid(+)	
   and c.Year = b.year(+)	
   and c.COMPANYGid = b.comgid(+)	
   and c.acggid = b.acggid(+)	
   and c.entgid = p.entgid(+)	
   and c.Year = p.year(+)	
   and c.COMPANYGid = p.comgid(+)	
   and c.acggid = p.acggid(+)	
   and c.entgid = f1.entgid(+)	
   and c.Year = f1.year(+)	
   and c.COMPANYGid = f1.comgid(+)	
   and c.acggid = f1.acggid(+)	
   and c.entgid = b1.entgid(+)	
   and c.Year = b1.year(+)	
   and c.COMPANYGid = b1.comgid(+)	
   and c.acggid = b1.acggid(+)	
   and c.entgid = p1.entgid(+)	
   and c.Year = p1.year(+)	
   and c.COMPANYGid = p1.comgid(+)	
   and c.acggid = p1.acggid(+);	
