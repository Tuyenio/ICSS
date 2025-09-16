<%-- 
    Document   : upload_multiple
    Created on : Sep 16, 2025, 10:09:52 AM
    Author     : Admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
        <title>JSP Page</title>
    </head>
    <body>
        <form action="upload" method="post" enctype="multipart/form-data">
            <label>Chọn nhiều file:</label>
            <input type="file" name="files" multiple>
            <button type="submit">Tải lên</button>
        </form>
    </body>
</html>
