update wf_prlyl_baoxiao set stat = decode(stat, 'ִ����', '������', stat);
update wf_prlyl_cg set stat = decode(stat, 'ִ����', '������', stat);
update wf_prlyl_fee set stat = decode(stat, 'ִ����', '������', stat);
update wf_prlyl_chuchai set stat = decode(stat, 'ִ����', '������', stat);
update wf_prlyl_pay set stat = decode(stat, '��ȷ��', '֪ͨ����', stat);
update wf_prlyl_stamp set stat = decode(stat, 'ִ����', '������', stat);
