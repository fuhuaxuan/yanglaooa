create or replace procedure P_PrlYL_Pay_doApp(p_EntGid    varchar2, --企业Gid
                                              p_ModelGid  varchar, --模型Gid
                                              p_FlowGid   varchar, --流程Gid
                                              p_AppAssign varchar2 --意见
                                              ) as
  v_Stage   varchar2(1024); -- 过程场景
  v_ErrText varchar2(1024); -- Oracle错误信息

  v_UsrGid    varchar2(32); --用户Gid
  v_ModelCode varchar2(32); --模型代码
  v_DeptGid   varchar2(32); --当前用户部门
  v_AcgTwoGid varchar2(32); --所属部门代码
  v_DeptCode  varchar2(32); --所属部门代码
  v_ComGid    varchar2(32); --公司
  v_Fee       number(20, 2); --付款金额

  v_Is12 Int; --是否资本性支出 12.01 13.01
  v_Is11 Int; --是否税金 11.01 12.02 3.01
  v_Is5  Int; --是否维保 5.01-5.05
  v_Is4  Int; --是否工资 4.01-4.03

  v_IsA Int; --是否 2,6,9,16
  v_IsB Int; --是否 9.05
  v_IsC Int; --是否 3,4.04,5,10,15

  v_Is60 Int; --是否60
