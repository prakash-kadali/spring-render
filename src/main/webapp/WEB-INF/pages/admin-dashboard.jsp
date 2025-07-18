<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Multywave Technologies</title>
 <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css"> 
 <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
<link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css"> 
</head>

<body>
<c:if test="${sessionScope.userRole ne 'admin'}">
    <c:redirect url="/login?error=AccessDenied"/>
</c:if>
<c:set var="activeTab" value="${param.tab}" />

<div class="sidebar">
    <a href="${pageContext.request.contextPath}/admin-dashboard" class="text-decoration-none text-white"> <h2 class="py-3 mb-4 border-bottom border-secondary">Multywave<br>Technologies</h2></a>
    <a href="${pageContext.request.contextPath}/admin-dashboard?tab=departments" class="nav-link text-white ${activeTab == 'departments' ? 'active-link' : ''}"><i class="fas fa-building me-2"></i>Departments</a>
    <a href="${pageContext.request.contextPath}/admin-dashboard?tab=designations" class="nav-link text-white ${activeTab == 'designations' ? 'active-link' : ''}">        <i class="fas fa-id-badge me-2"></i>Designations</a>
    <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees" class="nav-link text-white ${activeTab == 'employees' ? 'active-link' : ''}"><i class="fas fa-users me-2"></i>Employees</a>
    <a href="${pageContext.request.contextPath}/admin-dashboard?tab=users" class="nav-link text-white ${activeTab == 'users' ? 'active-link' : ''}"><i class="fas fa-user-cog me-2"></i>Users</a>
<a href="${pageContext.request.contextPath}/admin-dashboard?tab=leaves" class="nav-link text-white ${activeTab == 'leaves' ? 'active-link' : ''}">
    <i class="fas fa-clipboard-list me-2"></i>
    Leave Requests <span class="badge bg-warning text-dark">${pendingLeaves}</span>
</a>    
<a href="${pageContext.request.contextPath}/admin-dashboard?tab=statistics" class="nav-link text-white ${activeTab == 'statistics' ? 'active-link' : ''}">
    <i class="fas fa-chart-bar me-2"></i>Statistics
</a>

    <a href="${pageContext.request.contextPath}/admin-dashboard?tab=salaries" class="nav-link text-white ${activeTab == 'salaries' ? 'active-link' : ''}"><i class="fas fa-money-bill-wave me-2"></i>Salaries</a>
    <form action="${pageContext.request.contextPath}/logout" method="get" class="text-center mt-5">
        <button type="submit" class="btn btn-warning logout-button">
            <i class="fas fa-sign-out-alt me-2"></i>Logout
        </button>
    </form>
</div>

<div class="main-content">
    <%-- Multywave Technologies banner displayed for every section --%>
    <div>
    <div class="top-page-banner">
        <h1>Multywave Technologies</h1>
        <p>Security at your fingertips</p>
    </div>
   <%--Success& Error Messages --%>
    <c:if test="${not empty message}">
        <div class="alert alert-success text-center mt-3" role="alert">
            ${message}
        </div>
    </c:if>
    <c:if test="${not empty error}">
        <div class="alert alert-danger text-center mt-3" role="alert">
            ${error}
        </div>
    </c:if>
    
    <c:if test="${empty activeTab}">
     <%-- 2. SCROLLING ANNOUNCEMENT BANNER - Move here (outside empty activeTab) --%>
     
   <div class="announcement-container mt-4 mb-4">
    <div class="announcement-title fw-bold mb-2">
        <i class="fas fa-bullhorn me-2"></i>Announcements:
    </div>
    <div class="announcement-scroller">
        <div class="scrolling-vertical">
            <c:choose>
                <c:when test="${not empty activeAnnouncements}">
                    <c:forEach var="announcement" items="${activeAnnouncements}">
                        <div class="announcement-item-line">
                            <strong>${announcement.message}</strong>
                            <span class="ms-2">(${announcement.createdAt})</span>
                        </div>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <div class="announcement-item-line">No new announcements at this time.</div>
                </c:otherwise>
            </c:choose>
        </div>
    </div>
</div>
        <%-- 3. NEW ANNOUNCEMENT FORM - Move here --%>
       <!-- Button to open popup -->
<div class="text-center mb-3">
    <button class="btn btn-primary me-2" onclick="openAnnouncementPopup()">Publish Announcement</button>
    <button class="btn btn-outline-primary" onclick="openArchivePopup()">View Archived Announcements</button>
</div>

<!-- Modal Popup for New Announcement -->
<div id="announcementModal" class="modal" style="display:none; position: fixed; top:0; left:0; width:100%; height:100%; background: rgba(0,0,0,0.6); z-index: 9999;">
    <div class="modal-dialog modal-dialog-centered" style="max-width: 500px; margin: 5% auto; background: white; border-radius: 10px; overflow: hidden;">
        <div class="modal-content p-4">
            <div class="modal-header">
                <h5 class="modal-title">Add New Announcement</h5>
                <button type="button" class="btn-close" onclick="closeAnnouncementPopup()"></button>
            </div>
            <div class="modal-body">
                <form action="${pageContext.request.contextPath}/admin/addAnnouncement" method="post">
                    <div class="mb-3">
                        <label for="announcementMessage" class="form-label">Message</label>
                        <textarea class="form-control" id="announcementMessage" name="message" rows="3" required></textarea>
                    </div>
                    <div class="text-end">
                        <button type="submit" class="btn btn-success">Publish</button>
                        <button type="button" class="btn btn-secondary" onclick="closeAnnouncementPopup()">Cancel</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

        <%-- All Announcements List (Management) - Stays with the form --%>
        <!-- Archived Announcements Modal -->
<div class="modal fade" id="archiveModal" tabindex="-1" aria-labelledby="archiveModalLabel" aria-hidden="true">
  <div class="modal-dialog modal-xl modal-dialog-scrollable modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title" id="archiveModalLabel">Active & Archived Announcements</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
      </div>
      <div class="modal-body">

        <div class="mt-4">
            <h3>Active & Archived Announcements</h3>
            <div class="d-flex justify-content-between align-items-center mb-3">
                <label for="announcementSize" class="mr-2">Items per page:</label>
                <select id="announcementSize" class="form-control w-auto" onchange="window.location.href='${pageContext.request.contextPath}/admin-dashboard?announcementSize=' + this.value + '&announcementSortField=${announcementSortField}&announcementSortDir=${announcementSortDir}'">
                    <option value="5" ${announcementSize == 5 ? 'selected' : ''}>5</option>
                    <option value="10" ${announcementSize == 10 ? 'selected' : ''}>10</option>
                    <option value="20" ${announcementSize == 20 ? 'selected' : ''}>20</option>
                    <option value="50" ${announcementSize == 50 ? 'selected' : ''}>50</option>
                </select>
            </div>

            <div class="announcement-list">
                <c:choose>
                    <c:when test="${not empty allAnnouncements}">
                        <c:forEach var="announcement" items="${allAnnouncements}">
                            <div class="announcement-item card mb-3">
                                <div class="card-body">
                                    <h5 class="card-title">${announcement.message}</h5>
                                    <p class="card-text text-muted">Published: ${announcement.createdAt}</p>
                                    <div class="d-flex justify-content-between align-items-center">
                                        <div>
                                            <c:if test="${announcement.active}">
                                                <span class="badge bg-success">Active</span>
                                            </c:if>
                                            <c:if test="${!announcement.active}">
                                                <span class="badge bg-secondary">Archived</span>
                                            </c:if>
                                        </div>
                                        <div>
                                            <form action="${pageContext.request.contextPath}/admin/toggleAnnouncementStatus" method="post" style="display:inline-block; margin-right: 5px;">
                                                <input type="hidden" name="id" value="${announcement.id}">
                                                <button type="submit" class="btn btn-${announcement.active ? 'warning' : 'info'} btn-sm">
                                                    <i class="fas ${announcement.active ? 'fa-archive' : 'fa-check-circle'}"></i> ${announcement.active ? 'Deactivate' : 'Activate'}
                                                </button>
                                            </form>
                                            <form action="${pageContext.request.contextPath}/admin/deleteAnnouncement" method="post" style="display:inline-block;">
                                                <input type="hidden" name="id" value="${announcement.id}">
                                                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete this announcement?');">
                                                    <i class="fas fa-trash"></i> Delete
                                                </button>
                                            </form>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-info text-center" role="alert">
                            No announcements found.
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <%-- Pagination for Announcements --%>
            <div class="d-flex justify-content-center mt-3">
                <nav>
                    <ul class="pagination">
                        <li class="page-item ${announcementCurrentPage == 0 ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin-dashboard?announcementPage=${announcementCurrentPage - 1}&announcementSize=${announcementSize}&announcementSortField=${announcementSortField}&announcementSortDir=${announcementSortDir}">Previous</a>
                        </li>
                       <c:if test="${announcementTotalPages > 0}">
    <c:forEach var="i" begin="0" end="${announcementTotalPages - 1}">
        <li class="page-item ${announcementCurrentPage == i ? 'active' : ''}">
            <a class="page-link" href="${pageContext.request.contextPath}/admin-dashboard?announcementPage=${i}&announcementSize=${announcementSize}&announcementSortField=${announcementSortField}&announcementSortDir=${announcementSortDir}">${i + 1}</a>
        </li>
    </c:forEach>
