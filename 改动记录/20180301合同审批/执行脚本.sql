--工作流程执行脚本模板：201403版（此行不允许删除）
--1、定义流程用到的参数名称
declare
  v_EntGid varchar2(32);         --企业Gid
  v_ModelGid varchar2(32);       --工作流程模型Gid
  v_ModelCode varchar2(32);      --工作流程模型代码
  v_TaskGid varchar2(32);
  v_TaskGid_T1 varchar2(32);     --开始步骤
  v_TaskGid_T2 varchar2(32);
  v_TaskGid_Tcc varchar2(32);
  v_TaskGid_Tend varchar2(32);   --结束步骤
  v_Count int;
BEGIN
--2、初始化赋值
  v_TaskGid := sys_guid();
  v_TaskGid_T1 := sys_guid();
  v_TaskGid_T2 := sys_guid();
  v_TaskGid_Tcc := sys_guid();
  v_TaskGid_Tend := sys_guid();

  --获取企业Gid
  select Gid into v_EntGid from Ent where Lower(code) = lower('prlintra');--修改企业Code

  --定义模型代码
  v_ModelCode := 'PrlYL_Contract';

  --取出当前模型代码对应模型的数量
  select count(*) into v_Count from wf_model where lower(Code) = lower(v_ModelCode) and EntGid = v_EntGid;
  
  --获取模型Gid
  if v_Count = 0 then
    v_ModelGid := sys_guid();
  else
    select ModelGid into v_ModelGid from wf_model where lower(Code) = lower(v_ModelCode) and EntGid = v_EntGid;
  end if;

--3、删除旧有数据信息
  delete from WF_Model where EntGid = v_EntGid and ModelGid = v_ModelGid;
  delete from WF_Task_Define where EntGid = v_EntGid and ModelGid = v_ModelGid;
  delete from WF_Task_Define_Exec where EntGid = v_EntGid and ModelGid = v_ModelGid;
  delete from WF_Task_Define_Condition where EntGid = v_EntGid and ModelGid = v_ModelGid;
  delete from WF_rt where EntGid = v_EntGid and ModelGid = v_ModelGid;
  --delete from WF_Flow where EntGid = v_EntGid and ModelGid = v_ModelGid;
  --delete from WF_Task where EntGid = v_EntGid and ModelGid = v_ModelGid;
  --delete from WF_Task_History where EntGid = v_EntGid and ModelGid = v_ModelGid;

--4、定义工作流程名称 ，步骤等
  insert into WF_Model(EntGid, ModelGid, Code, Name, STAT, CLASSIFY, VERSION, AP1, AP2)
  select v_EntGid, v_ModelGid, v_ModelCode, '合同审批流程', 3, '人寿堂', '1.0', 0, 0 from dual;

  /*
  insert into WF_Task_Define(EntGid, ModelGid, TaskDefGid, Code, Name, Note, OrderValue, IsStart, IsEnd, IsMCF)
  select v_EntGid, v_ModelGid, v_TaskGid, v_ModelCode, '明细', '用于判断查看权限', 1, 0, 0, 0 from dual;
  */

  insert into WF_Task_Define(EntGid, ModelGid, TaskDefGid, Code, Name, Note, OrderValue, IsStart, IsEnd, IsMCF)
  select v_EntGid, v_ModelGid, v_TaskGid_T1, v_ModelCode || '_T1', '填写采购单', '填写', 1, 1, 0, 0 from dual;

  insert into WF_Task_Define(EntGid, ModelGid, TaskDefGid, Code, Name, Note, OrderValue, IsStart, IsEnd, IsMCF)
  select v_EntGid, v_ModelGid, v_TaskGid_T2, v_ModelCode || '_T2', '请审批','审批', 1, 0, 0, 0 from dual;

  insert into WF_Task_Define(EntGid, ModelGid, TaskDefGid, Code, Name, Note, OrderValue, IsStart, IsEnd, IsMCF)
  select v_EntGid, v_ModelGid, v_TaskGid_Tcc, v_ModelCode||'_Tcc', '抄送人阅读', '抄送', 1, 0, 0, 1 from dual;

  insert into WF_Task_Define(EntGid, ModelGid, TaskDefGid, Code, Name, Note, OrderValue, IsStart, IsEnd, IsMCF)
  select v_EntGid, v_ModelGid, v_TaskGid_Tend, v_ModelCode || '_Tend', '流程终止', '结束一个流程', 1, 0, 1, 0 from dual;

