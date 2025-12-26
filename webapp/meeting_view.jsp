<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="/WEB-INF/db.jspf" %>

<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>회의 상세</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">

<%
    String meetingIdStr = request.getParameter("meeting_id");
    if (meetingIdStr == null) {
        response.sendRedirect("meeting_list.jsp");
        return;
    }
    int meetingId = Integer.parseInt(meetingIdStr);

    String meetingDate = "";
    String title = "";
    String content = "";

    PreparedStatement ps = null;
    ResultSet rs = null;

    // 회의 정보 조회
    ps = conn.prepareStatement(
        "SELECT TO_CHAR(MEETING_DATE,'YYYY-MM-DD') AS MD, TITLE, CONTENT " +
        "FROM MEETINGS WHERE MEETING_ID = ?"
    );
    ps.setInt(1, meetingId);
    rs = ps.executeQuery();
    if (rs.next()) {
        meetingDate = rs.getString("MD");
        title = rs.getString("TITLE");
        content = rs.getString("CONTENT");
    }
    rs.close();
    ps.close();
%>

<h2>회의 상세</h2>
<a href="meeting_list.jsp">← 목록</a>

<div class="card">
  <p><strong>일자:</strong> <%= meetingDate %></p>
  <p><strong>제목:</strong> <%= title %></p>
  <p><strong>내용:</strong></p>
  <pre><%= content %></pre>
</div>

<!-- 참석자 관리 -->
<div class="card">
  <h3>참석자 관리</h3>
  
  <%
    // 현재 참석자 조회
    List<Integer> currentAttendees = new ArrayList<>();
    ps = conn.prepareStatement("SELECT USER_ID FROM MEETING_ATTENDEES WHERE MEETING_ID = ?");
    ps.setInt(1, meetingId);
    rs = ps.executeQuery();
    while (rs.next()) {
        currentAttendees.add(rs.getInt("USER_ID"));
    }
    rs.close();
    ps.close();
    
    // 전체 사용자 목록
    List<Map<String, Object>> allUsers = new ArrayList<>();
    ps = conn.prepareStatement(
      "SELECT USER_ID, NAME FROM USERS " +
      "ORDER BY CASE WHEN NAME = '종훈' THEN 0 ELSE 1 END, NAME"
    );
    rs = ps.executeQuery();
    while (rs.next()) {
        Map<String, Object> u = new HashMap<>();
        u.put("id", rs.getInt("USER_ID"));
        u.put("name", rs.getString("NAME"));
        allUsers.add(u);
    }
    rs.close();
    ps.close();
  %>
  
  <form method="post" action="action.jsp">
    <input type="hidden" name="mode" value="updateAttendees">
    <input type="hidden" name="meeting_id" value="<%= meetingId %>">
    
    <div class="row" style="margin-bottom: 12px;">
      <% for (Map<String, Object> u : allUsers) { 
         int uid = (Integer)u.get("id");
         boolean isAttending = currentAttendees.contains(uid);
      %>
        <label style="display:flex; gap:6px; align-items:center;">
          <input type="checkbox" name="attendees" value="<%= uid %>" 
                 <%= isAttending ? "checked" : "" %>>
          <%= u.get("name") %>
        </label>
      <% } %>
    </div>
    
    <button type="submit" class="btn-primary">참석자 저장</button>
  </form>
</div>

<%
    // 사용자 목록 (업무 담당자 선택용)
    List<Map<String, Object>> users = new ArrayList<>();
    ps = conn.prepareStatement(
      "SELECT USER_ID, NAME FROM USERS " +
      "ORDER BY CASE WHEN NAME = '종훈' THEN 0 ELSE 1 END, NAME"
    );
    rs = ps.executeQuery();
    while (rs.next()) {
        Map<String, Object> u = new HashMap<>();
        u.put("id", rs.getInt("USER_ID"));
        u.put("name", rs.getString("NAME"));
        users.add(u);
    }
    rs.close();
    ps.close();
%>

<div class="card">
  <h3>업무 추가</h3>
  <form method="post" action="action.jsp">
    <input type="hidden" name="mode" value="addTask">
    <input type="hidden" name="meeting_id" value="<%= meetingId %>">

    <div class="row">
      <input type="text" name="task_title" placeholder="업무 내용" style="flex:1;" required>

      <select name="assignee_id" required>
        <option value="">담당자 선택</option>
        <% for (Map<String,Object> u : users) { %>
          <option value="<%= u.get("id") %>"><%= u.get("name") %></option>
        <% } %>
      </select>

      <input type="hidden" name="status" value="TODO">

      <button type="submit" class="btn-success">추가</button>
    </div>
  </form>
</div>

<div class="card">
  <h3>업무 목록</h3>
  <table>
    <thead>
      <tr>
        <th>업무</th>
        <th>담당자</th>
        <th>상태</th>
        <th>변경</th>
        <th>삭제</th>
      </tr>
    </thead>
    <tbody>
<%
    ps = conn.prepareStatement(
        "SELECT T.TASK_ID, T.TITLE, T.STATUS, U.NAME " +
        "FROM TASKS T JOIN USERS U ON T.ASSIGNEE_ID = U.USER_ID " +
        "WHERE T.MEETING_ID = ? ORDER BY T.TASK_ID DESC"
    );
    ps.setInt(1, meetingId);
    rs = ps.executeQuery();

    boolean hasTasks = false;
    while (rs.next()) {
        hasTasks = true;
        String status = rs.getString("STATUS");
        String statusDisplay = status.equals("IN_PROGRESS") ? "진행중" : 
                              status.equals("DONE") ? "완료" : "예정";
%>
      <tr>
        <td><%= rs.getString("TITLE") %></td>
        <td><%= rs.getString("NAME") %></td>
        <td><%= statusDisplay %></td>
        <td>
          <form method="post" action="action.jsp" style="display:inline;">
            <input type="hidden" name="mode" value="updateTaskStatus">
            <input type="hidden" name="meeting_id" value="<%= meetingId %>">
            <input type="hidden" name="task_id" value="<%= rs.getInt("TASK_ID") %>">
            <select name="status" style="width:auto; min-width:100px;">
              <option value="TODO" <%= status.equals("TODO") ? "selected" : "" %>>예정</option>
              <option value="IN_PROGRESS" <%= status.equals("IN_PROGRESS") ? "selected" : "" %>>진행중</option>
              <option value="DONE" <%= status.equals("DONE") ? "selected" : "" %>>완료</option>
            </select>
            <button type="submit" class="btn-primary" style="padding:6px 12px; font-size:13px;">변경</button>
          </form>
        </td>
        <td>
          <form method="post" action="action.jsp" style="display:inline;">
            <input type="hidden" name="mode" value="deleteTask">
            <input type="hidden" name="meeting_id" value="<%= meetingId %>">
            <input type="hidden" name="task_id" value="<%= rs.getInt("TASK_ID") %>">
            <button type="submit" class="btn-danger" style="padding:6px 12px; font-size:13px;">삭제</button>
          </form>
        </td>
      </tr>
<%
    }
    if (!hasTasks) {
%>
      <tr><td colspan="5">등록된 업무가 없습니다.</td></tr>
<%
    }
    rs.close();
    ps.close();
    conn.close();
%>
    </tbody>
  </table>
</div>

</div>
</body>
</html>