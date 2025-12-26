<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>회의록 관리 시스템</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
  
  <div class="header-actions">
    <h2>회의록 & 업무 관리</h2>
    <div>
      <a href="my_tasks.jsp" class="btn">내 업무 보기</a>
      <a href="meeting_form.jsp" class="btn btn-primary">회의 등록하기</a>
    </div>
  </div>

  <%@ include file="/WEB-INF/db.jspf" %>

  <div class="card">
    <h3>회의 목록</h3>
    <table>
      <thead>
        <tr>
          <th style="width:140px;">일자</th>
          <th>제목</th>
          <th style="width:100px;">상세</th>
          <th style="width:100px;">삭제</th>
        </tr>
      </thead>
      <tbody>
      <%
        PreparedStatement psM = null;
        ResultSet rsM = null;
        try {
          psM = conn.prepareStatement(
            "SELECT MEETING_ID, TO_CHAR(MEETING_DATE,'YYYY-MM-DD') AS MD, TITLE " +
            "FROM MEETINGS ORDER BY MEETING_DATE DESC, MEETING_ID DESC"
          );
          rsM = psM.executeQuery();
          boolean has = false;
          while (rsM.next()) {
            has = true;
      %>
        <tr>
          <td><%= rsM.getString("MD") %></td>
          <td><%= rsM.getString("TITLE") %></td>
          <td><a href="meeting_view.jsp?meeting_id=<%= rsM.getInt("MEETING_ID") %>">열기</a></td>
          <td>
            <form method="post" action="action.jsp" style="display:inline;" onsubmit="return confirm('정말 삭제하시겠습니까?');">
              <input type="hidden" name="mode" value="deleteMeeting">
              <input type="hidden" name="meeting_id" value="<%= rsM.getInt("MEETING_ID") %>">
              <button type="submit" class="btn-danger" style="padding:6px 12px; font-size:13px;">삭제</button>
            </form>
          </td>
        </tr>
      <%
          }
          if (!has) {
      %>
        <tr><td colspan="4">등록된 회의가 없습니다.</td></tr>
      <%
          }
        } finally {
          if (rsM != null) rsM.close();
          if (psM != null) psM.close();
          conn.close();
        }
      %>
      </tbody>
    </table>
  </div>
</div>
</body>
</html>