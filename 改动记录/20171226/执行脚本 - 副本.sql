update wf_flow f
   set f.flownote = f.flownote ||
                    (select decode(ApplyType,
                                   '��ͬǩ����ӡ',
                                   '��������˾��' || ContactName,
                                   '')
                       from wf_prl_stamp wf
                      where wf.flowgid = f.flowgid)
 where exists (select 1 from wf_prl_stamp wf where wf.flowgid = f.flowgid)

B78EB93A60B44944B6056C174B548DD6