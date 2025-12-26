<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*, java.util.*" %>
<%@ include file="/WEB-INF/db.jspf" %>

<%
request.setCharacterEncoding("UTF-8");

String mode = request.getParameter("mode");
PreparedStatement ps = null;
ResultSet rs = null;

try {

    /* 회의 등록 */
    if ("addMeeting".equals(mode)) {
        String meetingDate = request.getParameter("meeting_date");
        String title = request.getParameter("title");
        String content = request.getParameter("content");
        String[] attendees = request.getParameterValues("attendees");

        ps = conn.prepareStatement(
            "INSERT INTO MEETINGS (MEETING_ID, MEETING_DATE, TITLE, CONTENT) " +
            "VALUES (SEQ_MEETINGS.NEXTVAL, TO_DATE(?, 'YYYY-MM-DD'), ?, ?)"
        );
        ps.setString(1, meetingDate);
        ps.setString(2, title);
        ps.setString(3, content);
        ps.executeUpdate();
        ps.close();

        ps = conn.prepareStatement("SELECT MAX(MEETING_ID) FROM MEETINGS");
        rs = ps.executeQuery();
        int meetingId = 0;
        if (rs.next()) meetingId = rs.getInt(1);
        rs.close();
        ps.close();

        if (attendees != null) {
            ps = conn.prepareStatement(
                "INSERT INTO MEETING_ATTENDEES (MEETING_ID, USER_ID) VALUES (?, ?)"
            );
            for (String u : attendees) {
                ps.setInt(1, meetingId);
                ps.setInt(2, Integer.parseInt(u));
                ps.executeUpdate();
            }
            ps.close();
        }

        conn.commit();
        response.sendRedirect("meeting_view.jsp?meeting_id=" + meetingId);
        return;
    }

    /* 회의 삭제 */
    if ("deleteMeeting".equals(mode)) {
        int meetingId = Integer.parseInt(request.getParameter("meeting_id"));

        // CASCADE 설정으로 자동 삭제되지만 명시적으로 처리
        ps = conn.prepareStatement("DELETE FROM MEETINGS WHERE MEETING_ID = ?");
        ps.setInt(1, meetingId);
        ps.executeUpdate();
        ps.close();

        conn.commit();
        response.sendRedirect("meeting_list.jsp");
        return;
    }

    /* 참석자 업데이트 */
    if ("updateAttendees".equals(mode)) {
        int meetingId = Integer.parseInt(request.getParameter("meeting_id"));
        String[] attendees = request.getParameterValues("attendees");

        // 기존 참석자 삭제
        ps = conn.prepareStatement("DELETE FROM MEETING_ATTENDEES WHERE MEETING_ID = ?");
        ps.setInt(1, meetingId);
        ps.executeUpdate();
        ps.close();

        // 새로운 참석자 추가
        if (attendees != null && attendees.length > 0) {
            ps = conn.prepareStatement(
                "INSERT INTO MEETING_ATTENDEES (MEETING_ID, USER_ID) VALUES (?, ?)"
            );
            for (String u : attendees) {
                ps.setInt(1, meetingId);
                ps.setInt(2, Integer.parseInt(u));
                ps.executeUpdate();
            }
            ps.close();
        }

        conn.commit();
        response.sendRedirect("meeting_view.jsp?meeting_id=" + meetingId);
        return;
    }

    /* 업무 추가 */
    if ("addTask".equals(mode)) {
        int meetingId = Integer.parseInt(request.getParameter("meeting_id"));
        String taskTitle = request.getParameter("task_title");
        int assigneeId = Integer.parseInt(request.getParameter("assignee_id"));
        String status = request.getParameter("status");

        ps = conn.prepareStatement(
            "INSERT INTO TASKS (TASK_ID, MEETING_ID, TITLE, ASSIGNEE_ID, STATUS) " +
            "VALUES (SEQ_TASKS.NEXTVAL, ?, ?, ?, ?)"
        );
        ps.setInt(1, meetingId);
        ps.setString(2, taskTitle);
        ps.setInt(3, assigneeId);
        ps.setString(4, status);
        ps.executeUpdate();
        ps.close();

        conn.commit();
        response.sendRedirect("meeting_view.jsp?meeting_id=" + meetingId);
        return;
    }

    /* 업무 상태 변경 */
    if ("updateTaskStatus".equals(mode)) {
        int meetingId = Integer.parseInt(request.getParameter("meeting_id"));
        int taskId = Integer.parseInt(request.getParameter("task_id"));
        String status = request.getParameter("status");

        ps = conn.prepareStatement("UPDATE TASKS SET STATUS = ? WHERE TASK_ID = ?");
        ps.setString(1, status);
        ps.setInt(2, taskId);
        ps.executeUpdate();
        ps.close();

        conn.commit();
        response.sendRedirect("meeting_view.jsp?meeting_id=" + meetingId);
        return;
    }

    /* 업무 삭제 */
    if ("deleteTask".equals(mode)) {
        int meetingId = Integer.parseInt(request.getParameter("meeting_id"));
        int taskId = Integer.parseInt(request.getParameter("task_id"));

        ps = conn.prepareStatement("DELETE FROM TASKS WHERE TASK_ID = ?");
        ps.setInt(1, taskId);
        ps.executeUpdate();
        ps.close();

        conn.commit();
        response.sendRedirect("meeting_view.jsp?meeting_id=" + meetingId);
        return;
    }

    response.sendRedirect("meeting_list.jsp");

} catch (Exception e) {
    try { conn.rollback(); } catch (Exception ignore) {}
%>
<html>
<head>
  <meta charset="UTF-8">
  <title>오류</title>
  <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
  <div class="card">
    <h3>오류 발생</h3>
    <pre style="color: #e74c3c;"><%= e.toString() %></pre>
    <a href="meeting_list.jsp" class="btn">목록으로</a>
  </div>
</div>
</body>
</html>
<%
} finally {
    if (rs != null) try { rs.close(); } catch (Exception ignore) {}
    if (ps != null) try { ps.close(); } catch (Exception ignore) {}
    if (conn != null) try { conn.close(); } catch (Exception ignore) {}
}
%>