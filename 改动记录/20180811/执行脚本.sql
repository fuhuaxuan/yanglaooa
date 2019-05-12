create or replace procedure P_PrlYL_BaoXiao_doMail(p_FlowGid varchar --����Gid
                                                   ) as
  v_Stage   varchar2(1024); -- ���̳���
  v_ErrText varchar2(1024); -- Oracle������Ϣ

  v_EntGid varchar2(32); --��ҵGid

  v_Title   varchar2(64); --����
  v_Email   varchar(1024); --�ʼ�
  v_Content varchar2(32500); --����

  v_Head    varchar(64); --��ͷ
  v_Body    varchar(2048); --������
  v_TStart  varchar(32);
  v_TEnd    varchar(32);
  v_Foot    varchar(64); --��β
  v_Count   int;
  v_CeoName varchar(64); --CEO

begin
  -- ��ȡ��ҵGid
  v_EntGid  := getEntGid;
  v_Head    := '<table border="0" style="width:500px;"><tr><td>���� :</td></tr>';
  v_TStart  := '<tr><td>';
  v_TEnd    := '��</td></tr>';
  v_Foot    := '<tr><td>-----------����չʾ���-----------</td></tr></table>';
  v_Email   := '';
  v_Content := '';

  select count(*)
    into v_Count
    from wf_task t
   where t.EntGid = v_EntGid
     and t.FlowGid = p_FlowGid
     and t.Stat = 1
     and lower(t.code) like '%_tc1%';

  if v_Count > 0 then
    select t.Note
      into v_CeoName
      from wf_task t
     where t.EntGid = v_EntGid
       and t.FlowGid = p_FlowGid
       and t.Stat = 1
       and lower(t.code) like '%_tc1%';
  end if;

  --for ѭ�� ȡ��δ��ȡ�Ŀ��
  for R in (select f.*, wm.name ModelName
              from Wf_PrlYL_Baoxiao f, wf_model wm
             where f.EntGid = v_EntGid
               and f.entgid = wm.entgid
               and f.FlowGid = p_FlowGid
               and f.modelgid = wm.modelgid) loop
    v_Stage   := 'FlowGid��' || R.Flowgid || '��ģ�ͣ�' || R.ModelName;
    v_Title   := '���˱�����������:' || R.Filldeptname;
    v_Content := v_Content || v_Head;
  
    if v_Count > 0 then
      v_Body    := '<font stylr="color:red">' || v_CeoName || '</font>';
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    end if;
  
    v_Body    := '[��������] : ' || R.ModelName;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[����] : ' || R.Num;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[������] : ' || R.Fillusrname;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[����ʱ��] : ' || to_char(R.Createdate, 'YYYY.MM.DD HH24:MI');
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[��˾����] : ' || R.Comname;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '<table cellpadding="0" cellspacing="1" class="ListBar" width="100%" style="background-color: #d9dbdf;">';
    v_Body    := v_Body || '<col style="padding-left:4px;width:80%">';
    v_Body    := v_Body || '<col style="padding-left:4px;width:20%">';
    v_Body    := v_Body ||
                 '<tr style="background-color: #ecedef;" align="center">';
    v_Body    := v_Body || '<td>��Ŀ��Ϣ</td>';
    v_Body    := v_Body || '<td>����������[Ԫ]</td>';
    v_Body    := v_Body || '</tr>';
    v_Content := v_Content || v_TStart || v_Body;
  
    for D in (select f.*
                from Wf_PrlYL_Baoxiao_Dtl f
               where f.EntGid = v_EntGid
                 and f.FlowGid = p_FlowGid) loop
      v_Body    := '<tr valign="top" style="background-color: white">';
      v_Body    := v_Body || '<td>[' || D.Acgcode || ']' || D.Acgname ||
                   '</td>';
      v_Body    := v_Body || '<td align="center">' || D.Applyfee || '</td>';
      v_Body    := v_Body || '</tr>';
      v_Content := v_Content || v_Body;
    end loop;
  
    v_Body    := '</table>';
    v_Content := v_Content || v_Body || '</td></tr>';
    v_Body    := '[����������] : ' || R.Sumfee || 'Ԫ';
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[������ע] : ' || R.Memo;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
  
    v_Content := v_Content || v_Foot;
    for U in (select hr.Email
                from hr_emp hr
               where hr.entgid = R.EntGid
                 and exists (select 1
                        from wf_task t
                       where t.EntGid = hr.EntGid
                         and t.FlowGid = R.Flowgid
                         and t.ExecGid = hr.UsrGid
                         and t.Stat = 1)) loop
      v_Email := U.EMAIL || ',';
    end loop;
    if v_Email is not null then
      HDNet_SendMail(v_Title, v_Email, v_Content);
    end if;
  end loop;
  --ɾ��
  update wf_task t
     set t.stat = 4
   where t.EntGid = v_EntGid
     and t.FlowGid = p_FlowGid
     and t.Stat = 1
     and lower(t.code) like '%_tc1%';
  commit;
  --�쳣����
exception
  when others then
    begin
      v_ErrText := substr(v_Stage || ' ʧ��!' || SQLCode || ':' || SQLERRM,
                          1,
                          1024);
      --������־
      insert into Log
        (EntGid,
         EntCode,
         EntName,
         UsrGid,
         UsrCode,
         UsrName,
         CreateDate,
         Atype,
         AContent)
        select e.gid,
               e.code,
               e.name,
               'sys',
               'sys',
               'ϵͳ�Զ�',
               sysdate,
               30,
               v_ErrText
          from ent e
         where e.gid = v_EntGid;
      commit;
    end;
end;
/

create or replace procedure P_PrlYL_Fee_doMail(p_FlowGid varchar --����Gid
                                               ) as
  v_Stage   varchar2(1024); -- ���̳���
  v_ErrText varchar2(1024); -- Oracle������Ϣ

  v_EntGid varchar2(32); --��ҵGid

  v_Title   varchar2(64); --����
  v_Email   varchar(1024); --�ʼ�
  v_Content varchar2(32500); --����

  v_Head   varchar(64); --��ͷ
  v_Body   varchar(2048); --������
  v_TStart varchar(32);
  v_TEnd   varchar(32);
  v_Foot   varchar(64); --��β
  v_Count       int;
  v_CeoName   varchar(64); --CEO

begin
  -- ��ȡ��ҵGid
  v_EntGid  := getEntGid;
  v_Head    := '<table border="0" style="width:500px;"><tr><td>���� :</td></tr>';
  v_TStart  := '<tr><td>';
  v_TEnd    := '��</td></tr>';
  v_Foot    := '<tr><td>-----------����չʾ���-----------</td></tr></table>';
  v_Email   := '';
  v_Content := '';

  select count(*)
    into v_Count
    from wf_task t
   where t.EntGid = v_EntGid
     and t.FlowGid = p_FlowGid
     and t.Stat = 1
     and lower(t.code) like '%_tc1%';

  if v_Count > 0 then
    select t.Note
      into v_CeoName
      from wf_task t
     where t.EntGid = v_EntGid
       and t.FlowGid = p_FlowGid
       and t.Stat = 1
       and lower(t.code) like '%_tc1%';
  end if;

  --for ѭ�� ȡ��δ��ȡ�Ŀ��
  for R in (select f.*, wm.name ModelName
              from wf_PrlYL_Fee f, wf_model wm
             where f.EntGid = v_EntGid
               and f.entgid = wm.entgid
               and f.FlowGid = p_FlowGid
               and f.modelgid = wm.modelgid) loop
    v_Stage   := 'FlowGid��' || R.Flowgid || '��ģ�ͣ�'|| R.ModelName;
    v_Title   := '���ô�������:' || R.Fillusrdept;
    v_Content := v_Content || v_Head;
  
    if v_Count > 0 then
      v_Body    := '<font stylr="color:red">' || v_CeoName || '</font>';
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    end if;

    v_Body    := '[��������] : ' || R.ModelName;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[����] : ' || R.Num;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[������] : ' || R.Fillusrname;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[����ʱ��] : ' || to_char(R.Createdate, 'YYYY.MM.DD HH24:MI');
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[��˾����] : ' || R.Companyname;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[��Ŀ����] : ' || R.ACGONENAME || '-' || R.Acgtwoname;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[DOA��Ϣ] : ' || R.Doacode || '-' || R.Doaname;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[����Ŀ��] : ' || R.Target;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[������Ŀ����] : ' || R.Memo;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[�Ƽ�������] : ' || R.Reason;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[ʣ��Ԥ����] : ' || R.Controlfee || 'Ԫ';
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[����������] : ����' || R.Askfee || 'Ԫ������' ||
                 nvl(R.Naskfee, '0') || 'Ԫ';
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
  
    v_Content := v_Content || v_Foot;
    for U in (select hr.Email
                from hr_emp hr
               where hr.entgid = R.EntGid
                 and exists (select 1
                        from wf_task t
                       where t.EntGid = hr.EntGid
                         and t.FlowGid = R.Flowgid
                         and t.ExecGid = hr.UsrGid
                         and t.Stat = 1)) loop
      v_Email := U.EMAIL || ',';
    end loop;
    if v_Email is not null then
      HDNet_SendMail(v_Title, v_Email, v_Content);
    end if;
  end loop;
  --ɾ��
  update wf_task t
     set t.stat = 4
   where t.EntGid = v_EntGid
     and t.FlowGid = p_FlowGid
     and t.Stat = 1
     and lower(t.code) like '%_tc1%';
  commit;
  --�쳣����
