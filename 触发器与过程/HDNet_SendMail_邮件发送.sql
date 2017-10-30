create or replace procedure HDNet_SendMail (
  pi_EntCode  in varchar2,          --��ҵ��֯����
  pi_Title  in varchar2,       --�ʼ�����
  pi_Email  in varchar2,       --����email�����email�á�,���ֿ�
  pi_Content in varchar2,      --��������
  pi_fAddr  in varchar2,       --�����˵�ַ
  pi_fName  in varchar2,       --����������
  pi_RplEmail  in varchar2,    --�ظ���ַ
  pi_isHTML  in varchar2      --����HTML
  )
  is
    req  utl_http.req;               --���Ͷ���
    resp utl_http.resp;              --���ն���

    v_Stage     varchar2(1024);      --����

    v_Url       varchar2(2000);      --�����ַ
    v_PostData  varchar2(32500);      --POST�ύ������
    v_MailContent       varchar2(32500);      --���������滻��ķ�����������

    v_Value     varchar2(2000);      --������Ϣ��������
    v_Content   varchar2(2048);      --������Ϣ��ȫ������

  begin

    --��ʼ��������վ����
    v_Stage := '��ʼ��������վ����';
    v_Url  := 'http://www.prehoa.net/bin/hdmailsend.dll/send?';

    --����HTTP���������POST����
    v_Stage := '����HTTP���������POST����';
    v_MailContent := pi_Content;
    if pi_isHTML = 'Y' then
      v_MailContent := replace(v_MailContent, '*' , ';');
      v_MailContent := replace(v_MailContent, '^', ';');
    end if ;

    v_MailContent := replace(v_MailContent, '%', '%25');
    v_MailContent := replace(v_MailContent, ' ', '%20');
    v_MailContent := replace(v_MailContent, '!', '%21');
    v_MailContent := replace(v_MailContent, '"', '%22');
    v_MailContent := replace(v_MailContent, '#', '%23');
    v_MailContent := replace(v_MailContent, '$', '%24');
    v_MailContent := replace(v_MailContent, '&', '%26');
    v_MailContent := replace(v_MailContent, '''', '%27');
    --v_MailContent := replace(v_MailContent, '(', '%28');
    --v_MailContent := replace(v_MailContent, ')', '%29');
    --v_MailContent := replace(v_MailContent, '*', '%2A');
    --v_MailContent := replace(v_MailContent, '*', '');
    --v_MailContent := replace(v_MailContent, '+', '%2B');
    --v_MailContent := replace(v_MailContent, ',', '%2C');
    --v_MailContent := replace(v_MailContent, '-', '%2D');
    --v_MailContent := replace(v_MailContent, '.', '%2E');
    --v_MailContent := replace(v_MailContent, '/', '%2F');
    --v_MailContent := replace(v_MailContent, ':', '%3A');
    --v_MailContent := replace(v_MailContent, ';', '%3B');
    --v_MailContent := replace(v_MailContent, '<?', '%3C');
    v_MailContent := replace(v_MailContent, '=', '%3D');
    --v_MailContent := replace(v_MailContent, '>?', '%3E');
    --v_MailContent := replace(v_MailContent, '?', '%3F');
    --v_MailContent := replace(v_MailContent, '@', '%40');
    --v_MailContent := replace(v_MailContent, '[', '%5B');
    --v_MailContent := replace(v_MailContent, '\', '%5C');
    --v_MailContent := replace(v_MailContent, ']', '%5D');
    --v_MailContent := replace(v_MailContent, '^', '%5E');
    --v_MailContent := replace(v_MailContent, '_', '%5F');
    --v_MailContent := replace(v_MailContent, '{', '%7B');
    --v_MailContent := replace(v_MailContent, '|', '%7C');
    --v_MailContent := replace(v_MailContent, '}', '%7D');
    --v_MailContent := replace(v_MailContent, '~', '%7E');

    v_MailContent := replace(v_MailContent, chr(10) , '%0A');
    v_MailContent := replace(v_MailContent, chr(13) , '%0D');


    v_PostData := 'Title=' || pi_Title
      || '&' || 'Email=' || pi_Email
      || '&' || 'fAddr=' || pi_fAddr
      || '&' || 'fName=' || pi_fName
      || '&' || 'RplEmail=' || pi_RplEmail
      || '&' || 'isHTML=' || pi_isHTML
      || '&' || 'Content=' || v_MailContent;
    --������ת�����ı���
    --v_PostData := utl_url.escape(pi_Content, true, 'gb2312');


    --���÷���HTTP���������ͷ�ļ�
    v_Stage := '���÷���HTTP���������ͷ�ļ�';
    --req  := utl_http.begin_request(v_Url, 'POST', 'HTTP/1.1');
    --req  := utl_http.begin_request(v_Url || v_PostData);
    req  := utl_http.begin_request(v_Url, 'POST', 'HTTP/1.1');
    utl_http.Set_Header(req, 'Content-Type', 'text/xml; charset=gb2312');

    --POST�����������Ϣ
    v_Stage := 'POST�����������Ϣ';
    utl_http.set_header(req, 'Content-Length', lengthb(v_PostData));
    Utl_http.write_text(req, v_PostData);

     --�õ�����http��Ӧ����
    v_Stage := '�õ�����http��Ӧ����';
    resp := utl_http.get_response(req);

    --�õ�����http��Ӧ����������Ϣ
    v_Stage := '�õ�����http��Ӧ����������Ϣ';
    loop
      utl_http.read_line(resp, v_Value, TRUE);
      v_Content := v_Content || v_Value;
    END loop;

    --�������ض���
    v_Stage := '�������ض���';
    utl_http.end_response(resp);

    --�������
    exception
      when utl_http.end_of_body then
        utl_http.end_response(resp);
      when others then
        v_Content := v_Stage || '����';
  end HDNet_SendMail;
/