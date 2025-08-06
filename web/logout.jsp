<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    // Xoá session hiện tại
    session.invalidate();

    // Chuyển hướng về trang đăng nhập
    response.sendRedirect("login.jsp");
%>