</c:if>

                        <li class="page-item ${announcementCurrentPage + 1 == announcementTotalPages ? 'disabled' : ''}">
                            <a class="page-link" href="${pageContext.request.contextPath}/admin-dashboard?announcementPage=${announcementCurrentPage + 1}&announcementSize=${announcementSize}&announcementSortField=${announcementSortField}&announcementSortDir=${announcementSortDir}">Next</a>
                        </li>
                    </ul>
                </nav>
            </div>
        </div>

      </div>
    </div>
  </div>
</div>
        
       
    </c:if>
<c:if test="${empty activeTab}">
    <div class="badge-container">
        <div class="badge-item">
            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=departments">
                <i class="fas fa-building"></i> Departments<br>
                <span class="badge bg-primary">${departments.size()}</span>
            </a>
        </div>
        <div class="badge-item">
            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees">
                <i class="fas fa-users"></i> Employees<br>
                <span class="badge bg-primary">${totalEmployees}</span>
            </a>
        </div>
        <div class="badge-item">
            <a href="#" onclick="showCalendar()">
                <i class="fas fa-calendar"></i> Calendar
            </a>
        </div>
    </div>

    <div id="calendar-section" class="calendar-container" style="display: none;">
    <div class="calendar-header">
        <button onclick="previousMonth()">Previous</button>
        <h3 id="calendar-month-year"></h3>
        <button onclick="nextMonth()">Next</button>
    </div>
    <div class="calendar-days" id="calendar-days"></div>

    <div class="holiday-form mt-4 p-3 border rounded">
        <h4>Declare a Holiday</h4>
        <form id="declareHolidayForm" onsubmit="declareHoliday(event)">
            <div class="mb-3">
                <label for="holidayDate" class="form-label">Date:</label>
                <input type="date" class="form-control" id="holidayDate" name="date" required>
            </div>
            <div class="mb-3">
                <label for="holidayReason" class="form-label">Reason:</label>
                <input type="text" class="form-control" id="holidayReason" name="description"  required>
            </div>
            <button type="submit" class="btn btn-success">Declare Holiday</button>
        </form>
        <div id="holidayMessage" class="mt-2"></div>
    </div>
</div>

</c:if>
  
    <div id="departments-section" class="${activeTab == 'departments' ? '' : 'd-none'}">
        <h2 class="text-center text-dark mb-4">Departments</h2>
        
        <%-- Search Input (Top and Center) --%>
        <div class="search-bar-container text-center mb-3">
            <input type="text" id="searchInputDept" onkeyup="searchTable('dataTableDept', 'searchInputDept')" placeholder="Search..." class="form-control mx-auto">
        </div>

        <div class="table-controls-row d-flex flex-wrap justify-content-between align-items-center mb-3">
            <%-- Records per page (Left) --%>
           <div class="records-per-page-container d-flex align-items-center mb-2 mb-md-0">
    <label for="deptSize" class="form-label me-2 mb-0">Records per page:</label>
    <form id="deptPageSizeForm" method="get" action="${pageContext.request.contextPath}/admin-dashboard" class="d-inline-flex align-items-center">
        <select id="deptSize" name="deptSize" class="form-select form-select-sm me-2" style="width: 100px;" onchange="this.form.submit()">
            <option value="5" ${deptSize == 5 ? 'selected' : ''}>5</option>
            <option value="10" ${deptSize == 10 ? 'selected' : ''}>10</option>
            <option value="20" ${deptSize == 20 ? 'selected' : ''}>20</option>
            <option value="50" ${deptSize == 50 ? 'selected' : ''}>50</option>
            <option value="100" ${deptSize == 100 ? 'selected' : ''}>100</option>
        </select>
        <input type="hidden" name="deptPage" value="${deptCurrentPage}" />
        <input type="hidden" name="tab" value="departments" />
        <input type="hidden" name="deptSortField" value="${deptSortField}" />
        <input type="hidden" name="deptSortDir" value="${deptSortDir}" />
    </form>
</div>
            <div class="export-options">
    <a href="${pageContext.request.contextPath}/export/departments/excel" class="btn btn-success btn-sm" title="Export to Excel">
        <i class="bi bi-file-earmark-spreadsheet"></i> <span class="visually-hidden">Export to Excel</span>
    </a>

    <a href="${pageContext.request.contextPath}/export/departments/pdf" class="btn btn-danger btn-sm" title="Export to PDF">
        <i class="bi bi-file-earmark-pdf"></i> <span class="visually-hidden">Export to PDF</span>
    </a>