--5、定义工作流程步骤执行人

  
  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid, '**FlowMember**', '**FlowMember**', '@流程参与人@', 1 from dual;

  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid, Gid, Code, Name, 1 from v_Usr where EntGid = v_EntGid and lower(Code) = lower('Admin_Grp');

  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid_T1, Gid, Code, Name, 1 from v_Usr where EntGid = v_EntGid and lower(Code) = lower('all_usr_grp');

  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid_T1, '**SpecGid**', '**SpecCode**', '@流程中指定@', 1 from dual;

  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid_T2, '**SpecGid**', '**SpecCode**', '@流程中指定@', 1 from dual;

  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid_Tcc, '**SpecGid**', '**SpecCode**', '@流程中指定@', 1 from dual;

--6、定义工作流程步骤走向

  insert into WF_Task_Define_Condition(EntGid, ModelGid, FromTaskDef, ToTaskDef)
  select v_EntGid, v_ModelGid, v_TaskGid_T1, v_TaskGid_T2 from dual;

  insert into WF_Task_Define_Condition(EntGid, ModelGid, FromTaskDef, ToTaskDef)
  select v_EntGid, v_ModelGid, v_TaskGid_T1, v_TaskGid_Tend from dual;

  insert into WF_Task_Define_Condition(EntGid, ModelGid, FromTaskDef, ToTaskDef)
  select v_EntGid, v_ModelGid, v_TaskGid_T2, v_TaskGid_T1 from dual;

  insert into WF_Task_Define_Condition(EntGid, ModelGid, FromTaskDef, ToTaskDef)
  select v_EntGid, v_ModelGid, v_TaskGid_T2, v_TaskGid_Tcc from dual;

  insert into WF_Task_Define_Condition(EntGid, ModelGid, FromTaskDef, ToTaskDef)
  select v_EntGid, v_ModelGid, v_TaskGid_T2, v_TaskGid_Tend from dual;

--7、为管理员以及相关人员设置权限
--监视权限  　　 作废权限  　　 变更权限  　　 模型设置权限  
  insert into wf_rt (EntGid, ModelGid, UsrGidEX, RTID)
  select v_EntGid, v_ModelGid, gid, '1111' from org where EntGid = v_EntGid and lower(code) = lower('Admin_Grp');

end;
/

commit;
--工作流程执行脚本模板：201403版（此行不允许删除）
--1、定义流程用到的参数名称
declare
  v_EntGid varchar2(32);         --企业Gid
  v_ModelGid varchar2(32);       --工作流程模型Gid
  v_ModelCode varchar2(32);      --工作流程模型代码
  v_TaskGid varchar2(32);
  v_TaskGid_T1 varchar2(32);     --开始步骤
  v_TaskGid_T2 varchar2(32);
  v_TaskGid_Tcc varchar2(32);
  v_TaskGid_Tend varchar2(32);   --结束步骤
  v_Count int;
BEGIN
--2、初始化赋值
  v_TaskGid := sys_guid();
  v_TaskGid_T1 := sys_guid();
  v_TaskGid_T2 := sys_guid();
  v_TaskGid_Tcc := sys_guid();
  v_TaskGid_Tend := sys_guid();

  --获取企业Gid
  select Gid into v_EntGid from Ent where Lower(code) = lower('prlintra');--修改企业Code

  --定义模型代码
  v_ModelCode := 'PrlYL_Contract';

  --取出当前模型代码对应模型的数量
  select count(*) into v_Count from wf_model where lower(Code) = lower(v_ModelCode) and EntGid = v_EntGid;
  
  --获取模型Gid
  if v_Count = 0 then
    v_ModelGid := sys_guid();
  else
    select ModelGid into v_ModelGid from wf_model where lower(Code) = lower(v_ModelCode) and EntGid = v_EntGid;
  end if;

