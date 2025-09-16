<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.io.File" %>
<%
    String uploadPath = application.getRealPath("") + File.separator + "uploads";
    File folder = new File(uploadPath);
    File[] files = folder.listFiles();
%>

<form action="downloadSelected" method="post">
    <table border="1">
        <tr><th>Chọn</th><th>Tên file</th></tr>
        <% for (File file : files) { %>
            <tr>
                <td><input type="checkbox" name="fileNames" value="<%= file.getName() %>"></td>
                <td><%= file.getName() %></td>
            </tr>
        <% } %>
    </table>
    <button type="submit">Tải về file đã chọn</button>
</form>