</div>
        </div>
       
        <div class="table-responsive">
            <table id="dataTableDept" class="table table-striped table-hover table-bordered shadow-sm">
                <thead class="table-primary">
                    <tr>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=departments&deptPage=${deptCurrentPage}&deptSize=${deptSize}&deptSortField=deptId&deptSortDir=${deptSortField eq 'deptId' and deptSortDir eq 'asc' ? 'desc' : 'asc'}">
                                ID
                                <c:if test="${deptSortField eq 'deptId'}">  <i class="fas fa-sort-${deptSortDir eq 'asc' ? 'up' : 'down'}"></i></c:if></a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=departments&deptPage=${deptCurrentPage}&deptSize=${deptSize}&deptSortField=name&deptSortDir=${deptSortField eq 'name' and deptSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Department Name
                                <c:if test="${deptSortField eq 'name'}"><i class="fas fa-sort-${deptSortDir eq 'asc' ? 'up' : 'down'}"></i>  </c:if></a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=departments&deptPage=${deptCurrentPage}&deptSize=${deptSize}&deptSortField=mail&deptSortDir=${deptSortField eq 'mail' and deptSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Email
                                <c:if test="${deptSortField eq 'mail'}">
                                    <i class="fas fa-sort-${deptSortDir eq 'mail' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=departments&deptPage=${deptCurrentPage}&deptSize=${deptSize}&deptSortField=createdDate&deptSortDir=${deptSortField eq 'createdDate' and deptSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Created Date
                                <c:if test="${deptSortField eq 'createdDate'}">
                                    <i class="fas fa-sort-${deptSortDir eq 'createdDate' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="dept" items="${departments}">
                        <tr>
                            <td>${dept.deptId}</td>
                            <td>${dept.name}</td>
                            <td>${dept.mail}</td>
                            <td>${dept.createdDate}</td>
                            <td>
                                <form action="${pageContext.request.contextPath}/deleteDepartment" method="post" class="d-inline">
                                    <input type="hidden" name="id" value="${dept.deptId}" />
                                    <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete this department?');">
                                        <i class="fas fa-trash-alt"></i> Delete
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <div class="pagination-container">
            <c:forEach begin="0" end="${deptTotalPages - 1}" var="i">
                <a href="${pageContext.request.contextPath}/admin-dashboard?deptPage=${i}&tab=departments&deptSize=${deptSize}&deptSortField=${deptSortField}&deptSortDir=${deptSortDir}"
                   class="${i == deptCurrentPage ? 'font-weight-bold' : ''}">
                    ${i + 1}
                </a>
            </c:forEach>
        </div>

        <%-- Add Department Button (moved here) --%>
        <div class="add-button-container">
            <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addDeptModal">
                <i class="fas fa-plus-circle me-2"></i>Add Department
            </button>
        </div>

        <div class="modal fade" id="addDeptModal" tabindex="-1" aria-labelledby="addDeptModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title" id="addDeptModalLabel">Add Department</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/addDepartment" method="post">
                        <div class="modal-body">
                            <div class="mb-3">
                                <label for="deptId" class="form-label">Department ID:</label>
                                <input type="number" class="form-control" id="deptId" name="deptId" required>
                            </div>
                            <div class="mb-3">
                                <label for="dept_name" class="form-label">Department Name:</label>
                                <input type="text" class="form-control" id="dept_name" name="name" required>
                            </div>
                            <div class="mb-3">
                                <label for="dept_mail" class="form-label">Email:</label>
                                <input type="email" class="form-control" id="dept_mail" name="mail" required>
                            </div>
                            <div class="mb-3">
                                <label for="dept_createdDate" class="form-label">Created Date:</label>
                                <input type="date" class="form-control" id="dept_createdDate" name="createdDate" required>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-success">Add Department</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div> 

    <div id="designations-section" class="${activeTab == 'designations' ? '' : 'd-none'}">
        <h2 class="text-center text-primary mb-4">Designations</h2>
        
        <%-- Search Input (Top and Center) --%>
        <div class="search-bar-container text-center mb-3">
            <input type="text" id="searchInputDesig" onkeyup="searchTable('dataTableDesig', 'searchInputDesig')" placeholder="Search..." class="form-control mx-auto">
        </div>

        <div class="table-controls-row d-flex flex-wrap justify-content-between align-items-center mb-3">
            <%-- Records per page (Left) --%>
            <div class="records-per-page-container d-flex align-items-center mb-2 mb-md-0">
    <label for="desigSize" class="form-label me-2 mb-0">Records per page:</label>
    <form id="desigPageSizeForm" method="get" action="${pageContext.request.contextPath}/admin-dashboard" class="d-inline-flex align-items-center">
        <select id="desigSize" name="desigSize" class="form-select form-select-sm me-2" style="width: 100px;" onchange="this.form.submit()">
            <option value="5" ${desigSize == 5 ? 'selected' : ''}>5</option>
            <option value="10" ${desigSize == 10 ? 'selected' : ''}>10</option>
            <option value="20" ${desigSize == 20 ? 'selected' : ''}>20</option>
            <option value="50" ${desigSize == 50 ? 'selected' : ''}>50</option>
            <option value="100" ${desigSize == 100 ? 'selected' : ''}>100</option>
        </select>
        <input type="hidden" name="desigPage" value="${desigCurrentPage}" />
        <input type="hidden" name="tab" value="designations" />
        <input type="hidden" name="desigSortField" value="${desigSortField}" />
        <input type="hidden" name="desigSortDir" value="${desigSortDir}" />
    </form>
</div>
            <div id="designations-section" class="${activeTab == 'designations' ? '' : 'd-none'}">
    <div class="export-options">
    <a href="${pageContext.request.contextPath}/export/designations/excel" class="btn btn-success btn-sm" title="Export to Excel">
        <i class="bi bi-file-earmark-spreadsheet"></i> <span class="visually-hidden">Export to Excel</span>
    </a>

    <a href="${pageContext.request.contextPath}/export/designations/pdf" class="btn btn-danger btn-sm" title="Export to PDF">
        <i class="bi bi-file-earmark-pdf"></i> <span class="visually-hidden">Export to PDF</span>
    </a>
</div>
    <table>
        </table>
</div>
        </div>
        
        <div class="table-responsive">
            <table id="dataTableDesig" class="table table-striped table-hover table-bordered shadow-sm">
                <thead class="table-primary">
                    <tr>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=designations&desigPage=${desigCurrentPage}&desigSize=${desigSize}&desigSortField=desigId&desigSortDir=${desigSortField eq 'desigId' and desigSortDir eq 'asc' ? 'desc' : 'asc'}">
                                ID
                                <c:if test="${desigSortField eq 'desigId'}">
                                    <i class="fas fa-sort-${desigSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=designations&desigPage=${desigCurrentPage}&desigSize=${desigSize}&desigSortField=title&desigSortDir=${desigSortField eq 'title' and desigSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Title
                                <c:if test="${desigSortField eq 'title'}">
                                    <i class="fas fa-sort-${desigSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=designations&desigPage=${desigCurrentPage}&desigSize=${desigSize}&desigSortField=dmail&desigSortDir=${desigSortDir eq 'dmail' and desigSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Mail
                                <c:if test="${desigSortField eq 'dmail'}">
                                    <i class="fas fa-sort-${desigSortDir eq 'dmail' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=designations&desigPage=${desigCurrentPage}&desigSize=${desigSize}&desigSortField=createdDate&desigSortDir=${desigSortField eq 'createdDate' and desigSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Created Date
                                <c:if test="${desigSortField eq 'createdDate'}">
                                    <i class="fas fa-sort-${desigSortDir eq 'createdDate' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="desig" items="${designations}">
                        <tr>
                            <td>${desig.desigId}</td>
                            <td>${desig.title}</td>
                            <td>${desig.dmail}</td>
                            <td>${desig.createdDate}</td>
                            <td>
                                <form action="${pageContext.request.contextPath}/deleteDesignation" method="post" class="d-inline">
                                    <input type="hidden" name="id" value="${desig.desigId}" />
                                    <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete this designation?');">
                                        <i class="fas fa-trash-alt"></i> Delete
                                    </button>
                                </form>
                            </td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <div class="pagination-container">
            <c:forEach begin="0" end="${desigTotalPages - 1}" var="i">
                <a href="${pageContext.request.contextPath}/admin-dashboard?desigPage=${i}&tab=designations&desigSize=${desigSize}&desigSortField=${desigSortField}&desigSortDir=${desigSortDir}"
                   class="${i == desigCurrentPage ? 'font-weight-bold' : ''}">
                    ${i + 1}
                </a>
            </c:forEach>
        </div>
        <%-- Add Designation Button (moved here) --%>
        <div class="add-button-container">
            <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addDesignationModal">
                <i class="fas fa-plus-circle me-2"></i>Add Designation
            </button>
        </div>
        <div class="modal fade" id="addDesignationModal" tabindex="-1" aria-labelledby="addDesignationModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title" id="addDesignationModalLabel">Add Designation</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="${pageContext.request.contextPath}/addDesignation" method="post">
                        <div class="modal-body">
                            <div class="mb-3">
                                <label for="desigId" class="form-label">Designation ID:</label>
                                <input type="number" class="form-control" id="desigId" name="desigId" required>
                            </div>
                            <div class="mb-3">
                                <label for="desig_title" class="form-label">Designation Name:</label>
                                <input type="text" class="form-control" id="desig_title" name="title" required>
                            </div>
                            <div class="mb-3">
                                <label for="desig_mail" class="form-label">Email:</label>
                                <input type="email" class="form-control" id="desig_mail" name="dmail" required>
                            </div>
                            <div class="mb-3">
                                <label for="desig_createdDate" class="form-label">Created Date:</label>
                                <input type="date" class="form-control" id="desig_createdDate" name="createdDate" required>
                            </div>
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-success">Add Designation</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
    <div id="employees-section" class="${activeTab == 'employees' ? '' : 'd-none'}">
   
            <h2 class="text-center text-primary mb-4">Employees</h2>

            <%-- Search Input (Top and Center) --%>
            <div class="search-bar-container text-center mb-3">
                <input type="text" id="searchInputEmp" onkeyup="searchTable('dataTableEmp', 'searchInputEmp')" placeholder="Search..." class="form-control mx-auto">
            </div>

            <div class="table-controls-row d-flex flex-wrap justify-content-between align-items-center mb-3">
                <%-- Records per page (Left) --%>
                <div class="records-per-page-container d-flex align-items-center mb-2 mb-md-0">
                    <label for="empSize" class="form-label me-2 mb-0">Records per page:</label>
                    <form id="empPageSizeForm" method="get" action="${pageContext.request.contextPath}/admin-dashboard" class="d-inline-flex align-items-center">
                        <select id="empSize" name="empSize" class="form-select form-select-sm me-2" style="width: 100px;" onchange="this.form.submit()">
                            <option value="5" ${empSize == 5 ? 'selected' : ''}>5</option>
                            <option value="10" ${empSize == 10 ? 'selected' : ''}>10</option>
                            <option value="20" ${empSize == 20 ? 'selected' : ''}>20</option>
                            <option value="50" ${empSize == 50 ? 'selected' : ''}>50</option>
                            <option value="100" ${empSize == 100 ? 'selected' : ''}>100</option>
                        </select>
                        <input type="hidden" name="empPage" value="${empCurrentPage}" />
                        <input type="hidden" name="tab" value="employees" />
                        <input type="hidden" name="empSortField" value="${empSortField}" />
                        <input type="hidden" name="empSortDir" value="${empSortDir}" />
                    </form>
                    
                </div>

                <%-- Export Options (Right) --%>
               <div class="export-options">
    <a href="${pageContext.request.contextPath}/export/employees/excel" class="btn btn-success btn-sm" title="Export to Excel">
        <i class="bi bi-file-earmark-spreadsheet"></i> <span class="visually-hidden">Export to Excel</span>
    </a>

    <a href="${pageContext.request.contextPath}/export/employees/pdf" class="btn btn-danger btn-sm" title="Export to PDF">
        <i class="bi bi-file-earmark-pdf"></i> <span class="visually-hidden">Export to PDF</span>
    </a>
</div>

            </div>
<div class="mb-3">
    <h5>Total Employees: <span class="text-primary">${totalEmployees}</span></h5>
</div>
            <div class="table-responsive">
                <table id="dataTableEmp" class="table table-striped table-hover table-bordered shadow-sm">
                    <thead class="table-primary">
                        <tr>
                            <th>
                                <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=empId&empSortDir=${empSortField eq 'empId' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                    ID
                                    <c:if test="${empSortField eq 'empId'}">
                                        <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                    </c:if>
                                </a>
                            </th>
                            <th>
                                <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=name&empSortDir=${empSortField eq 'name' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                    Name
                                    <c:if test="${empSortField eq 'name'}">
                                        <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                    </c:if>
                                </a>
                            </th>
                            <th>View Photo</th>
                            <th>
                                <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=email&empSortDir=${empSortField eq 'email' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                    Email
                                    <c:if test="${empSortField eq 'email'}">
                                        <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                    </c:if>
                                </a>
                            </th>
                            <th>
                                <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=phone&empSortDir=${empSortField eq 'phone' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                    Phone
                                    <c:if test="${empSortField eq 'phone'}">
                                        <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                    </c:if>
                                </a>
                            </th>
                            <th>
                                <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=hiredate&empSortDir=${empSortField eq 'hiredate' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                    Hire Date
                                    <c:if test="${empSortField eq 'hiredate'}">
                                        <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                    </c:if>
                                </a>
                            </th>
                            <th>
                                <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=firstName&empSortDir=${empSortField eq 'firstName' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                    First Name
                                    <c:if test="${empSortField eq 'firstName'}">
                                        <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                    </c:if>
                                </a>
                            </th>
                            <th>
                                <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=lastName&empSortDir=${empSortField eq 'lastName' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                    Last Name
                                    <c:if test="${empSortField eq 'lastName'}">
                                        <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                    </c:if>
                                </a>
                            </th>
                            <th>
                                <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=salary&empSortDir=${empSortField eq 'salary' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                    Salary
                                    <c:if test="${empSortField eq 'salary'}">
                                        <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                    </c:if>
                                </a>
                            </th>
                            <th>
                                <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees&empPage=${empCurrentPage}&amp;empSize=${empSize}&amp;empSortField=dept.name&amp;empSortDir=${empSortField eq 'dept.name' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                    Department
                                    <c:if test="${empSortField eq 'dept.name'}">
                                        <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                    </c:if>
                                </a>
                            </th>
                            <th>
                                <a href="${pageContext.request.contextPath}/admin-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=desig.title&empSortDir=${empSortField eq 'desig.title' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                    Designation
                                    <c:if test="${empSortField eq 'desig.title'}">
                                        <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                    </c:if>
                                </a>
                            </th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="emp" items="${employees}">
                            <tr>
                                <td>${emp.empId}</td>
                                <td>${emp.name}</td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty emp.photoUrl}">
                                            <a href="#" data-bs-toggle="modal" data-bs-target="#viewPhotoModal" onclick="showPhotoModal('${emp.photoUrl}', '${emp.name}')">View Photo</a>
                                        </c:when>
                                        <c:otherwise>No Photo</c:otherwise>
                                    </c:choose>
                                </td>
                                <td>${emp.email}</td>
                                <td>${emp.phone}</td>
                                <td>${emp.hiredate}</td>
                                <td>${emp.firstName}</td>
                                <td>${emp.lastName}</td>
                                <td>${emp.salary}</td>
                                <td>${emp.dept.name}</td>
                                <td>${emp.desig.title}</td>
                                <td>
                                    <form action="${pageContext.request.contextPath}/deleteEmployee" method="post" class="d-inline">
                                        <input type="hidden" name="id" value="${emp.empId}" />
                                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete this employee?');">
                                            <i class="fas fa-trash-alt"></i> 
                                        </button>
                                    </form>
                                    <a href="#" class="btn btn-primary btn-sm" data-bs-toggle="modal" data-bs-target="#uploadPhotoModal" onclick="setUploadPhotoId(${emp.empId})">
                                        <i class="fas fa-upload"></i> 
                                    </a>
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>

            <%-- Photo View Modal --%>
            <div class="modal fade" id="viewPhotoModal" tabindex="-1" aria-labelledby="viewPhotoModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title" id="viewPhotoModalLabel">Employee Photo</h5>
                            <!--  <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>-->
                        </div>
                        <div class="modal-body text-center">
                            <img id="employeePhoto" src="" alt="Employee Photo" style="max-width: 100%; max-height: 400px;" />
                        </div>
                        <div class="modal-footer">
                            <!--  <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>-->
                        </div>
                    </div>
                </div>
            </div>

            <%-- Photo Upload Modal --%>
            <div class="modal fade" id="uploadPhotoModal" tabindex="-1" aria-labelledby="uploadPhotoModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header bg-primary text-white">
                            <h5 class="modal-title" id="uploadPhotoModalLabel">Upload Employee Photo</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <form action="${pageContext.request.contextPath}/employee/upload-photo" method="post" enctype="multipart/form-data">
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label for="empId" class="form-label">Employee ID:</label>
                                    <input type="text" class="form-control" id="uploadEmpId" name="empId" readonly>
                                </div>
                                <div class="mb-3">
                                    <label for="file" class="form-label">Select Photo:</label>
                                    <input type="file" class="form-control" id="file" name="file" accept="image/*" required>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                <button type="submit" class="btn btn-primary">Upload</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>

            <%-- Pagination --%>
            <div class="pagination-container">
                <c:set var="maxPagesToShow" value="7"/>
                <c:set var="startPage" value="${0}"/>
                <c:set var="endPage" value="${empTotalPages - 1}"/>

                <%-- Previous Link --%>
                <c:if test="${empCurrentPage > 0}">
                    <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${empCurrentPage - 1}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}">
                        Previous
                    </a>
                </c:if>

                <%-- Always show first page --%>
                <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=0&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}"
                   class="${0 == empCurrentPage ? 'font-weight-bold' : ''}">
                    1
                </a>

                <%-- Display first few pages or dots --%>
                <c:choose>
                    <c:when test="${empTotalPages <= maxPagesToShow}">
                        <c:forEach begin="1" end="${empTotalPages - 1}" var="i">
                            <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${i}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}"
                               class="${i == empCurrentPage ? 'font-weight-bold' : ''}">
                                ${i + 1}
                            </a>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <c:forEach begin="1" end="${(empTotalPages > 3 ? 2 : empTotalPages -1)}" var="i">
                            <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${i}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}"
                               class="${i == empCurrentPage ? 'font-weight-bold' : ''}">
                                ${i + 1}
                            </a>
                        </c:forEach>

                        <c:if test="${empCurrentPage >= 3 && empCurrentPage <= empTotalPages - 4}">
                            <span>...</span>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${empCurrentPage - 1}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}">
                                ${empCurrentPage}
                            </a>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${empCurrentPage}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}"
                               class="font-weight-bold">
                                ${empCurrentPage + 1}
                            </a>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${empCurrentPage + 1}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}">
                                ${empCurrentPage + 2}
                            </a>
                            <span>...</span>
                        </c:if>

                        <c:if test="${empCurrentPage < 3 || empCurrentPage > empTotalPages - 4}">
                            <c:if test="${empTotalPages > maxPagesToShow}">
                                <span>...</span>
                            </c:if>
                        </c:if>

                        <c:forEach begin="${(empTotalPages > 3 ? empTotalPages - 3 : empTotalPages)}" end="${empTotalPages - 1}" var="i">
                            <c:if test="${i > 0}">
                                <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${i}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}"
                                   class="${i == empCurrentPage ? 'font-weight-bold' : ''}">
                                    ${i + 1}
                                </a>
                            </c:if>
                        </c:forEach>
                    </c:otherwise>
                </c:choose>

                <%-- Next Link --%>
                <c:if test="${empCurrentPage < empTotalPages - 1}">
                    <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${empCurrentPage + 1}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}">
                        Next
                    </a>
                </c:if>
            </div>

            <%-- Add Employee Button --%>
            <div class="add-button-container">
                <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addEmployeeModal">
                    <i class="fas fa-plus-circle me-2"></i>Add Employee
                </button>
            </div>

            <%-- Add Employee Modal --%>
            <div class="modal fade" id="addEmployeeModal" tabindex="-1" aria-labelledby="addEmployeeModalLabel" aria-hidden="true">
                <div class="modal-dialog">
                    <div class="modal-content">
                        <div class="modal-header bg-success text-white">
                            <h5 class="modal-title" id="addEmployeeModalLabel">Add Employee</h5>
                            <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                        </div>
                        <form action="${pageContext.request.contextPath}/addEmployee" method="post" enctype="multipart/form-data">
                            <div class="modal-body">
                                <div class="mb-3">
                                    <label for="empId" class="form-label">Employee ID:</label>
                                    <input type="text" class="form-control" id="empId" name="empId" required>
                                </div>
                                <div class="mb-3">
                                    <label for="emp_name" class="form-label">Name:</label>
                                    <input type="text" class="form-control" id="emp_name" name="name" required>
                                </div>
                                <div class="mb-3">
                                    <label for="emp_email" class="form-label">Email:</label>
                                    <input type="email" class="form-control" id="emp_email" name="email" required>
                                </div>
                                <div class="mb-3">
                                    <label for="emp_phone" class="form-label">Phone:</label>
                                    <input type="text" class="form-control" id="emp_phone" name="phone" required>
                                </div>
                                <div class="mb-3">
                                    <label for="emp_hiredate" class="form-label">Hire Date:</label>
                                    <input type="date" class="form-control" id="emp_hiredate" name="hiredate" required>
                                </div>
                                <div class="mb-3">
                                    <label for="emp_firstName" class="form-label">First Name:</label>
                                    <input type="text" class="form-control" id="emp_firstName" name="firstName" required>
                                </div>
                                <div class="mb-3">
                                    <label for="emp_lastName" class="form-label">Last Name:</label>
                                    <input type="text" class="form-control" id="emp_lastName" name="lastName" required>
                                </div>
                                <div class="mb-3">
                                    <label for="emp_salary" class="form-label">Salary:</label>
                                    <input type="number" class="form-control" id="emp_salary" name="salary" required>
                                </div>
                                <div class="mb-3">
                                    <label for="emp_accountNumber" class="form-label">Account Number:</label>
                                    <input type="text" class="form-control" id="emp_accountNumber" name="accountNumber" required>
                                </div>
                                <div class="mb-3">
                                    <label for="emp_deptId" class="form-label">Department:</label>
                                    <select class="form-select" id="emp_deptId" name="deptId" required>
                                        <option value="">-- Select Department --</option>
                                        <c:forEach var="dept" items="${departments}">
                                            <option value="${dept.deptId}">${dept.name}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="emp_desigId" class="form-label">Designation:</label>
                                    <select class="form-select" id="emp_desigId" name="desigId" required>
                                        <option value="">-- Select Designation --</option>
                                        <c:forEach var="desig" items="${designations}">
                                            <option value="${desig.desigId}">${desig.title}</option>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="mb-3">
                                    <label for="file" class="form-label">Photo:</label>
                                   <input type="file" class="form-control" id="file" name="file" accept=".jpg,.jpeg,.png,.gif,.webp" required>
                                </div>
                            </div>
                            <div class="modal-footer">
                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                <button type="submit" class="btn btn-success">Add Employee</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
       
    </div>
    <div id="users-section" class="${activeTab == 'users' ? '' : 'd-none'}">
        <h2 class="text-center text-primary mb-4">Users</h2>

        <%-- Search Input (Top and Center) --%>
        <div class="search-bar-container text-center mb-3">
            <input type="text" id="searchInputUser" onkeyup="searchTable('dataTableUser', 'searchInputUser')" placeholder="Search..." class="form-control mx-auto">
        </div>

        <div class="table-controls-row d-flex flex-wrap justify-content-between align-items-center mb-3">
            <%-- Records per page (Left) --%>
           <div class="records-per-page-container d-flex align-items-center mb-2 mb-md-0">
    <label for="userSize" class="form-label me-2 mb-0">Records per page:</label>
    <form id="userPageSizeForm" method="get" action="${pageContext.request.contextPath}/admin-dashboard" class="d-inline-flex align-items-center">
        <select id="userSize" name="userSize" class="form-select form-select-sm me-2" style="width: 100px;" onchange="this.form.submit()">
            <option value="5" ${userSize == 5 ? 'selected' : ''}>5</option>
            <option value="10" ${userSize == 10 ? 'selected' : ''}>10</option>
            <option value="20" ${userSize == 20 ? 'selected' : ''}>20</option>
            <option value="50" ${userSize == 50 ? 'selected' : ''}>50</option>
            <option value="100" ${userSize == 100 ? 'selected' : ''}>100</option>
        </select>
        <input type="hidden" name="userPage" value="${userCurrentPage}" />
        <input type="hidden" name="tab" value="users" />
        <input type="hidden" name="userSortField" value="${userSortField}" />
        <input type="hidden" name="userSortDir" value="${userSortDir}" />
    </form>
    
</div>
<div id="users-section" class="${activeTab == 'users' ? '' : 'd-none'}">
    <div class="export-options">
    <a href="${pageContext.request.contextPath}/export/users/excel" class="btn btn-success btn-sm" title="Export to Excel"><i class="bi bi-file-earmark-spreadsheet"></i> <span class="visually-hidden">Export to Excel</span></a>
    <a href="${pageContext.request.contextPath}/export/users/pdf" class="btn btn-danger btn-sm" title="Export to PDF">        <i class="bi bi-file-earmark-pdf"></i> <span class="visually-hidden">Export to PDF</span></a>
</div></div>  </div>
        
        <div class="table-responsive">
            <table id="dataTableUser" class="table table-striped table-hover table-bordered shadow-sm">
                <thead class="table-primary">
                    <tr>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=users&userPage=${userCurrentPage}&userSize=${userSize}&userSortField=userId&userSortDir=${userSortField eq 'userId' and userSortDir eq 'asc' ? 'desc' : 'asc'}">
                                ID<c:if test="${userSortField eq 'userId'}"><i class="fas fa-sort-${userSortDir eq 'asc' ? 'up' : 'down'}"></i></c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=users&userPage=${userCurrentPage}&userSize=${userSize}&userSortField=username&userSortDir=${userSortField eq 'username' and userSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Username<c:if test="${userSortField eq 'username'}"><i class="fas fa-sort-${userSortDir eq 'username' ? 'up' : 'down'}"></i></c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=users&userPage=${userCurrentPage}&userSize=${userSize}&userSortField=email&userSortDir=${userSortField eq 'email' and userSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Email<c:if test="${userSortField eq 'email'}"><i class="fas fa-sort-${userSortDir eq 'email' ? 'up' : 'down'}"></i></c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=users&userPage=${userCurrentPage}&userSize=${userSize}&userSortField=role&userSortDir=${userSortField eq 'role' and userSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Role<c:if test="${userSortField eq 'role'}"><i class="fas fa-sort-${userSortDir eq 'role' ? 'up' : 'down'}"></i></c:if>
                            </a>
                        </th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="user" items="${users}">
                        <tr>
                            <td>${user.userId}</td>
                            <td>${user.username}</td>
                            <td>${user.email}</td>
                            <td>${user.role}</td>
                            <td>
                                <c:if test="${user.role ne 'admin'}">
                                    <form method="post" action="${pageContext.request.contextPath}/delete-user" class="d-inline">
                                        <input type="hidden" name="id" value="${user.userId}" />
                                        <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Are you sure you want to delete this user?');">
                                            <i class="fas fa-trash-alt"></i> Delete
                                        </button>
                                    </form></c:if></td></tr></c:forEach></tbody></table></div>
        <div class="pagination-container">
            <c:forEach begin="0" end="${userTotalPages - 1}" var="i">
                <a href="${pageContext.request.contextPath}/admin-dashboard?userPage=${i}&tab=users&userSize=${userSize}&userSortField=${userSortField}&userSortDir=${userSortDir}"
                   class="${i == userCurrentPage ? 'font-weight-bold' : ''}">
                    ${i + 1}
                </a>
            </c:forEach>
        </div>
        <%-- Add User Button (moved here) --%>
        <div class="add-button-container">
            <button type="button" class="btn btn-success" data-bs-toggle="modal" data-bs-target="#addUserModal">
                <i class="fas fa-plus-circle me-2"></i>Add User
            </button>
        </div>

        <div class="modal fade" id="addUserModal" tabindex="-1" aria-labelledby="addUserModalLabel" aria-hidden="true">
            <div class="modal-dialog">
                <div class="modal-content">
                    <div class="modal-header bg-success text-white">
                        <h5 class="modal-title" id="addUserModalLabel">Add User</h5>
                        <button type="button" class="btn-close btn-close-white" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form method="post" action="${pageContext.request.contextPath}/add-user">
                        <div class="modal-body">
    <%-- Auto-suggest Employee field --%>
    <div class="mb-3 position-relative">
        <label for="employeeSuggest" class="form-label">Link to Employee:</label>
        <input type="text" class="form-control" id="employeeSuggest" placeholder="Search by ID, Name or Email">
        <ul id="employeeSuggestions" class="list-group position-absolute w-100 z-3" style="top: 100%; max-height: 200px; overflow-y: auto;"></ul>
       <input type="number" class="form-control" id="employeeId" name="employeeId" placeholder="Enter Employee ID" required>
        <small class="form-text text-muted">This links a user to an employee record.</small>
    </div>

    <div class="mb-3">
        <label for="username" class="form-label">Username:</label>
        <input type="text" class="form-control" id="username" name="username" required>
    </div>

    <div class="mb-3">
        <label for="user_email" class="form-label">Email:</label>
        <input type="email" class="form-control" id="user_email" name="email" required>
    </div>

    <div class="mb-3">
        <label for="user_role" class="form-label">Role:</label>
        <select class="form-select" id="user_role" name="role" required>
            <option value="">-- Select Role --</option>
            <option value="admin">Admin</option>
            <option value="employee">Employee</option>
        </select>
    </div>

    <div class="mb-3">
        <label for="user_password" class="form-label">Password:</label>
        <input type="password" class="form-control" id="user_password" name="password" required>
    </div>
</div>

                        <div class="modal-footer">
                            <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                            <button type="submit" class="btn btn-success">Add User</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
<div id="admin-leave-section" class="${activeTab == 'leaves' ? '' : 'd-none'}">
    <h4 class="mt-4">Leave Requests</h4>
    <table class="table table-bordered table-hover">
        <thead>
            <tr>
                <th>Employee</th>
                <th>Date Range</th>
                <th>Reason</th>
                <th>Status</th>
                <th>Action</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${leaveRequests}" var="leave">
                <tr>
                    <td>${leave.employee.name}</td>
                    <td>${leave.startDate} to ${leave.endDate}</td>
                    <td>${leave.reason}</td>
                    <td>${leave.status}</td>
                    <td>
                        <c:if test="${leave.status == 'PENDING'}">
                            <form method="post" action="${pageContext.request.contextPath}/admin/handle-leave">
                                <input type="hidden" name="requestId" value="${leave.id}" />
                                <button name="action" value="approve" class="btn btn-success btn-sm">Approve</button>
                                <button name="action" value="reject" class="btn btn-danger btn-sm">Reject</button>
                            </form>
                        </c:if>
                        <c:if test="${leave.status != 'Pending'}">
                            <span class="text-muted">${leave.status}</span>
                        </c:if>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>
<div id="statistics-section" class="${activeTab == 'statistics' ? '' : 'd-none'} container mt-4">

    <h3 class="mb-4 text-center text-primary">📊 Employee Attendance Statistics</h3>

    <form method="get" action="${pageContext.request.contextPath}/admin-dashboard" class="row g-3 mb-3">
        <input type="hidden" name="tab" value="statistics" />

        <div class="col-md-4 position-relative">
            <input type="text" class="form-control" id="employeeQueryInput" name="employeeQuery"
                   value="${param.employeeQuery}" placeholder="Search by ID, Name, or Email" autocomplete="off" />
            <div id="employeeSuggestions" class="list-group position-absolute w-100 z-3"></div>
        </div>

        <div class="col-md-2">
            <select name="periodd" class="form-select" onchange="this.form.submit()">
                <option value="month" ${periodd == 'month' ? 'selected' : ''}>This Month</option>
                <option value="year" ${periodd == 'year' ? 'selected' : ''}>This Year</option>
            </select>
        </div>

        <div class="col-md-2">
            <input type="date" name="selectedDate" class="form-control" value="${selectedDate}" onchange="this.form.submit()" />
        </div>

        <div class="col-md-2">
            <button type="submit" class="btn btn-primary">🔍 View</button>
        </div>
    </form>

    <!-- Show cards only when a valid employee is searched -->
    <c:if test="${not empty selectedEmployee and not empty param.employeeQuery}">
        <div class="row mb-4">
            <div class="col-md-4">
                <div class="card shadow-sm p-3 border-success">
                    <h5 class="text-success">✅ Present Days (${periodd})</h5>
                    <p class="fs-4 fw-bold">${presentDays} / ${totalWorkingDays}</p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card shadow-sm p-3 border-danger">
                    <h5 class="text-danger">🛌 Leaves Taken (${periodd})</h5>
                    <p class="fs-4 fw-bold">${leavesTaken}</p>
                </div>
            </div>

            <div class="col-md-4">
                <div class="card shadow-sm p-3 border-info">
                    <h5 class="text-info">🕒 Check-in/Out (${selectedDate})</h5>
                    <p class="mb-1">Check-in: <strong>${checkInTime != null ? checkInTime : '—'}</strong></p>
                    <p>Check-out: <strong>${checkOutTime != null ? checkOutTime : '—'}</strong></p>
                </div>
            </div>
        </div>

        <!-- Leave Requests Table -->
        <c:if test="${not empty leaveRequests}">
            <div class="card shadow-sm p-4">
                <h5 class="text-primary">📄 Leave Requests</h5>
                <div class="table-responsive">
                    <table class="table table-bordered table-hover mt-3">
                        <thead class="table-light">
                            <tr>
                                <th>Start Date</th>
                                <th>End Date</th>
                                <th>Reason</th>
                                <th>Status</th>
                                <th>Applied On</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="lr" items="${leaveRequests}">
                                <tr>
                                    <td>${lr.startDate}</td>
                                    <td>${lr.endDate}</td>
                                    <td>${lr.reason}</td>
                                    <td class="fw-bold ${lr.status == 'Accepted' ? 'text-success' : (lr.status == 'Rejected' ? 'text-danger' : 'text-warning')}">
                                        ${lr.status}
                                    </td>
                                    <td>${lr.requestDate}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </div>
        </c:if>
    </c:if>

    <!-- Optional: No match warning -->
    <c:if test="${empty selectedEmployee and not empty param.employeeQuery}">
        <div class="alert alert-warning text-center">No employee matched your search.</div>
    </c:if>

</div>

    <div id="salaries-section" class="${activeTab == 'salaries' ? '' : 'd-none'}">
        <h3 class="text-center text-primary my-4">
            <i class="fas fa-money-bill-wave me-2"></i>Salary Details
        </h3>
        <%-- Search Input (Top and Center) --%>
        <div class="search-bar-container text-center mb-3">
            <input type="text" id="salarySearch" onkeyup="searchTable('salaryTable', 'salarySearch')" placeholder="Search Salary..." class="form-control mx-auto">
        </div>

        <div class="table-controls-row d-flex flex-wrap justify-content-between align-items-center mb-3">
            <%-- Records per page (Left) --%>
           <div class="records-per-page-container d-flex align-items-center mb-2 mb-md-0">
    <label for="salarySize" class="form-label me-2 mb-0">Records per page:</label>
    <form id="salaryPageSizeForm" method="get" action="${pageContext.request.contextPath}/admin-dashboard" class="d-inline-flex align-items-center">
        <select id="salarySize" name="empSize" class="form-select form-select-sm me-2" style="width: 100px;" onchange="this.form.submit()">
            <option value="5" ${empSize == 5 ? 'selected' : ''}>5</option>
            <option value="10" ${empSize == 10 ? 'selected' : ''}>10</option>
            <option value="20" ${empSize == 20 ? 'selected' : ''}>20</option>
            <option value="50" ${empSize == 50 ? 'selected' : ''}>50</option>
            <option value="100" ${empSize == 100 ? 'selected' : ''}>100</option>
        </select>
        <input type="hidden" name="empPage" value="${empCurrentPage}" />
        <input type="hidden" name="tab" value="salaries" />
        <input type="hidden" name="empSortField" value="${empSortField}" />
        <input type="hidden" name="empSortDir" value="${empSortDir}" />
    </form>
</div>        
        </div>
        <div class="table-responsive">
            <table id="salaryTable" class="table table-striped table-hover table-bordered shadow-sm">
                <thead class="table-primary">
                    <tr>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=salaries&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=empId&empSortDir=${empSortField eq 'empId' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Employee ID
                                <c:if test="${empSortField eq 'empId'}">
                                    <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=salaries&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=accountNumber&empSortDir=${empSortField eq 'accountNumber' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Account Number
                                <c:if test="${empSortField eq 'accountNumber'}">
                                    <i class="fas fa-sort-${empSortDir eq 'accountNumber' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=salaries&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=name&empSortDir=${empSortField eq 'name' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Employee Name
                                <c:if test="${empSortField eq 'name'}">
                                    <i class="fas fa-sort-${empSortDir eq 'name' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/admin-dashboard?tab=salaries&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=salary&empSortDir=${empSortField eq 'salary' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Salary
                                <c:if test="${empSortField eq 'salary'}">
                                    <i class="fas fa-sort-${empSortDir eq 'salary' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="emp" items="${employees}">
                        <tr>
                            <td>${emp.empId}</td>
                            <td>${emp.accountNumber}</td>
                            <td>${emp.name}</td>
                            <td>${emp.salary}</td>
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

       <div class="pagination-container">

    <c:set var="maxPagesToShow" value="7"/> <%-- e.g., 3 start + dots + 3 end + current --%>
    <c:set var="startPage" value="${0}"/>
   <c:set var="endPage" value="${empTotalPages - 1}"/>
    <%-- Previous Link --%>
    <c:if test="${empCurrentPage > 0}">
        <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${empCurrentPage - 1}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}">
            Previous</a>
    </c:if>
   <%-- Always show first page --%>
    <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=0&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}"
       class="${0 == empCurrentPage ? 'font-weight-bold' : ''}">
        1
    </a>
    <%-- Display first few pages or dots --%>
    <c:choose>
        <c:when test="${empTotalPages <= maxPagesToShow}">
            <%-- If total pages are few, display all of them after the first --%>
            <c:forEach begin="1" end="${empTotalPages - 1}" var="i">
                <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${i}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}"
                   class="${i == empCurrentPage ? 'font-weight-bold' : ''}">
                    ${i + 1}
                </a>
            </c:forEach>
        </c:when>
        <c:otherwise>
            <%-- More pages, show first few, then dots, then last few --%>

            <%-- First three pages (or fewer if total pages less than 3) --%>
            <c:forEach begin="1" end="${(empTotalPages > 3 ? 2 : empTotalPages -1)}" var="i">
                <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${i}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}"
                   class="${i == empCurrentPage ? 'font-weight-bold' : ''}">
                    ${i + 1}
                </a>
            </c:forEach>
            <%-- Dots for middle pages --%>
            <c:if test="${empCurrentPage >= 3 && empCurrentPage <= empTotalPages - 4}">
                <%-- If current page is in the middle, show it with surrounding pages --%>
                <span>...</span>
                <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${empCurrentPage - 1}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}">
                    ${empCurrentPage}
                </a>
                <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${empCurrentPage}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}"
                   class="font-weight-bold">
                    ${empCurrentPage + 1}
                </a>
                <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${empCurrentPage + 1}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}">
                    ${empCurrentPage + 2}
                </a>
                <span>...</span>
            </c:if>
            <c:if test="${empCurrentPage < 3 || empCurrentPage > empTotalPages - 4}">
                <%-- If not in the middle, just dots between first and last groups --%>
                <c:if test="${empTotalPages > maxPagesToShow}">
                    <span>...</span>
                </c:if>
            </c:if>
            <%-- Last three pages (or fewer if total pages less than 3 from end) --%>
            <c:forEach begin="${(empTotalPages > 3 ? empTotalPages - 3 : empTotalPages)}" end="${empTotalPages - 1}" var="i">
                 <c:if test="${i > 0}"> <%-- To prevent displaying page 1 again if total pages < 3 --%>

                    <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${i}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}"

                       class="${i == empCurrentPage ? 'font-weight-bold' : ''}">
                        ${i + 1}
                    </a>
                </c:if>
            </c:forEach>
        </c:otherwise>
    </c:choose>
    <%-- Next Link --%>
    <c:if test="${empCurrentPage < empTotalPages - 1}">
        <a href="${pageContext.request.contextPath}/admin-dashboard?empPage=${empCurrentPage + 1}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}">
            Next
        </a>
    </c:if>
