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
        <% if ("Chưa bắt đầu".equals(status)) { %>
        <h5><i class="fa-solid fa-hourglass-start"></i> <%= trangThaiLabels.get(status) %></h5>
        <% }else if("Đang thực hiện".equals(status)) { %>
        <h5><i class="fa-solid fa-spinner"></i> <%= trangThaiLabels.get(status) %></h5>
        <% }else if("Đã hoàn thành".equals(status)) { %>
        <h5><i class="fa-solid fa-check-circle"></i> <%= trangThaiLabels.get(status) %></h5> 
        <% }else if("Trễ hạn".equals(status)) { %>
        <h5><i class="fa-solid fa-exclamation-triangle"></i> <%= trangThaiLabels.get(status) %></h5>
        <% } %>   
        <% if ("Chưa bắt đầu".equals(status)) { %>
        <% } %>
        <% for (Map<String, Object> task : taskList) {
               if (status.equals(task.get("trang_thai"))) {
               // Kiểm tra xem task có được nhắc nhở hay không
            Object nhacNho = task.get("nhac_viec");
            boolean hasReminder = false;

            if (nhacNho != null) {
                try {
                    int value = Integer.parseInt(nhacNho.toString());
                    hasReminder = (value == 1);
                } catch (NumberFormatException e) {
                    hasReminder = false;
                }
            }
                                        
            // Trạng thái duyệt
            String trangThaiDuyet = task.get("trang_thai_duyet") != null ? task.get("trang_thai_duyet").toString() : "Chưa duyệt";
            String duyetBadgeClass = "badge-chua-duyet";
            if ("Đã duyệt".equals(trangThaiDuyet)) duyetBadgeClass = "badge-da-duyet";
            else if ("Từ chối".equals(trangThaiDuyet)) duyetBadgeClass = "badge-tu-choi";
        %>
        <div class="kanban-task <%= hasReminder ? "task--alert" : "" %>" data-task-id="<%= task.get("id") %>">
            <div class="task-content" 
                 data-bs-toggle="modal" 
                 data-bs-target="#modalTaskDetail"
                 data-id="<%= task.get("id") %>"
                 data-ten="<%= task.get("ten_cong_viec") %>"
                 data-mo-ta="<%= task.get("mo_ta") %>"
                 data-ngay-bat-dau="<%= task.get("ngay_bat_dau") %>"
                 data-han="<%= task.get("han_hoan_thanh") %>"
                 data-ngay-gia-han="<%= task.get("ngay_gia_han") %>"
                 data-uu-tien="<%= task.get("muc_do_uu_tien") %>"
                 data-ten_nguoi_giao="<%= task.get("nguoi_giao_id") %>"
                 data-ten_nguoi_nhan="<%= task.get("nguoi_nhan_ten") %>"
                 data-ten_phong_ban="<%= task.get("phong_ban_id") %>"
                 data-trang-thai="<%= task.get("trang_thai") %>"
                 data-trang-thai-duyet="<%= trangThaiDuyet %>"
                 data-tai_lieu_cv="<%= task.get("tai_lieu_cv") %>"
                 data-file_tai_lieu="<%= task.get("file_tai_lieu") %>">
                <% if (hasReminder) { %>
                <div class="task-reminder-bell" title="Công việc đang được nhắc nhở">
                    <i class="fa-solid fa-bell"></i>
                </div>
                <% } %>
                <div class="task-title"><%= task.get("ten_cong_viec") %></div>
                <div class="task-meta">Người giao: <b><%= task.get("nguoi_giao_id") %></b><br>Người nhận: <b><%= task.get("nguoi_nhan_ten") %></b></div>
                <span class="task-priority badge <%= priorityBadge.getOrDefault(task.get("muc_do_uu_tien"), "bg-secondary") %>"><%= task.get("muc_do_uu_tien") %></span>
                <span class="task-status badge <%= badgeClass.getOrDefault(status, "bg-secondary") %>"><%= trangThaiLabels.get(status) %></span>
                <span class="badge <%= duyetBadgeClass %> ms-1"><%= trangThaiDuyet %></span>
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
                    <div class="progress-bar <%= badgeClass.getOrDefault(status, "bg-secondary") %>"
                         style="width: <%= percent %>%;">
                    </div>
                </div>
            </div>

            <!-- Nút 3 chấm -->
            <div class="task-actions">
                <button class="task-dots-btn" type="button" data-stop-modal="true">
                    <i class="fa-solid fa-ellipsis-vertical"></i>
                </button>
                <div class="task-actions-dropdown">
                    <button class="task-action-item archive" data-task-id="<%= task.get("id") %>" data-action="archive"><i class="fa-solid fa-archive"></i> Lưu trữ</button>
                    <button class="task-action-item remind" data-task-id="<%= task.get("id") %>" data-action="remind"><i class="fa-solid fa-bell"></i> Nhắc việc</button>
                    <button class="task-action-item delete" data-task-id="<%= task.get("id") %>" data-action="delete"><i class="fa-solid fa-trash"></i> Xóa</button>
                </div>
            </div>
        </div>
        <% }} %>
    </div>
    <% } %>
</div>