exception
  when others then
    begin
      v_ErrText := substr(v_Stage || ' ʧ��!' || SQLCode || ':' || SQLERRM,
                          1,
                          1024);
      --������־
      insert into Log
        (EntGid,
         EntCode,
         EntName,
         UsrGid,
         UsrCode,
         UsrName,
         CreateDate,
         Atype,
         AContent)
        select e.gid,
               e.code,
               e.name,
               'sys',
               'sys',
               'ϵͳ�Զ�',
               sysdate,
               30,
               v_ErrText
          from ent e
         where e.gid = v_EntGid;
      commit;
    end;
end;
/
create or replace procedure P_PrlYL_Pay_doMail(p_FlowGid varchar --����Gid
                                               ) as
  v_Stage   varchar2(1024); -- ���̳���
  v_ErrText varchar2(1024); -- Oracle������Ϣ

  v_EntGid varchar2(32); --��ҵGid

  v_Title   varchar2(64); --����
  v_Email   varchar(1024); --�ʼ�
  v_Content varchar2(32500); --����

  v_Head   varchar(64); --��ͷ
  v_Body   varchar(2048); --������
  v_TStart varchar(32);
  v_TEnd   varchar(32);
  v_Foot   varchar(64); --��β
  v_Count       int;
  v_CeoName   varchar(64); --CEO