begin
  commit;
  v_Is60  := 0;
  v_Stage := '取出流程信息';
  select f.FillUsrGid,
         f.fillusrdeptgid,
         f.AcgTwoGid,
         f.companygid,
         f.PayFee,
         substr(f.FillusrDeptCode, 0, 4)
    into v_UsrGid, v_DeptGid, v_AcgTwoGid, v_ComGid, v_Fee, v_DeptCode
    from wf_PrlYL_Pay f
   where f.entgid = p_EntGid
     and f.flowgid = p_FlowGid;

  select count(*)
    into v_Is12
    from prl_acg
   where EntGid = p_EntGid
     and gid = v_AcgTwoGid
     and code in ('12.01', '12.02', '13.01');

  select count(*)
    into v_Is11
    from prl_acg
   where EntGid = p_EntGid
     and gid = v_AcgTwoGid
     and code in ('3.01', '11.01', '11.02');

  select count(*)
    into v_Is5
    from prl_acg
   where EntGid = p_EntGid
     and gid = v_AcgTwoGid
     and code in ('5.01', '5.02', '5.03', '5.04', '5.05');

  select count(*)
    into v_Is4
    from prl_acg
   where EntGid = p_EntGid
     and gid = v_AcgTwoGid
     and code in ('4.01', '4.02', '4.03', '4.04');

  select count(*)
    into v_IsA
    from prl_acg
   where EntGid = p_EntGid
     and gid = v_AcgTwoGid
     and code in ('1.01',
                  '1.02',
                  '2.01',
                  '2.02',
                  '2.03',
                  '2.04',
                  '2.05',
                  '2.06',
                  '2.07',
                  '2.08',
                  '6.01',
                  '9.01',
                  '9.02',
                  '9.03',
                  '9.04',
                  '9.06',
                  '9.07',
                  '9.08',
                  '16.01',
                  '16.02');

  select count(*)
    into v_IsB
    from prl_acg
   where EntGid = p_EntGid
     and gid = v_AcgTwoGid
     and code in ('9.05');

  select count(*)
    into v_IsC
    from prl_acg
   where EntGid = p_EntGid
     and gid = v_AcgTwoGid
     and code in ('3.01',
                  '4.04',
                  '5.01',
                  '5.02',
                  '5.03',
                  '5.04',
                  '5.05',
                  '10.01',
                  '11.01',
                  '11.02',
                  '15.01',
                  '15.02');

  v_Stage := '判断是否需要财务总监审批';
  if v_Is12 > 0 and v_Fee > 20000 then
    v_Is60 := 1;
  elsif v_IsA > 0 and v_Fee > 2000 then
    v_Is60 := 1;
  elsif v_IsB > 0 and v_Fee > 1000 then
    v_Is60 := 1;
  elsif v_IsC > 0 then
    v_Is60 := 1;
  else
    v_Is60 := 0;
  end if;

  v_Stage := '取出模型信息';
  select m.code
    into v_ModelCode
    from wf_model m
   where m.Entgid = p_EntGid
     and m.modelgid = p_ModelGid;

  if p_AppAssign <> '终止' then

    delete from wf_PrlYL_Pay_App f
     where f.EntGid = p_EntGid
       and f.FlowGid = p_FlowGid
       and f.Appdate is null;

    --插入审批人
    insert into wf_PrlYL_Pay_App
      (EntGid,
       FlowGid,
       dtlGid,
       AppGid,
       AppCode,
       AppName,
       AppOrder,
       AppType)
      select p_EntGid,
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
                     5          AppOrder,
                     5          AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 30
                 and rownum = 1
                 and v_Is4 > 0
              union
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     10         AppOrder,
                     10         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 10
                 and rownum = 1
              union
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     15         AppOrder,
                     15         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 15
                 and rownum = 1
              union
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     20         AppOrder,
                     20         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_ComGid
                 and v.atype = 20
                 and rownum = 1
              union
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     25         AppOrder,
                     25         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 25
                 and rownum = 1
                 and exists (select 1
                        from prl_acg
                       where EntGid = p_EntGid
                         and gid = v_AcgTwoGid
                         and code in ('14.01'))
              union
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     30         AppOrder,
                     30         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_ComGid
                 and v.atype = 30
                 and rownum = 1
              union
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     32         AppOrder,
                     32         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 32
                 and v_Is4 > 0
                 and rownum = 1
              union
              select o.AppGid, o.AppCode, o.AppName, 33 AppOrder, 33 AppType
                from v_wf_model_usr_app o
               where o.EntGid = p_EntGid
                 and o.ModelGid = p_ModelGid
                 and replace(lower(o.Modelcode), lower(v_ModelCode), '') in
                     ('_th5')
                 and v_DeptCode not in ('0016', '0035')
                 and rownum = 1
              union
              --运营副总，非 12.01,非 13.01 
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     34         AppOrder,
                     34         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 34
                 and (((v_Is12 = 0 or v_Is11 = 0) and
                     v_DeptCode not in ('0016', '0035')) or
                     (v_Is12 = 0 and v_DeptCode in ('0016', '0035')))
                 and rownum = 1
              union
              --集团人事副总，4.01-4.03
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     35         AppOrder,
                     35         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 35
                 and v_Is4 > 0
                 and rownum = 1
              union
              --集团工程副总，12.01,13.01,5.01-5.05
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     40         AppOrder,
                     40         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 40
                 and (v_Is12 > 0 or v_Is5 > 0)
                 and rownum = 1
              union
              --集团财务总监
              --1、固定资产、无形资产采购资本性支出，工程改造资本性支出 12.01 13.01 并且 > 20000
              --2、成本、耗材，行政费用（除业务招待费），营销费用，备用金 1.01,1.02,2.01-2.08,6.01,9.01-9.08,16.01 > 2000
              --3、业务招待费 9.05 > 1000
              --4、重大支出（对外股权投资、出借资金、捐赠或赞助等），往来调拨款，财务费用、利息支出，税金支出，非日常的工资福利性支出，维修维保费用，总部管理费 3.01,4.04,5.01-5.05,10.01,11.01-11.02,15.01-15.02
              --5、其他都不到
              select o.AppGid, o.AppCode, o.AppName, 60 AppOrder, 60 AppType
                from v_wf_model_usr_app o
               where o.EntGid = p_EntGid
                 and o.ModelGid = p_ModelGid
                 and replace(lower(o.Modelcode), lower(v_ModelCode), '') in
                     ('_th6')
                 and v_DeptCode not in ('0016')
                 and v_Is60 = 1
                 and rownum = 1
              union
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     60         AppOrder,
                     60         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 60
                 and v_DeptCode in ('0016')
                 and rownum = 1
              union
              select o.AppGid, o.AppCode, o.AppName, 70 AppOrder, 70 AppType
                from v_wf_model_usr_app o
               where o.EntGid = p_EntGid
                 and o.ModelGid = p_ModelGid
                 and replace(lower(o.Modelcode), lower(v_ModelCode), '') in
                     ('_th7')
                 and ((v_Is60 = 1 and v_DeptCode not in ('0016', '0035')) or
                     (v_DeptCode in ('0016', '0035')))
                 and rownum = 1
              union
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     73         AppOrder,
                     73         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 75
                 and v_Fee >= 500000
                 and exists (select 1
                        from prl_acg
                       where EntGid = p_EntGid
                         and gid = v_AcgTwoGid
                         and code in ('12.01','12.02'))
                 and rownum = 1
              union
              select v.PostGid  AppGid,
                     v.PostCode AppCode,
                     v.PostName AppName,
                     73         AppOrder,
                     73         AppType
                from v_Post v
               where v.EntGid = p_EntGid
                 and v.deptGid = v_DeptGid
                 and v.atype = 75
                 and v_Fee >= 50000
                 and not exists (select 1
                        from prl_acg
                       where EntGid = p_EntGid
                         and gid = v_AcgTwoGid
                         and code in ('12.01','12.02'))
                 and rownum = 1) t;
  
    commit;
    --取出审批人中重复的审批人
    delete from wf_PrlYL_Pay_App f
     where f.EntGid = p_EntGid
       and f.FlowGid = p_FlowGid
       and f.Apporder > 0
       and f.Appdate is null
       and not exists (select 1
              from (select max(t.appType) appType,
                           t.EntGid,
                           t.FlowGid,
                           t.AppGid
                      from wf_PrlYL_Pay_App t
                     where t.EntGid = p_EntGid
                       and t.FlowGid = p_FlowGid
                       and t.AppOrder < 100
                       and t.AppDate is null
                     group by t.EntGid, t.FlowGid, t.AppGid) a
             where f.EntGid = a.EntGid
               and f.FlowGid = a.FlowGid
               and f.appType = a.appType);
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
                          from wf_PrlYL_Pay_App t
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
