update wf_prlyl_baoxiao set stat = decode(stat, '执行中', '审批中', stat);
update wf_prlyl_cg set stat = decode(stat, '执行中', '审批中', stat);
update wf_prlyl_fee set stat = decode(stat, '执行中', '审批中', stat);
update wf_prlyl_chuchai set stat = decode(stat, '执行中', '审批中', stat);
update wf_prlyl_pay set stat = decode(stat, '已确认', '通知出纳', stat);
update wf_prlyl_stamp set stat = decode(stat, '执行中', '审批中', stat);