begin
  -- ��ȡ��ҵGid
  v_EntGid  := getEntGid;
  v_Head    := '<table border="0" style="width:500px;"><tr><td>���� :</td></tr>';
  v_TStart  := '<tr><td>';
  v_TEnd    := '��</td></tr>';
  v_Foot    := '<tr><td>-----------����չʾ���-----------</td></tr></table>';
  v_Email   := '';
  v_Content := '';

  select count(*)
    into v_Count
    from wf_task t
   where t.EntGid = v_EntGid
     and t.FlowGid = p_FlowGid
     and t.Stat = 1
     and lower(t.code) like '%_tc1%';

  if v_Count > 0 then
    select t.Note
      into v_CeoName
      from wf_task t
     where t.EntGid = v_EntGid
       and t.FlowGid = p_FlowGid
       and t.Stat = 1
       and lower(t.code) like '%_tc1%';
  end if;

  --for ѭ�� ȡ��δ��ȡ�Ŀ��
  for R in (select f.*, wm.name ModelName
              from wf_PrlYL_Pay f, wf_model wm
             where f.EntGid = v_EntGid
               and f.entgid = wm.entgid
               and f.FlowGid = p_FlowGid
               and f.modelgid = wm.modelgid) loop
    v_Stage   := 'FlowGid��' || R.Flowgid || '��ģ�ͣ�' || R.ModelName;
    v_Title   := '�����������:' || R.Fillusrdept;
    v_Content := v_Content || v_Head;
  
    if v_Count > 0 then
      v_Body    := '<font stylr="color:red">' || v_CeoName || '</font>';
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    end if;

    v_Body    := '[��������] : ' || R.ModelName;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[����] : ' || R.Num;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[������] : ' || R.Fillusrname;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[����ʱ��] : ' || to_char(R.Createdate, 'YYYY.MM.DD HH24:MI');
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    if R.Feeflowgid is not null then
      v_Body    := '[���õ���] : ' || R.Feenum || '-' || R.Partnum;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[�Ƿ�β��] : ';
      if R.Isend = 10 then
        v_Body := v_Body || '��';
      else
        v_Body := v_Body || '��';
      end if;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    end if;
    v_Body    := '[��˾����] : ' || R.Companyname;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[��Ŀ����] : ' || R.acgonename || '-' || R.acgtwoname;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[DOA��Ϣ] : ' || R.Doacode;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[������] : ' || nvl(R.payfee, 0) || 'Ԫ';
    if substr(R.Acgonename, 0, 1) = '3' then
      v_Body := v_Body || '(��˾�е���' || nvl(R.Npayfee, 0) || 'Ԫ)';
    end if;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[Ҫ��֧����ʽ] : ' || R.Payway;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[�����(��д)] : ' || R.Bigrmb;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[���ע] :' || R.Memo;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[�տλ] : ' || R.Payee;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    if R.Feeflowgid is not null then
      v_Body    := '[��A����Ŀ�ܶ�] : ' || R.feea;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[��B���Ѹ�����] : ' || R.Feeb;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[��C�����θ���] : ' || R.Payfee;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[��Ƿ���=A-B-C] : ' || R.Feeleft;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[ʵ�ʸ����ܶ�=B+C] : ' || R.Feeok;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    end if;
  
    v_Content := v_Content || v_Foot;
    for U in (select hr.Email
                from hr_emp hr
               where hr.entgid = R.EntGid
                 and exists (select 1
                        from wf_task t
                       where t.EntGid = hr.EntGid
                         and t.FlowGid = R.Flowgid
                         and t.ExecGid = hr.UsrGid
                         and t.Stat = 1)) loop
      v_Email := U.EMAIL || ',';
    end loop;
    if v_Email is not null then
      HDNet_SendMail(v_Title, v_Email, v_Content);
    end if;
  end loop;
  --ɾ��
  update wf_task t
     set t.stat = 4
   where t.EntGid = v_EntGid
     and t.FlowGid = p_FlowGid
     and t.Stat = 1
     and lower(t.code) like '%_tc1%';
  commit;
  --�쳣����
exception
  when others then
    begin
      v_ErrText := substr(v_Stage || ' ʧ��!' || SQLCode || ':' || SQLERRM,
                          1,
                          1024);
      --������־
      insert into Log
        (EntGid,
         EntCode,
         EntName,
         UsrGid,
         UsrCode,
         UsrName,
         CreateDate,
         Atype,
         AContent)
        select e.gid,
               e.code,
               e.name,
               'sys',
               'sys',
               'ϵͳ�Զ�',
               sysdate,
               30,
               v_ErrText
          from ent e
         where e.gid = v_EntGid;
      commit;
    end;
end;
/
create or replace procedure P_PrlYL_Stamp_doMail(p_FlowGid varchar --����Gid
                                               ) as
  v_Stage   varchar2(1024); -- ���̳���
  v_ErrText varchar2(1024); -- Oracle������Ϣ

  v_EntGid varchar2(32); --��ҵGid

  v_Title   varchar2(64); --����
  v_Email   varchar(1024); --�ʼ�
  v_Content varchar2(32500); --����

  v_Head   varchar(64); --��ͷ
  v_Body   varchar(2048); --������
  v_TStart varchar(32);
  v_TEnd   varchar(32);
  v_Foot   varchar(64); --��β
  v_Count       int;
  v_CeoName   varchar(64); --CEO