</div>
    </div>
</div> 
<div class="footer">
    Address: Kavuri Hills, Madhapur, Hyderabad, India | Phone: +91-9876543210
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
<script>
    // Generic search function for tables
    function searchTable(tableId, inputId) {
        const input = document.getElementById(inputId);
        const filter = input.value.toUpperCase();
        const table = document.getElementById(tableId);
        const trs = table.getElementsByTagName("tr");

        // Loop through all table rows, and hide those who don't match the search query
        for (let i = 1; i < trs.length; i++) { // Start from 1 to skip the header row
            let showRow = false;
            const tds = trs[i].getElementsByTagName("td");
            for (let j = 0; j < tds.length; j++) {
                const cell = tds[j];
                if (cell) {
                    if (cell.innerText.toUpperCase().indexOf(filter) > -1) {
                        showRow = true;
                        break;
                    }
                }
            }
            trs[i].style.display = showRow ? "" : "none";
        }
    }

    // Function to handle the opening of a modal by ID
    function openPopup(modalId) {
        var myModal = new bootstrap.Modal(document.getElementById(modalId));
        myModal.show();
    }

    // Function to close a modal by ID via JS (e.g., if needed after an AJAX submission)
    function closePopup(modalId) {
        var myModalEl = document.getElementById(modalId);
        var modal = bootstrap.Modal.getInstance(myModalEl);
        if (modal) {
            modal.hide();
        }
    }

    // This part is for showing the correct tab section based on URL parameter
    document.addEventListener('DOMContentLoaded', function() {
        const urlParams = new URLSearchParams(window.location.search);
        const activeTab = urlParams.get('tab');
        
        if (activeTab) {
            // Show the specific section if a tab is specified in the URL
            const targetSection = document.getElementById(activeTab + '-section');
            if (targetSection) {
                targetSection.classList.remove('d-none');
            }
        } 
        // If no tab is specified, default to 'departments'
        else {
            const defaultSection = document.getElementById();
            if (defaultSection) {
                defaultSection.classList.remove('d-none');
            }
        }
        
        // This is important for opening modals based on server-side 'openPopup' message
        const serverPopup = '${openPopup}';
        if (serverPopup && serverPopup !== 'null' && serverPopup !== '') {
            const popupEl = document.getElementById(serverPopup);
            if (popupEl) {
                var myModal = new bootstrap.Modal(popupEl);
                myModal.show();
            }
        }
    });
    
    function showPhotoModal(url, name) {
        document.getElementById('employeePhoto').src = url;
        document.getElementById('viewPhotoModalLabel').textContent = 'Photo of ' + name;
        var modal = new bootstrap.Modal(document.getElementById('viewPhotoModal'));
        modal.show();
    }

    function setUploadPhotoId(empId) {
        document.getElementById('uploadEmpId').value = empId;
    }