--3、删除旧有数据信息
  delete from WF_Model where EntGid = v_EntGid and ModelGid = v_ModelGid;
  delete from WF_Task_Define where EntGid = v_EntGid and ModelGid = v_ModelGid;
  delete from WF_Task_Define_Exec where EntGid = v_EntGid and ModelGid = v_ModelGid;
  delete from WF_Task_Define_Condition where EntGid = v_EntGid and ModelGid = v_ModelGid;
  delete from WF_rt where EntGid = v_EntGid and ModelGid = v_ModelGid;
  --delete from WF_Flow where EntGid = v_EntGid and ModelGid = v_ModelGid;
  --delete from WF_Task where EntGid = v_EntGid and ModelGid = v_ModelGid;
  --delete from WF_Task_History where EntGid = v_EntGid and ModelGid = v_ModelGid;

--4、定义工作流程名称 ，步骤等
  insert into WF_Model(EntGid, ModelGid, Code, Name, STAT, CLASSIFY, VERSION, AP1, AP2)
  select v_EntGid, v_ModelGid, v_ModelCode, '合同审批流程', 3, '人寿堂', '1.0', 0, 0 from dual;

  /*
  insert into WF_Task_Define(EntGid, ModelGid, TaskDefGid, Code, Name, Note, OrderValue, IsStart, IsEnd, IsMCF)
  select v_EntGid, v_ModelGid, v_TaskGid, v_ModelCode, '明细', '用于判断查看权限', 1, 0, 0, 0 from dual;
  */

  insert into WF_Task_Define(EntGid, ModelGid, TaskDefGid, Code, Name, Note, OrderValue, IsStart, IsEnd, IsMCF)
  select v_EntGid, v_ModelGid, v_TaskGid_T1, v_ModelCode || '_T1', '填写采购单', '填写', 1, 1, 0, 0 from dual;

  insert into WF_Task_Define(EntGid, ModelGid, TaskDefGid, Code, Name, Note, OrderValue, IsStart, IsEnd, IsMCF)
  select v_EntGid, v_ModelGid, v_TaskGid_T2, v_ModelCode || '_T2', '请审批','审批', 1, 0, 0, 0 from dual;

  insert into WF_Task_Define(EntGid, ModelGid, TaskDefGid, Code, Name, Note, OrderValue, IsStart, IsEnd, IsMCF)
  select v_EntGid, v_ModelGid, v_TaskGid_Tcc, v_ModelCode||'_Tcc', '抄送人阅读', '抄送', 1, 0, 0, 1 from dual;

  insert into WF_Task_Define(EntGid, ModelGid, TaskDefGid, Code, Name, Note, OrderValue, IsStart, IsEnd, IsMCF)
  select v_EntGid, v_ModelGid, v_TaskGid_Tend, v_ModelCode || '_Tend', '流程终止', '结束一个流程', 1, 0, 1, 0 from dual;

--5、定义工作流程步骤执行人

  
  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid, '**FlowMember**', '**FlowMember**', '@流程参与人@', 1 from dual;

  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid, Gid, Code, Name, 1 from v_Usr where EntGid = v_EntGid and lower(Code) = lower('Admin_Grp');

  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid_T1, Gid, Code, Name, 1 from v_Usr where EntGid = v_EntGid and lower(Code) = lower('all_usr_grp');

  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid_T1, '**SpecGid**', '**SpecCode**', '@流程中指定@', 1 from dual;

  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid_T2, '**SpecGid**', '**SpecCode**', '@流程中指定@', 1 from dual;

  insert into WF_Task_Define_Exec(EntGid, ModelGid, TaskDefGid, ExecGidEx, ExecCodeEx, ExecNameEx, OwnerValue)
  select v_EntGid, v_ModelGid, v_TaskGid_Tcc, '**SpecGid**', '**SpecCode**', '@流程中指定@', 1 from dual;

