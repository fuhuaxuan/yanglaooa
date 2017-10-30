create or replace function F_PrlYL_getApp(p_EntGid   varchar2, --��ҵGid
                                          p_ModelGid varchar2, --ģ��Gid
                                          p_UsrGid   varchar2, --�û�Gid
                                          p_ComGid   varchar2, --��˾
                                          p_AcgCode  varchar2 --��Ŀ����
                                          ) return varchar2 is
  v_Stage   varchar2(1024); -- ���̳���
  v_ErrText varchar2(1024); -- Oracle������Ϣ

  v_ModelCode   varchar2(32); --ģ�ʹ���
  v_DeptGid     varchar2(32); --��ǰ�û�����
  v_PreDeptCode varchar2(32); --�������Ŵ���

  v_AppGid varchar2(32); --��������¼ÿ��Сʱ��
begin
  v_Stage := 'ȡ��������Ϣ';

  select d.Gid, substr(d.Code2, 0, 4)
    into v_DeptGid, v_PreDeptCode
    from hr_emp hr, dept d
   where hr.EntGid = p_EntGid
     and hr.EntGid = d.EntGid
     and hr.DeptGid = d.gid
     and hr.UsrGid = p_UsrGid;

  v_Stage := 'ȡ��ģ����Ϣ';
  select m.code
    into v_ModelCode
    from wf_model m
   where m.Entgid = p_EntGid
     and m.modelgid = p_ModelGid;
  select AppGid
    into v_AppGid
    from (select *
            from (select max(t.AppType) AppType, t.AppGid
                    from (select v.PostGid  AppGid,
                                 v.PostCode AppCode,
                                 v.PostName AppName,
                                 10         AppOrder,
                                 10         AppType
                            from v_Post v
                           where v.EntGid = p_EntGid
                             and v.deptGid = v_DeptGid
                             and v.atype = 10
                             and rownum = 1
                             and p_AcgCode <> '12.01'
                          union
                          select v.PostGid  AppGid,
                                 v.PostCode AppCode,
                                 v.PostName AppName,
                                 20         AppOrder,
                                 20         AppType
                            from v_Post v
                           where v.EntGid = p_EntGid
                             and v.deptGid = v_DeptGid
                             and v.atype = 20
                             and rownum = 1
                             and p_AcgCode = '12.01'
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
                          select v.PostGid  AppGid,
                                 v.PostCode AppCode,
                                 v.PostName AppName,
                                 40         AppOrder,
                                 40         AppType
                            from v_Post v
                           where v.EntGid = p_EntGid
                             and v.deptGid = v_DeptGid
                             and v.atype = 40
                             and rownum = 1
                          union
                          select o.AppGid,
                                 o.AppCode,
                                 o.AppName,
                                 50        AppOrder,
                                 50        AppType
                            from v_wf_model_usr_app o
                           where o.EntGid = p_EntGid
                             and o.ModelGid = p_ModelGid
                             and replace(lower(o.Modelcode),
                                         lower(v_ModelCode),
                                         '') in ('_th3')
                             and rownum = 1
                          union
                          select o.AppGid,
                                 o.AppCode,
                                 o.AppName,
                                 60        AppOrder,
                                 60        AppType
                            from v_wf_model_usr_app o
                           where o.EntGid = p_EntGid
                             and o.ModelGid = p_ModelGid
                             and replace(lower(o.Modelcode),
                                         lower(v_ModelCode),
                                         '') in ('_th4')
                             and rownum = 1) t
                   group by t.AppGid) a
           order by a.AppType)
   where rownum = 1;

  --���ؼ�����
  return v_AppGid;
  --�쳣����
exception
  when others then
    begin
      rollback;
      v_ErrText := substr('ģ��Gid:' || p_ModelGid || ';�û�Gid:' || p_UsrGid || ';' ||
                          v_Stage || ' ʧ��!' || SQLCode || ':' || SQLERRM,
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
         where e.gid = p_EntGid;
      commit;
    end;
end;
/