</script>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
<script>
    const contextPath = '${pageContext.request.contextPath}';
    let currentDate = new Date(); // Stores the current month being viewed
    let customHolidays = []; // Will store holidays fetched from the backend

    // --- Announcement Data (MUST BE BEFORE DOMContentLoaded if used by a function called inside) ---
    // This data embedding should remain at the top, outside of DOMContentLoaded,
    // so it's available as soon as the script parses.
    const activeAnnouncementsData = [
        <c:forEach var="announcement" items="${activeAnnouncements}" varStatus="loop">
            {
                "message": "${fn:escapeXml(announcement.message)}",
                "createdAt": "${announcement.createdAt}"
            }<c:if test="${!loop.last}">,</c:if>
        </c:forEach>
    ];
    // --- End Announcement Data ---


    // Function to toggle calendar visibility and render it
    function showCalendar() {
        const calendarSection = document.getElementById('calendar-section');
        if (calendarSection.style.display === 'none' || calendarSection.style.display === '') {
            calendarSection.style.display = 'block';
            fetchHolidaysAndRender(); // Fetch and render when shown
        } else {
            calendarSection.style.display = 'none';
        }
    }

    // Function to fetch holidays and then render the calendar
    async function fetchHolidaysAndRender() {
        const year = currentDate.getFullYear();
        const month = currentDate.getMonth() + 1; // Months are 0-indexed in JS, API expects 1-indexed

        try {
            const response = await fetch(contextPath + '/api/holidays?year=' + year + '&month=' + month);
            if (!response.ok) {
                throw new Error(`HTTP error! status: ${response.status}`);
            }
            customHolidays = await response.json();
            console.log("Fetched holidays:", customHolidays); // Debugging: Log the holidays
        } catch (error) {
            console.error("Error fetching holidays:", error);
            customHolidays = []; // Clear holidays on error
        }
        renderCalendar(); // Render calendar after fetching
    }

    function renderCalendar() {
        const calendarDays = document.getElementById('calendar-days');
        const monthYear = document.getElementById('calendar-month-year');
        const year = currentDate.getFullYear();
        const month = currentDate.getMonth(); // 0-indexed month
        const firstDay = new Date(year, month, 1);
        const lastDay = new Date(year, month + 1, 0);
        const daysInMonth = lastDay.getDate();
        const startingDayIndex = firstDay.getDay(); // 0 for Sunday, 1 for Monday, etc.

        monthYear.textContent = currentDate.toLocaleString('default', { month: 'long', year: 'numeric' });
        calendarDays.innerHTML = ''; // Clear previous days

        // Add day names
        const days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
        days.forEach(day => {
            const dayElement = document.createElement('div');
            dayElement.className = 'calendar-day day-name';
            dayElement.textContent = day;
            calendarDays.appendChild(dayElement);
        });

        // Add empty cells for days before the first of the month
        for (let i = 0; i < startingDayIndex; i++) {
            const emptyDay = document.createElement('div');
            emptyDay.className = 'calendar-day';
            calendarDays.appendChild(emptyDay);
        }

        // Add days of the month
        for (let day = 1; day <= daysInMonth; day++) {
            const dayElement = document.createElement('div');
            dayElement.className = 'calendar-day';
            const currentDayDate = new Date(year, month, day);
            dayElement.textContent = day;

            let isHoliday = false;
            let tooltipText = 'Working Day'; // Default tooltip

            // Check for default holidays: Sunday (0) and Second Saturday (6)
            const weekDay = currentDayDate.getDay();
            const weekOfMonth = Math.floor((day + startingDayIndex - 1) / 7) + 1; // 1-indexed week of month

            if (weekDay === 0) { // Sunday
                isHoliday = true;
                tooltipText = 'Sunday Holiday';
            } else if (weekDay === 6 && weekOfMonth === 2) { // Second Saturday
                isHoliday = true;
                tooltipText = 'Second Saturday Holiday';
            }

            // Check for custom declared holidays
            const currentDayFormatted = year + '-' +
                String(month + 1).padStart(2, '0') + '-' +
                String(day).padStart(2, '0');

            const foundCustomHoliday = customHolidays.find(h => {
                const holidayDateStr = h.date ? h.date.split('T')[0] : '';
                console.log(`Comparing ${currentDayFormatted} with ${holidayDateStr}`);
                return holidayDateStr === currentDayFormatted;
            });

            if (foundCustomHoliday) {
                isHoliday = true;
                tooltipText = foundCustomHoliday.description || 'Custom Holiday';
                console.log(`Custom holiday matched for ${currentDayFormatted}:`, foundCustomHoliday);
            }

            // Apply classes based on holiday status
            if (isHoliday) {
                dayElement.classList.add('holiday'); // Apply red styling for holidays
            }

            // Highlight today's date
            if (currentDayDate.toDateString() === new Date().toDateString()) {
                dayElement.classList.add('today');
            }

            dayElement.title = tooltipText; // Set tooltip
            calendarDays.appendChild(dayElement);
        }
    }

    function previousMonth() {
        currentDate.setMonth(currentDate.getMonth() - 1);
        fetchHolidaysAndRender(); // Fetch and re-render for new month
    }

    function nextMonth() {
        currentDate.setMonth(currentDate.getMonth() + 1);
        fetchHolidaysAndRender(); // Fetch and re-render for new month
    }

    async function declareHoliday(event) {
        event.preventDefault();
        const holidayDate = document.getElementById('holidayDate').value;
        const holidayReason = document.getElementById('holidayReason').value;
        const holidayMessageDiv = document.getElementById('holidayMessage');

        if (!holidayDate || !holidayReason) {
            holidayMessageDiv.textContent = 'Please select a date and enter a reason.';
            holidayMessageDiv.className = 'text-danger';
            return;
        }

        try {
            const response = await fetch(contextPath + '/declare-holiday', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'date=' + encodeURIComponent(holidayDate) + '&description=' + encodeURIComponent(holidayReason)
            });

            const data = await response.json(); // Assuming backend returns JSON
            if (data.success) {
                holidayMessageDiv.textContent = 'Holiday declared successfully!';
                holidayMessageDiv.className = 'text-success';
                document.getElementById('holidayDate').value = ''; // Clear form
                document.getElementById('holidayReason').value = ''; // Clear form
                await fetchHolidaysAndRender(); // Re-fetch and re-render calendar
            } else {
                holidayMessageDiv.textContent = data.message || 'Failed to declare holiday.';
                holidayMessageDiv.className = 'text-danger';
            }
        } catch (error) {
            console.error('Error declaring holiday:', error);
            holidayMessageDiv.textContent = 'Error communicating with server: ' + error.message;
            holidayMessageDiv.className = 'text-danger';
        }
    }
    // --- CONSOLIDATED DOMContentLoaded Listener ---
    document.addEventListener('DOMContentLoaded', () => {
        // Calendar Initialization
        const calendarSection = document.getElementById('calendar-section');
        if (calendarSection) {
            calendarSection.style.display = 'none'; // Hide calendar by default
        }
        // --- Announcement Scroller JavaScript (One-by-One Display) ---
        const announcementDisplay = document.getElementById('currentAnnouncementMessage');
        let currentAnnouncementIndex = 0;
        let announcementInterval;

        function displayNextAnnouncement() {
            if (!announcementDisplay) {
                console.error("Announcement display element (currentAnnouncementMessage) not found.");
                return;
            }
            if (activeAnnouncementsData.length === 0) {
                announcementDisplay.textContent = "No new announcements at this time.";
                announcementDisplay.style.opacity = 1;
                return;
            }
            announcementDisplay.style.opacity = 0; // Fade out
            setTimeout(() => {
                const announcement = activeAnnouncementsData[currentAnnouncementIndex];
                announcementDisplay.textContent = announcement.message;
                announcementDisplay.style.opacity = 1; // Fade in

                currentAnnouncementIndex = (currentAnnouncementIndex + 1) % activeAnnouncementsData.length;
            }, 500); // Matches CSS transition duration
        }

        if (activeAnnouncementsData.length > 0) {
            displayNextAnnouncement(); // Show first immediately
            announcementInterval = setInterval(displayNextAnnouncement, 5000); // Cycle every 5 seconds
        } else {
            if (announcementDisplay) {
                announcementDisplay.textContent = "No new announcements at this time.";
                announcementDisplay.style.opacity = 1;
            }
        }     // --- End Announcement Scroller JavaScript ---
    });