--6、定义工作流程步骤走向

  insert into WF_Task_Define_Condition(EntGid, ModelGid, FromTaskDef, ToTaskDef)
  select v_EntGid, v_ModelGid, v_TaskGid_T1, v_TaskGid_T2 from dual;

  insert into WF_Task_Define_Condition(EntGid, ModelGid, FromTaskDef, ToTaskDef)
  select v_EntGid, v_ModelGid, v_TaskGid_T1, v_TaskGid_Tend from dual;

  insert into WF_Task_Define_Condition(EntGid, ModelGid, FromTaskDef, ToTaskDef)
  select v_EntGid, v_ModelGid, v_TaskGid_T2, v_TaskGid_T1 from dual;

  insert into WF_Task_Define_Condition(EntGid, ModelGid, FromTaskDef, ToTaskDef)
  select v_EntGid, v_ModelGid, v_TaskGid_T2, v_TaskGid_Tcc from dual;

  insert into WF_Task_Define_Condition(EntGid, ModelGid, FromTaskDef, ToTaskDef)
  select v_EntGid, v_ModelGid, v_TaskGid_T2, v_TaskGid_Tend from dual;

--7、为管理员以及相关人员设置权限
--监视权限  　　 作废权限  　　 变更权限  　　 模型设置权限  
  insert into wf_rt (EntGid, ModelGid, UsrGidEX, RTID)
  select v_EntGid, v_ModelGid, gid, '1111' from org where EntGid = v_EntGid and lower(code) = lower('Admin_Grp');

end;
/

commit;
create or replace procedure P_PrlYL_Contract_doApp(p_EntGid    varchar2, --企业Gid
                                                   p_ModelGid  varchar, --模型Gid
                                                   p_FlowGid   varchar, --流程Gid
                                                   p_AppAssign varchar2 --意见
                                                   ) as
  v_Stage   varchar2(1024); -- 过程场景
  v_ErrText varchar2(1024); -- Oracle错误信息

  v_UsrGid    varchar2(32); --用户Gid
  v_ModelCode varchar2(32); --模型代码
  v_DeptGid   varchar2(32); --当前用户部门
begin
  commit;
  v_Stage := '取出流程信息';
  select f.FillUsrGid, f.FillDeptGid
    into v_UsrGid, v_DeptGid
    from wf_PrlYL_Contract f
   where f.entgid = p_EntGid
     and f.flowgid = p_FlowGid;

  v_Stage := '取出模型信息';
  select m.code
    into v_ModelCode
    from wf_model m
   where m.Entgid = p_EntGid
     and m.modelgid = p_ModelGid;

  if p_AppAssign <> '终止' then
    --插入审批人
    insert into wf_PrlYL_Contract_App
      (EntGid,
       ModelGid,
       FlowGid,
       Gid,
       AppGid,
       AppCode,
       AppName,
       AppOrder,
       AppType)
      select p_EntGid,
             p_ModelGid,
             p_FlowGid,
             sys_guid(),
             t.AppGid,
             t.AppCode,
             t.AppName,
             t.AppOrder,
             t.AppType
        from (select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     10         AppOrder,
                     10         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 5
                 and rownum = 1
              union
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     20         AppOrder,
                     20         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 10
                 and rownum = 1
              union
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     30         AppOrder,
                     30         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 30
                 and rownum = 1
              union
              select o.AppGid, o.AppCode, o.AppName, 40 AppOrder, 40 AppType
                from v_wf_model_usr_app o
               where o.EntGid = p_EntGid
                 and o.ModelGid = p_ModelGid
                 and replace(lower(o.Modelcode), lower(v_ModelCode), '') in
                     ('_th4')
                 and rownum = 1) t;
  
    --取出审批人中重复的审批人
    delete from wf_PrlYL_Contract_App f
     where f.EntGid = p_EntGid
       and f.FlowGid = p_FlowGid
       and f.Apporder > 0
       and f.Appdate is null
       and not exists (select 1
              from (select max(t.apporder) apporder,
                           t.EntGid,
                           t.FlowGid,
                           t.AppGid
                      from wf_PrlYL_Contract_App t
                     where t.EntGid = p_EntGid
                       and t.FlowGid = p_FlowGid
                       and t.AppOrder < 100
                       and t.AppDate is null
                     group by t.EntGid, t.FlowGid, t.AppGid) a
             where f.EntGid = a.EntGid
               and f.FlowGid = a.FlowGid
               and f.apporder = a.apporder);
    v_Stage := '插入审批人';
    if p_AppAssign = '提交' then
      insert into WF_Task
        (EntGid,
         ModelGid,
         FlowGid,
         TaskDefGid,
         TaskGid,
         Stat,
         Code,
         Name,
         Note,
         ExecGid,
         ExecCode,
         ExecName,
         OrderValue,
         IsMCF)
        select p_EntGid,
               p_ModelGid,
               p_FlowGid,
               d.TaskDefGid,
               sys_guid(),
               1,
               d.code,
               d.name,
               d.note,
               a.AppGid,
               a.AppCode,
               a.AppName,
               d.OrderValue,
               d.IsMCF
          from WF_Task_Define d,
               (select *
                  from (select *
                          from wf_PrlYL_Contract_App t
                         where t.entgid = p_EntGid
                           and t.flowgid = p_FlowGid
                           and t.AppOrder <= 100
                           and t.AppDate is null
                         order by t.Apporder)
                 where rownum = 1) a
         where d.EntGid = p_EntGid
           and d.ModelGid = p_ModelGid
           and replace(lower(d.code), lower(v_ModelCode), '') in ('_t2')
           and not exists (select 1
                  from wf_task t
                 where t.entgid = p_EntGid
                   and t.flowgid = p_FlowGid
                   and t.TaskDefGid = d.taskdefgid
                   and t.ExecGid = a.AppGid
                   and t.stat = 1);
    end if;
  end if;
  commit;
  --异常处理
