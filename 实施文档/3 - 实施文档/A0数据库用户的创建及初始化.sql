
--���½ű���Ҫ�滻
--�滻-��������-"9191",�滻��ȷ���ĺ������롣

--����HDNetӦ���û�
create user 
hdIntra 			--�û���
identified by 
"heading.com" 			--����
default tablespace users temporary tablespace temp;

--��Ȩ�ޣ�Resource,ConnectΪORACLEĬ�Ͻ�ɫ,���Ҳ������û��Ŀռ�
GRANT dba , unlimited tablespace, CREATE ANY TABLE to hdIntra;

--���ӵ��´��������ݿ��û�
CONNECT hdIntra/heading.com@orcl;

--������ҵGID
create or replace function getEntGid return varchar2 is
begin
  return '2000000000000000000000000009260A';
end;
/

--������ҵ����Code
create or replace function getEntCode return varchar2 is
begin
  return '9260A';
end;
/

--������ҵȫ��
create or replace function getEntName return varchar2 is
begin
  return '�������巿�ز��������޹�˾';
end;
/

--������ҵ���
create or replace function getEntSName return varchar2 is
begin
  return '����������֮����̫����';
end;
/

--��վ�û�����-��ҵ����
create or replace function getHDNetCode return varchar2 is
begin
  return 'prlintra';
end;
/

--��ʼ���û�����һ���û������Ǻ�ͬ���û������ټ���2����Ϊ�����ڲ�������Ա��heading�û���ռ����2��������
create or replace function getUsrCount return varchar2 is
begin
  return '0';
end;
/

--��վ·��
create or replace function getHDNetPath return varchar2 is
begin
  return 'd:\hdnet\';
end;
/


--ȫ���û���Gid
create or replace function getGid3 return varchar2 is
begin
  return 'ALL_USR_GRP';
end;
/

--��ҵ������Gid
create or replace function getGid4 return varchar2 is
begin
  return 'DEPT';
end;
/

--����Ԥ��
create or replace function getWeatherUrl return varchar2 is
begin
  return 'http://m.weather.com.cn/m/pn6/weather.htm';
end;
/
