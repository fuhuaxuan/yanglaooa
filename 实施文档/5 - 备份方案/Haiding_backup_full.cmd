@echo off

e:
cd \backup\script

writefile file=temp1.cmd content="set backup_param1=full##now##" dateformat="YYYY-MM-DD" append=false
call temp1.cmd
del temp1.cmd

e:
md \backup\%backup_param1%
cd \backup\%backup_param1%

rem ���ݿ�
exp $$���ݿ��û���$$/$$���ݿ�����$$@$$���ݿ������$$ file=Haiding_%backup_param1%_DB.dat full=y log=Haiding_%backup_param1%_DB_ExpLog.txt
type *.txt >> Haiding_%backup_param1%_Backuplog.log
del *.txt /q >> Haiding_%backup_param1%_Backuplog.log
rar a -r Haiding_%backup_param1%_DB.rar *.dat >> Haiding_%backup_param1%_Backuplog.log
del *.dat /q >> Haiding_%backup_param1%_Backuplog.log

rem WEB�ļ�
rar a -r -v100000k Haiding_%backup_param1%_Web.rar  $$WEBĿ¼�����ַ$$\*.* >> Haiding_%backup_param1%_Backuplog.log


set backup_param1=