exception
  when others then
    begin
      rollback;
      v_ErrText := substr('流程Gid:' || p_FlowGid || ';用户Gid:' || v_UsrGid || ';' ||
                          v_Stage || ' 失败!' || SQLCode || ':' || SQLERRM,
                          1,
                          1024);
      --插入日志
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
               '系统自动',
               sysdate,
               30,
               v_ErrText
          from ent e
         where e.gid = p_EntGid;
      commit;
    end;
end;
/

create or replace procedure P_PrlYL_Contract_doMail(p_FlowGid varchar --流程Gid
                                              ) as
  v_Stage   varchar2(1024); -- 过程场景
  v_ErrText varchar2(1024); -- Oracle错误信息

  v_EntGid varchar2(32); --企业Gid

  v_Title   varchar2(64); --标题
  v_Email   varchar(1024); --邮件
  v_Content varchar2(32500); --内容

  v_Head   varchar(64); --表头
  v_Body   varchar(2048); --表内容
  v_TStart varchar(32);
  v_TEnd   varchar(32);
  v_Foot   varchar(64); --表尾

begin
  -- 获取企业Gid
  v_EntGid  := getEntGid;
  v_Head    := '<table border="0" style="width:500px;"><tr><td>您好 :</td></tr>';
  v_TStart  := '<tr><td>';
  v_TEnd    := '；</td></tr>';
  v_Foot    := '<tr><td>-----------内容展示完毕-----------</td></tr></table>';
  v_Email   := '';
  v_Content := '';
  --for 循环 取出未领取的快递
  for R in (select f.*, wm.name ModelName
              from wf_PrlYL_Contract f, wf_model wm
             where f.EntGid = v_EntGid
               and f.entgid = wm.entgid
               and f.FlowGid = p_FlowGid
               and f.modelgid = wm.modelgid) loop
    v_Stage   := 'FlowGid：' || R.Flowgid || '；模型：' || R.ModelName;
    v_Title   := '采购待审提醒:' || R.Filldeptname;
    v_Content := v_Content || v_Head;
  
    v_Body    := '[流程名称] : ' || R.ModelName;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[单号] : ' || R.Num;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[发起人] : ' || R.Fillusrname;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[发起时间] : ' || to_char(R.Createdate, 'YYYY.MM.DD HH24:MI');
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[标题] : ' || R.ContractName;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[合同名称] :' || R.ContractMatters;
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[合同事宜] : ';
    v_Content := v_Content || v_TStart || v_Body || v_TEnd;
    v_Body    := '[备注] : ' || R.ContractMemo;
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
  --异常处理
exception
  when others then
    begin
      v_ErrText := substr(v_Stage || ' 失败!' || SQLCode || ':' || SQLERRM,
                          1,
                          1024);
      --插入日志
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
               '系统自动',
               sysdate,
               30,
               v_ErrText
          from ent e
         where e.gid = v_EntGid;
      commit;
    end;
end;
/