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

<div class="kanban-board deleted-board">
    <% for (String status : trangThaiLabels.keySet()) { 
           String columnClass = "";
           if ("Chưa bắt đầu".equals(status)) columnClass = "not-started";
           else if ("Đang thực hiện".equals(status)) columnClass = "in-progress";
           else if ("Đã hoàn thành".equals(status)) columnClass = "completed";
           else if ("Trễ hạn".equals(status)) columnClass = "late";
    %>
    <div class="kanban-col <%= columnClass %> deleted-col">
        <% if ("Chưa bắt đầu".equals(status)) { %>
        <h5><i class="fa-solid fa-trash"></i> <%= trangThaiLabels.get(status) %> (Đã xóa)</h5>
        <% }else if("Đang thực hiện".equals(status)) { %>
        <h5><i class="fa-solid fa-trash"></i> <%= trangThaiLabels.get(status) %> (Đã xóa)</h5>
        <% }else if("Đã hoàn thành".equals(status)) { %>
        <h5><i class="fa-solid fa-trash"></i> <%= trangThaiLabels.get(status) %> (Đã xóa)</h5> 
        <% }else if("Trễ hạn".equals(status)) { %>
        <h5><i class="fa-solid fa-trash"></i> <%= trangThaiLabels.get(status) %> (Đã xóa)</h5>
        <% } %>   
        
        <% for (Map<String, Object> task : taskList) {
               if (status.equals(task.get("trang_thai"))) {
        %>
        <div class="kanban-task deleted-task" data-bs-toggle="modal" data-bs-target="#modalTaskDetail"
             data-id="<%= task.get("id") %>"
             data-ten="<%= task.get("ten_cong_viec") %>"
             data-mo-ta="<%= task.get("mo_ta") %>"
             data-han="<%= task.get("han_hoan_thanh") %>"
             data-uu-tien="<%= task.get("muc_do_uu_tien") %>"
             data-ten_nguoi_giao="<%= task.get("nguoi_giao_id") %>"
             data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_ten") %>"
             data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
             data-trang-thai="<%= task.get("trang_thai") %>"
             data-tai_lieu_cv="<%= task.get("tai_lieu_cv") %>"
             data-file_tai_lieu="<%= task.get("file_tai_lieu") %>">
            <div class="task-title"><%= task.get("ten_cong_viec") %></div>
            <div class="task-meta">Người giao: <b><%= task.get("nguoi_giao_id") %></b> <br>Người nhận: <b><%= task.get("nguoi_nhan_ten") %></b></div>
            <span class="task-priority badge <%= priorityBadge.getOrDefault(task.get("muc_do_uu_tien"), "bg-secondary") %>">
                <%= task.get("muc_do_uu_tien") %>
            </span>
            <span class="task-status badge bg-danger">
                Đã xóa
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
                <div class="progress-bar bg-danger" style="width: <%= percent %>%; opacity: 0.5;"></div>
            </div>
            <!-- Nút 3 chấm -->
            <div class="task-actions">
                <button class="task-dots-btn" type="button" data-stop-modal="true">
                    <i class="fa-solid fa-ellipsis-vertical"></i>
                </button>
                <div class="task-actions-dropdown">
                    <button class="task-action-item restore" data-task-id="<%= task.get("id") %>" data-action="restore">
                        <i class="fa-solid fa-undo"></i> Khôi phục
                    </button>
                    <button class="task-action-item delete-permanent" data-task-id="<%= task.get("id") %>" data-action="permanent-delete">
                        <i class="fa-solid fa-trash"></i> Xóa vĩnh viễn
                    </button>
                </div>
            </div>
        </div>
        <% }} %>
    </div>
    <% } %>
</div>

<style>
.deleted-board .deleted-col {
    background: linear-gradient(135deg, #f8d7da 0%, #f5c6cb 100%);
    border: 2px solid #dc3545;
    border-radius: 12px;
}

.deleted-board .deleted-col h5 {
    color: #dc3545;
    font-weight: 600;
    background: rgba(220, 53, 69, 0.1);
    padding: 8px 12px;
    border-radius: 8px;
    margin-bottom: 15px;
}

.deleted-board .deleted-task {
    opacity: 0.6;
    border-left: 4px solid #dc3545;
    background: rgba(248, 215, 218, 0.7);
    text-decoration: line-through;
}

.deleted-board .deleted-task:hover {
    opacity: 0.8;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(220, 53, 69, 0.2);
}

.deleted-board .task-actions {
    display: flex;
    gap: 5px;
    justify-content: center;
}

.deleted-board .btn-restore {
    background-color: #198754;
    border-color: #198754;
}

.deleted-board .btn-permanent-delete {
    background-color: #dc3545;
    border-color: #dc3545;
}
</style>