</script>
<script>
document.addEventListener("DOMContentLoaded", function () {
    const suggestInput = document.getElementById("employeeSuggest");
    const suggestionBox = document.getElementById("employeeSuggestions");
    const hiddenEmpId = document.getElementById("employeeId");
    const usernameInput = document.getElementById("username");
    const emailInput = document.getElementById("user_email");

    suggestInput.addEventListener("input", function () {
        const query = this.value.trim();
        suggestionBox.innerHTML = "";
        if (query.length < 2) return;

        fetch("/api/employee/suggestions?query=" + encodeURIComponent(query))
            .then(res => res.json())
            .then(data => {
                data.forEach(emp => {
                    console.log("Received emp:", emp); // ✅ DEBUG

                    const empId = emp.empId || "N/A";
                    const name = emp.name || "N/A";
                    const email = emp.email || "N/A";

                    const li = document.createElement("li");
                    li.classList.add("list-group-item", "list-group-item-action");

                    li.textContent = `(${empId}) ${name} - ${email}`;

                    li.addEventListener("click", function () {
                        suggestInput.value = name;
                        usernameInput.value = name;
                        emailInput.value = email;
                        hiddenEmpId.value = empId;
                        suggestionBox.innerHTML = "";
                    });

                    suggestionBox.appendChild(li);
                });
            })
            .catch(error => {
                console.error("Error fetching suggestions:", error);
            });
    });

    // Hide suggestion on outside click
    document.addEventListener("click", function (e) {
        if (!suggestInput.contains(e.target) && !suggestionBox.contains(e.target)) {
            suggestionBox.innerHTML = "";
        }
    });
});
</script>
<script>
    function openAnnouncementPopup() {
        document.getElementById("announcementModal").style.display = "block";
    }

    function closeAnnouncementPopup() {
        document.getElementById("announcementModal").style.display = "none";
    }

    // Optional: close modal when clicking outside the popup
    window.onclick = function(event) {
        const modal = document.getElementById("announcementModal");
        if (event.target === modal) {
            modal.style.display = "none";
        }
    }
