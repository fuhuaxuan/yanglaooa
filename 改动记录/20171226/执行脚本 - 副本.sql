update wf_flow f
   set f.flownote = f.flownote ||
                    (select decode(ApplyType,
                                   '合同签署用印',
                                   '；合作公司：' || ContactName,
                                   '')
                       from wf_prl_stamp wf
                      where wf.flowgid = f.flowgid)
 where exists (select 1 from wf_prl_stamp wf where wf.flowgid = f.flowgid)
