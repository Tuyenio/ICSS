<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*,java.io.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8" />
  <title>HRM - Test JSP (Safe)</title>
  <style>body{font-family:Arial,Helvetica,sans-serif;font-size:14px}pre{background:#f4f4f4;padding:10px;border:1px solid #ddd;}</style>
</head>
<body>
  <h2>HRM Test JSP — Thông tin an toàn</h2>
  <p>Timestamp: <%= new java.util.Date() %></p>
  <p>Remote Addr: <%= request.getRemoteAddr() %></p>
  <p>Remote Host: <%= request.getRemoteHost() %></p>
  <p>Context Path: <%= request.getContextPath() %></p>
  <p>Request URI: <%= request.getRequestURI() %></p>

  <h3>Java System Properties</h3>
  <pre>
<%
    Properties props = System.getProperties();
    for (Enumeration<?> e = props.propertyNames(); e.hasMoreElements();) {
        String k = (String)e.nextElement();
        out.println(k + " = " + props.getProperty(k));
    }
%>
  </pre>

  <h3>Request Headers</h3>
  <pre>
<%
    java.util.Enumeration<String> hnames = request.getHeaderNames();
    while (hnames.hasMoreElements()) {
        String hn = hnames.nextElement();
        out.println(hn + ": " + request.getHeader(hn));
    }
%>
  </pre>

  <p><em>Lưu ý: file này chỉ hiển thị thông tin hệ thống, không thực thi lệnh hệ thống.</em></p>
</body>
</html>