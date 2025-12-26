<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>회의 등록</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
  
  <h2>회의 등록</h2>
  <a href="meeting_list.jsp">← 목록으로</a>

  <%@ include file="/WEB-INF/db.jspf" %>

  <%
    // 사용자 목록(참석자 선택용)
    List<Map<String, Object>> users = new ArrayList<>();
    PreparedStatement psU = null;
    ResultSet rsU = null;
    try {
      psU = conn.prepareStatement(
        "SELECT USER_ID, NAME FROM USERS " +
        "ORDER BY CASE WHEN NAME = '종훈' THEN 0 ELSE 1 END, NAME"
      );
      rsU = psU.executeQuery();
      while (rsU.next()) {
        Map<String, Object> u = new HashMap<>();
        u.put("id", rsU.getInt("USER_ID"));
        u.put("name", rsU.getString("NAME"));
        users.add(u);
      }
    } finally {
      if (rsU != null) rsU.close();
      if (psU != null) psU.close();
      conn.close();
    }
  %>

  <div class="card">
    <form method="post" action="action.jsp">
      <input type="hidden" name="mode" value="addMeeting"/>

      <div class="row">
        <div>
          <div><small>회의일자</small></div>
          <input type="date" name="meeting_date" required>
        </div>

        <div style="flex:1; min-width: 260px;">
          <div><small>회의 제목</small></div>
          <input type="text" name="title" placeholder="예) 주간 업무 공유" style="width:100%;" required>
        </div>
      </div>

      <div style="margin-top:16px;">
        <div><small>참석자</small></div>
        <div class="row">
          <% for (Map<String, Object> u : users) { %>
            <label style="display:flex; gap:6px; align-items:center;">
              <input type="checkbox" name="attendees" value="<%= u.get("id") %>">
              <%= u.get("name") %>
            </label>
          <% } %>
        </div>
        <small style="color:#7f8c8d; margin-top: 8px;">※ 참석자 미선택도 가능합니다</small>
      </div>

      <div style="margin-top:16px;">
        <div><small>주요 내용</small></div>
        <textarea name="content" placeholder="회의 주요 내용을 입력하세요" required></textarea>
      </div>

      <div style="margin-top:20px; display: flex; gap: 10px;">
        <button type="submit" class="btn-primary">등록</button>
        <a href="meeting_list.jsp" class="btn">취소</a>
      </div>
    </form>
  </div>
</div>
</body>
</html>