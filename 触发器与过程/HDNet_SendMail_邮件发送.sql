create or replace procedure HDNet_SendMail(pi_Title   in varchar2, --邮件标题
                                           pi_Email   in varchar2, --发送email，多个email用“,”分开
                                           pi_Content in varchar2 --发送内容
                                           ) is
  req  utl_http.req; --发送对象
  resp utl_http.resp; --接收对象

  v_Stage       varchar2(1024); --场景
  v_EntCode     varchar2(32);
  v_Url         varchar2(2000); --邮箱地址
  v_PostData    varchar2(32500); --POST提交的内容
  v_MailContent varchar2(32500); --经过内容替换后的发送邮箱内容
  v_fAddr       varchar2(32); --发件人地址
  v_fName       varchar2(32); --发件人名称
  v_RplEmail    varchar2(32); --回复地址
  v_isHTML      varchar2(32); --采用HTML
  v_Value       varchar2(2000); --返回信息的行内容
  v_Content     varchar2(2048); --返回信息的全部内容

begin

  --初始化邮箱网站参数
  v_Stage    := '初始化邮箱网站参数';
  v_Url      := 'http://61.172.235.58:81/bin/hdmailsend.dll/send?';
  v_EntCode  := getentcode;
  v_fAddr    := 'pcrtoa@hd123.net';
  v_fName    := 'OA系统邮件提醒';
  v_RplEmail := 'pcrtoa@hd123.net';
  v_isHTML   := 'y';
  --构造HTTP邮箱请求的POST内容
  v_Stage       := '构造HTTP邮箱请求的POST内容';
  v_MailContent := pi_Content;
  if v_isHTML = 'Y' then
    v_MailContent := replace(v_MailContent, '*', ';');
    v_MailContent := replace(v_MailContent, '^', ';');
  end if;

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

  v_MailContent := replace(v_MailContent, chr(10), '%0A');
  v_MailContent := replace(v_MailContent, chr(13), '%0D');

  v_PostData := 'Title=' || pi_Title || '&' || 'Email=' || pi_Email || '&' ||
                'fAddr=' || v_fAddr || '&' || 'fName=' || v_fName || '&' ||
                'RplEmail=' || v_RplEmail || '&' || 'isHTML=' || v_isHTML || '&' ||
                'Content=' || v_MailContent;
  --将中文转成中文编码
  --v_PostData := utl_url.escape(pi_Content, true, 'gb2312');

  --设置发送HTTP邮箱请求的头文件
  v_Stage := '设置发送HTTP邮箱请求的头文件';
  --req  := utl_http.begin_request(v_Url, 'POST', 'HTTP/1.1');
  --req  := utl_http.begin_request(v_Url || v_PostData);
  req := utl_http.begin_request(v_Url, 'POST', 'HTTP/1.1');
  utl_http.Set_Header(req, 'Content-Type', 'text/xml; charset=gb2312');

  --POST发送邮箱的信息
  v_Stage := 'POST发送邮箱的信息';
  utl_http.set_header(req, 'Content-Length', lengthb(v_PostData));
  Utl_http.write_text(req, v_PostData);

  --得到返回http响应对象
  v_Stage := '得到返回http响应对象';
  resp    := utl_http.get_response(req);

  --得到返回http响应对象内容信息
  v_Stage := '得到返回http响应对象内容信息';
  loop
    utl_http.read_line(resp, v_Value, TRUE);
    v_Content := v_Content || v_Value;
  END loop;

  --结束返回对象
  v_Stage := '结束返回对象';
  utl_http.end_response(resp);

  --出错控制
exception
  when utl_http.end_of_body then
    utl_http.end_response(resp);
  when others then
    v_Content := v_Stage || '错误';
end HDNet_SendMail;
/