</script>
<script>
    function openArchivePopup() {
        var archiveModal = new bootstrap.Modal(document.getElementById('archiveModal'));
        archiveModal.show();
    }
</script>

<script>
    document.addEventListener("DOMContentLoaded", function () {
        const input = document.getElementById("employeeQueryInput");
        const suggestionsBox = document.getElementById("employeeSuggestions");

        input.addEventListener("input", function () {
            const query = this.value.trim();
            if (query.length < 2) {
                suggestionsBox.innerHTML = "";
                return;
            }

            fetch("/search-employees?query=" + encodeURIComponent(query))
                .then(response => response.json())
                .then(data => {
                    suggestionsBox.innerHTML = "";
                    data.forEach(emp => {
                        const item = document.createElement("a");
                        item.href = "#";
                        item.classList.add("list-group-item", "list-group-item-action");
                        item.textContent = `${emp.empId} - ${emp.firstName} ${emp.lastName} (${emp.email})`;

                        item.addEventListener("click", function (e) {
                            e.preventDefault();
                            input.value = emp.empId; // you can choose to use name/email instead
                            suggestionsBox.innerHTML = "";
                        });

                        suggestionsBox.appendChild(item);
                    });
                });
        });

        document.addEventListener("click", function (e) {
            if (!suggestionsBox.contains(e.target) && e.target !== input) {
                suggestionsBox.innerHTML = "";
            }
        });
    });
</script>


</body>
</html>