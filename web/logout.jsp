<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%
    // Xoá session hiện tại
    session.invalidate();

    // ✅ Xoá cookie ICSS_USER (logout hoàn toàn)
    Cookie userCookie = new Cookie("ICSS_USER", "");
    userCookie.setMaxAge(0); // Xoá cookie ngay lập tức
    userCookie.setHttpOnly(true);
    userCookie.setPath("/");
    response.addCookie(userCookie);

    // Chuyển hướng về trang đăng nhập
    response.sendRedirect("login.jsp");
%>
