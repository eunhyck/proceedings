<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="/WEB-INF/db.jspf" %>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>개인별 업무</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">

<h2>개인별 업무 목록</h2>
<a href="meeting_list.jsp">← 회의 목록</a>

<%
    String userIdStr = request.getParameter("user_id");
    Integer userId = null;
    if (userIdStr != null && !userIdStr.isEmpty()) {
        userId = Integer.parseInt(userIdStr);
    }

    List<Map<String,Object>> users = new ArrayList<>();
    PreparedStatement ps = conn.prepareStatement("SELECT USER_ID, NAME FROM USERS ORDER BY NAME");
    ResultSet rs = ps.executeQuery();
    while (rs.next()) {
        Map<String,Object> u = new HashMap<>();
        u.put("id", rs.getInt("USER_ID"));
        u.put("name", rs.getString("NAME"));
        users.add(u);
    }
    rs.close();
    ps.close();
%>

<div class="card">
<form method="get">
  <div class="row">
    <select name="user_id" required style="flex:1;">
      <option value="">-- 담당자 선택 --</option>
      <% for (Map<String,Object> u : users) { %>
        <option value="<%= u.get("id") %>"
          <%= (userId != null && ((Integer)u.get("id")).equals(userId)) ? "selected" : "" %>>
          <%= u.get("name") %>
        </option>
      <% } %>
    </select>
    <button type="submit" class="btn-primary">조회</button>
  </div>
</form>
</div>

<div class="card">
<table>
<thead>
<tr>
  <th>회의일자</th>
  <th>회의 제목</th>
  <th>업무</th>
  <th>상태</th>
</tr>
</thead>
<tbody>

<%
if (userId != null) {
    ps = conn.prepareStatement(
        "SELECT TO_CHAR(M.MEETING_DATE,'YYYY-MM-DD') MD, M.TITLE MT, M.MEETING_ID, " +
        "T.TITLE TT, T.STATUS " +
        "FROM TASKS T JOIN MEETINGS M ON T.MEETING_ID = M.MEETING_ID " +
        "WHERE T.ASSIGNEE_ID = ? ORDER BY M.MEETING_DATE DESC"
    );
    ps.setInt(1, userId);
    rs = ps.executeQuery();

    boolean has = false;
    while (rs.next()) {
        has = true;
        String status = rs.getString("STATUS");
        String statusDisplay = status.equals("IN_PROGRESS") ? "진행중" : 
                              status.equals("DONE") ? "완료" : "예정";
%>
<tr>
  <td><%= rs.getString("MD") %></td>
  <td>
    <a href="meeting_view.jsp?meeting_id=<%= rs.getInt("MEETING_ID") %>">
      <%= rs.getString("MT") %>
    </a>
  </td>
  <td><%= rs.getString("TT") %></td>
  <td><%= statusDisplay %></td>
</tr>
<%
    }
    if (!has) {
%>
<tr><td colspan="4">업무가 없습니다.</td></tr>
<%
    }
    rs.close();
    ps.close();
}
conn.close();
%>

</tbody>
</table>
</div>

</div>
</body>
</html>