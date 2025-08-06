<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*" %>

<%
    List<Map<String, Object>> taskList = (List<Map<String, Object>>) request.getAttribute("taskList");

    Map<String, String> trangThaiLabels = new LinkedHashMap<>();
    trangThaiLabels.put("Chưa bắt đầu", "Chưa bắt đầu");
    trangThaiLabels.put("Đang thực hiện", "Đang thực hiện");
    trangThaiLabels.put("Đã hoàn thành", "Đã hoàn thành");
    trangThaiLabels.put("Trễ hạn", "Trễ hạn");

    Map<String, String> badgeClass = new HashMap<>();
    badgeClass.put("Chưa bắt đầu", "bg-secondary");
    badgeClass.put("Đang thực hiện", "bg-warning text-dark");
    badgeClass.put("Đã hoàn thành", "bg-success");
    badgeClass.put("Trễ hạn", "bg-danger");

    Map<String, String> priorityBadge = new HashMap<>();
    priorityBadge.put("Cao", "bg-danger");
    priorityBadge.put("Trung bình", "bg-warning text-dark");
    priorityBadge.put("Thấp", "bg-success");
%>


<div class="kanban-board">
    <% for (String status : trangThaiLabels.keySet()) { 
           String columnClass = "";
           if ("Chưa bắt đầu".equals(status)) columnClass = "not-started";
           else if ("Đang thực hiện".equals(status)) columnClass = "in-progress";
           else if ("Đã hoàn thành".equals(status)) columnClass = "completed";
           else if ("Trễ hạn".equals(status)) columnClass = "late";
    %>
    <div class="kanban-col <%= columnClass %>">
        <h5><%= trangThaiLabels.get(status) %></h5>
        <% if ("Chưa bắt đầu".equals(status)) { %>
        <button class="btn btn-outline-secondary kanban-add-btn" data-bs-toggle="modal"
                data-bs-target="#modalTask">
            <i class="fa-solid fa-plus"></i> Thêm task
        </button>
        <% } %>
        <% for (Map<String, Object> task : taskList) {
               if (status.equals(task.get("trang_thai"))) {
        %>
        <div class="kanban-task" data-bs-toggle="modal" data-bs-target="#modalTaskDetail"
             data-id="<%= task.get("id") %>"
             data-ten="<%= task.get("ten_cong_viec") %>"
             data-mo-ta="<%= task.get("mo_ta") %>"
             data-han="<%= task.get("han_hoan_thanh") %>"
             data-uu-tien="<%= task.get("muc_do_uu_tien") %>"
             data-ten_nguoi_giao="<%= task.get("nguoi_giao_id") %>"
             data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_id") %>"
             data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
             data-trang-thai="<%= task.get("trang_thai") %>">
            <div class="task-title"><%= task.get("ten_cong_viec") %></div>
            <div class="task-meta">Người giao: <b><%= task.get("nguoi_giao_id") %></b> <br>Người nhận: <b><%= task.get("nguoi_nhan_id") %></b></div>
            <span class="task-priority badge <%= priorityBadge.getOrDefault(task.get("muc_do_uu_tien"), "bg-secondary") %>">
                <%= task.get("muc_do_uu_tien") %>
            </span>
            <span class="task-status badge <%= badgeClass.getOrDefault(status, "bg-secondary") %>">
                <%= trangThaiLabels.get(status) %>
            </span>
            <%
                Object p = task.get("phan_tram");
                int percent = 0;
                if (p != null) {
                    try {
                        percent = Integer.parseInt(p.toString());
                    } catch (NumberFormatException e) {
                        percent = 0;
                    }
                }
            %>
            <div class="progress">
                <div class="progress-bar <%= badgeClass.getOrDefault(status, "bg-secondary") %>" style="width: <%= percent %>%;"></div>
            </div>
            <%
                String vaitro = (String) task.get("vai_tro");
                boolean isAdminOrManager = "Admin".equalsIgnoreCase(vaitro) || "Quản lý".equalsIgnoreCase(vaitro);
            %>
            <% if (isAdminOrManager) { %>
            <div class="task-actions">
                <form action="./xoaCongviec" method="post" onsubmit="return confirm('Bạn có chắc muốn xóa công việc này không?');">
                    <input type="hidden" name="id" value="<%= task.get("id") %>">
                    <button type="submit" class="btn btn-sm btn-danger">
                        <i class="fa-solid fa-trash"></i>
                    </button>
                </form>
            </div>
            <% } %>
        </div>
        <% }} %>
    </div>
    <% } %>
</div>