begin
  -- ��ȡ��ҵGid
  v_EntGid  := getEntGid;
  v_Head    := '<table border="0" style="width:500px;"><tr><td>���� :</td></tr>';
  v_TStart  := '<tr><td>';
  v_TEnd    := '��</td></tr>';
  v_Foot    := '<tr><td>-----------����չʾ���-----------</td></tr></table>';
  v_Email   := '';
  v_Content := '';
  
  select count(*)
    into v_Count
    from wf_task t
   where t.EntGid = v_EntGid
     and t.FlowGid = p_FlowGid
     and t.Stat = 1
     and lower(t.code) like '%_tc1%';

  if v_Count > 0 then
    select t.Note
      into v_CeoName
      from wf_task t
     where t.EntGid = v_EntGid
       and t.FlowGid = p_FlowGid
       and t.Stat = 1
       and lower(t.code) like '%_tc1%';
  end if;

  --for ѭ�� ȡ��δ��ȡ�Ŀ��
  for R in (select f.*, wm.name ModelName
              from wf_PrlYL_Stamp f, wf_model wm
             where f.EntGid = v_EntGid
               and f.entgid = wm.entgid
               and f.FlowGid = p_FlowGid
               and f.modelgid = wm.modelgid) loop
    v_Stage   := 'FlowGid��' || R.Flowgid || '��ģ�ͣ�' || R.ModelName;
    v_Title   := '��ӡ��������:' || R.FILLDEPTNAME;
    v_Content := v_Content || v_Head;
  
    if v_Count > 0 then
      v_Body    := '<font stylr="color:red">' || v_CeoName || '</font>';
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    end if;

    v_Body    := '[��������] : ' || R.ModelName;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[����] : ' || R.Num;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[������] : ' || R.Fillusrname;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[����ʱ��] : ' || to_char(R.Createdate, 'YYYY.MM.DD HH24:MI');
  
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[�Ƿ��������] : ' || R.mIsFlow || '������' || R.mNum || '��';
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[��������] : ' || R.DeptType;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[��������] : ' || R.ApplyType;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[����ӡ������] : ' || R.StampType;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[��˾����] : ' || R.ComName;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
  
    if R.ApplyType = '�Ǻ�ͬ���ļ���ӡ' then
      v_Body    := '[�ļ����շ�����] : ' || R.FilerName;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[�ļ�����] : ' || R.FileName;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[�ļ�����] : ' || R.FileCount;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[�ļ�Ŀ��] : ' || R.FileAim;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[��������������֤] : �ұ�֤�����ύ�����ڸ��µķǺ�ͬ���ļ��뱾������ע������һ��';
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    end if;
    if R.ApplyType = '��ͬǩ����ӡ' then
      v_Body    := '[��ͬ����] : ' || R.ContractName;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[��ͬ����] : ' || R.ContractCount;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[��ͬ���/�����] : ' || R.ContractFee;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[������˾] : ' || R.ContactName;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[��ͬ����] : ' || to_char(R.ContractDate1, 'YYYY.MM.DD') || '~' ||
                   to_char(R.ContractDate2, 'YYYY.MM.DD');
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
      v_Body    := '[��ͬ��Ҫ] : ' || R.ComtractMemo;
      v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    end if;
    v_Body    := '[��ע] : ' || R.Memo;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Content := v_Content || v_Foot;
    for U in (select hr.Email
                from hr_emp hr
               where hr.entgid = R.EntGid
                 and exists (select 1
                        from wf_task t
                       where t.EntGid = hr.EntGid
                         and t.FlowGid = R.Flowgid
                         and t.ExecGid = hr.UsrGid
                         and t.Stat = 1)) loop
      v_Email := U.EMAIL || ',';
    end loop;
    if v_Email is not null then
      HDNet_SendMail(v_Title, v_Email, v_Content);
    end if;
  end loop;
  --ɾ��
  update wf_task t
     set t.stat = 4
   where t.EntGid = v_EntGid
     and t.FlowGid = p_FlowGid
     and t.Stat = 1
     and lower(t.code) like '%_tc1%';
  commit;
  --�쳣����
exception
  when others then
    begin
      v_ErrText := substr(v_Stage || ' ʧ��!' || SQLCode || ':' || SQLERRM,
                          1,
                          1024);
      --������־
      insert into Log
        (EntGid,
         EntCode,
         EntName,
         UsrGid,
         UsrCode,
         UsrName,
         CreateDate,
         Atype,
         AContent)
        select e.gid,
               e.code,
               e.name,
               'sys',
               'sys',
               'ϵͳ�Զ�',
               sysdate,
               30,
               v_ErrText
          from ent e
         where e.gid = v_EntGid;
      commit;
    end;
end;
/