<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/functions" prefix="fn" %>


<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Employee Dashboard - Multywave Technologies</title>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css" crossorigin="anonymous">
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">

        <link rel="stylesheet" href="${pageContext.request.contextPath}/css/dashboard.css">
    
</head>
<body>
<%-- No admin role check needed here, as this is the employee dashboard --%>

<c:set var="activeTab" value="${param.tab}" />

<div class="sidebar">
    <a href="${pageContext.request.contextPath}/emp-dashboard" class="text-decoration-none text-white">
        <h2 class="py-3 mb-4 border-bottom border-secondary">Multywave<br>Technologies</h2>
    </a>

    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=departments" class="nav-link text-white ${activeTab == 'departments' ? 'active-link' : ''}">
        <i class="fas fa-building me-2"></i>Departments
    </a>
    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=designations" class="nav-link text-white ${activeTab == 'designations' ? 'active-link' : ''}">
        <i class="fas fa-id-badge me-2"></i>Designations
    </a>
    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees" class="nav-link text-white ${activeTab == 'employees' ? 'active-link' : ''}">
        <i class="fas fa-users me-2"></i>Employees
    </a>
    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=users" class="nav-link text-white ${activeTab == 'users' ? 'active-link' : ''}">
        <i class="fas fa-user-cog me-2"></i>Users
    </a>
     <a href="${pageContext.request.contextPath}/emp-dashboard?tab=leaves" class="nav-link text-white ${activeTab == 'leaves' ? 'active-link' : ''}">
        <i class="fas fa-clipboard-list me-2"></i>Leaves
    </a> 
    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=statistics" class="nav-link text-white ${activeTab == 'statistics' ? 'active-link' : ''}">
    <i class="fas fa-chart-bar me-2"></i>My Statistics
</a>
    
    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=salaries" class="nav-link text-white ${activeTab == 'salaries' ? 'active-link' : ''}">
        <i class="fas fa-money-bill-wave me-2"></i>Salaries
    </a>

    <form action="${pageContext.request.contextPath}/logout" method="get" class="text-center mt-5">
        <button type="submit" class="btn btn-warning logout-button">
            <i class="fas fa-sign-out-alt me-2"></i>Logout
        </button>
    </form>
</div>

<div class="main-content">
    <%-- Multywave Technologies banner displayed for every section --%>
    <div class="top-page-banner">
        <h1>Multywave Technologies</h1>
        <p>Security at your fingertips</p>
    </div>

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

<c:if test="${empty activeTab}">
<c:if test="${sessionScope.userRole == 'employee'}">
    <div class="text-center my-4">
        <form method="post" action="${pageContext.request.contextPath}/employee/check-in" onsubmit="return fillLocation(this);">
    <input type="hidden" name="latitude" id="latitude">
    <input type="hidden" name="longitude" id="longitude">
    <button type="submit" class="btn btn-success">Check In</button>
</form>
<form method="post" action="${pageContext.request.contextPath}/employee/check-out" onsubmit="return fillLocation(this);">
    <input type="hidden" name="latitude" id="latitude">
    <input type="hidden" name="longitude" id="longitude">
    <button type="submit" class="btn btn-danger">Check Out</button>
</form>

    </div>
</c:if>

<!-- Show messages -->

    <div class="badge-container">
        <div class="badge-item">
            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=departments">
                <i class="fas fa-building"></i> Departments<br>
                <span class="badge bg-primary">${departments.size()}</span>
            </a>
        </div>
        <div class="badge-item">
            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees">
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
</c:if>
</c:if>

    <div id="departments-section" class="${activeTab == 'departments' ? '' : 'd-none'}">
        <h2 class="text-center text-primary mb-4">Departments</h2>
        
        <%-- Search Input (Top and Center) --%>
        <div class="search-bar-container text-center mb-3">
            <input type="text" id="searchInputDept" onkeyup="searchTable('dataTableDept', 'searchInputDept')" placeholder="Search..." class="form-control mx-auto">
        </div>

        <div class="table-controls-row d-flex flex-wrap justify-content-between align-items-center mb-3">
            <%-- Records per page (Left) --%>
          <div class="records-per-page-container d-flex align-items-center mb-2 mb-md-0">
    <label for="deptSize" class="form-label me-2 mb-0">Records per page:</label>
    <form id="deptPageSizeForm" method="get" action="${pageContext.request.contextPath}/emp-dashboard" class="d-inline-flex align-items-center">
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
            <!-- Sorting Options Dropdown (Right) --%>
            <div class="dropdown ms-auto mb-2 mb-md-0">
                <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButtonDeptSort" data-bs-toggle="dropdown" aria-expanded="false">
                    Sort By
                </button>
                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownMenuButtonDeptSort">
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=departments&deptPage=${deptCurrentPage}&deptSize=${deptSize}&deptSortField=deptId&deptSortDir=${deptSortField eq 'deptId' and deptSortDir eq 'asc' ? 'desc' : 'asc'}">
                        ID <c:if test="${deptSortField eq 'deptId'}"><i class="fas fa-sort-${deptSortDir eq 'asc' ? 'up' : 'down'} ms-2"></i></c:if>
                    </a></li>
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=departments&deptPage=${deptCurrentPage}&deptSize=${deptSize}&deptSortField=name&deptSortDir=${deptSortField eq 'name' and deptSortDir eq 'asc' ? 'desc' : 'asc'}">
                        Department Name <c:if test="${deptSortField eq 'name'}"><i class="fas fa-sort-${deptSortDir eq 'name' ? 'up' : 'down'} ms-2"></i></c:if>
                    </a></li>
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=departments&deptPage=${deptCurrentPage}&deptSize=${deptSize}&deptSortField=mail&deptSortDir=${deptSortField eq 'mail' and deptSortDir eq 'asc' ? 'desc' : 'asc'}">
                        Email <c:if test="${deptSortField eq 'mail'}"><i class="fas fa-sort-${deptSortDir eq 'mail' ? 'up' : 'down'} ms-2"></i></c:if>
                    </a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><span class="dropdown-item-text text-muted">Current: 
                        <c:choose>
                            <c:when test="${not empty deptSortField}">${deptSortField} (<c:if test="${deptSortDir eq 'asc'}">Asc</c:if><c:if test="${deptSortDir eq 'desc'}">Desc</c:if>)</c:when>
                            <c:otherwise>None</c:otherwise>
                        </c:choose>
                    </span></li>
                </ul>
            </div>-->
        </div>
        
        <div class="table-responsive">
            <table id="dataTableDept" class="table table-striped table-hover table-bordered shadow-sm">
                <thead class="table-primary">
                    <tr>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=departments&deptPage=${deptCurrentPage}&deptSize=${deptSize}&deptSortField=deptId&deptSortDir=${deptSortField eq 'deptId' and deptSortDir eq 'asc' ? 'desc' : 'asc'}">
                                ID
                                <c:if test="${deptSortField eq 'deptId'}">
                                    <i class="fas fa-sort-${deptSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=departments&deptPage=${deptCurrentPage}&deptSize=${deptSize}&deptSortField=name&deptSortDir=${deptSortField eq 'name' and deptSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Department Name
                                <c:if test="${deptSortField eq 'name'}">
                                    <i class="fas fa-sort-${deptSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=departments&deptPage=${deptCurrentPage}&deptSize=${deptSize}&deptSortField=mail&deptSortDir=${deptSortField eq 'mail' and deptSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Email
                                <c:if test="${deptSortField eq 'mail'}">
                                    <i class="fas fa-sort-${deptSortDir eq 'mail' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=departments&deptPage=${deptCurrentPage}&deptSize=${deptSize}&deptSortField=createdDate&deptSortDir=${deptSortField eq 'createdDate' and deptSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Created Date
                                <c:if test="${deptSortField eq 'createdDate'}">
                                    <i class="fas fa-sort-${deptSortDir eq 'createdDate' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                       
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="dept" items="${departments}">
                        <tr>
                            <td>${dept.deptId}</td>
                            <td>${dept.name}</td>
                            <td>${dept.mail}</td>
                            <td>${dept.createdDate}</td>
                            
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <div class="pagination-container">
            <c:forEach begin="0" end="${deptTotalPages - 1}" var="i">
                <a href="${pageContext.request.contextPath}/emp-dashboard?deptPage=${i}&tab=departments&deptSize=${deptSize}&deptSortField=${deptSortField}&deptSortDir=${deptSortDir}"
                   class="${i == deptCurrentPage ? 'font-weight-bold' : ''}">
                    ${i + 1}
                </a>
            </c:forEach>
        </div>

        <%-- Removed Add Department Button and Modal --%>
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
    <form id="desigPageSizeForm" method="get" action="${pageContext.request.contextPath}/emp-dashboard" class="d-inline-flex align-items-center">
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

            <!-- Sorting Options Dropdown (Right) --%>
            <div class="dropdown ms-auto mb-2 mb-md-0">
                <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButtonDesigSort" data-bs-toggle="dropdown" aria-expanded="false">
                    Sort By
                </button>
                <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownMenuButtonDesigSort">
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=designations&desigPage=${desigCurrentPage}&desigSize=${desigSize}&desigSortField=desigId&desigSortDir=${desigSortField eq 'desigId' and desigSortDir eq 'asc' ? 'desc' : 'asc'}">
                        ID <c:if test="${desigSortField eq 'desigId'}"><i class="fas fa-sort-${desigSortDir eq 'asc' ? 'up' : 'down'} ms-2"></i></c:if>
                    </a></li>
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=designations&desigPage=${desigCurrentPage}&desigSize=${desigSize}&desigSortField=title&desigSortDir=${desigSortField eq 'title' and desigSortDir eq 'asc' ? 'desc' : 'asc'}">
                        Title <c:if test="${desigSortField eq 'title'}"><i class="fas fa-sort-${desigSortDir eq 'asc' ? 'up' : 'down'} ms-2"></i></c:if>
                    </a></li>
                    <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=designations&desigPage=${desigCurrentPage}&desigSize=${desigSize}&desigSortField=dmail&desigSortDir=${desigSortField eq 'dmail' and desigSortDir eq 'asc' ? 'desc' : 'asc'}">
                        Mail <c:if test="${desigSortField eq 'dmail'}"><i class="fas fa-sort-${desigSortDir eq 'dmail' ? 'up' : 'down'} ms-2"></i></c:if>
                    </a></li>
                    <li><hr class="dropdown-divider"></li>
                    <li><span class="dropdown-item-text text-muted">Current: 
                        <c:choose>
                            <c:when test="${not empty desigSortField}">${desigSortField} (<c:if test="${desigSortDir eq 'asc'}">Asc</c:if><c:if test="${desigSortDir eq 'desc'}">Desc</c:if>)</c:when>
                            <c:otherwise>None</c:otherwise>
                        </c:choose>
                    </span></li>
                </ul>
            </div>-->
        </div>
        
        <div class="table-responsive">
            <table id="dataTableDesig" class="table table-striped table-hover table-bordered shadow-sm">
                <thead class="table-primary">
                    <tr>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=designations&desigPage=${desigCurrentPage}&desigSize=${desigSize}&desigSortField=desigId&desigSortDir=${desigSortField eq 'desigId' and desigSortDir eq 'asc' ? 'desc' : 'asc'}">
                                ID
                                <c:if test="${desigSortField eq 'desigId'}">
                                    <i class="fas fa-sort-${desigSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=designations&desigPage=${desigCurrentPage}&desigSize=${desigSize}&desigSortField=title&desigSortDir=${desigSortField eq 'title' and desigSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Title
                                <c:if test="${desigSortField eq 'title'}">
                                    <i class="fas fa-sort-${desigSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=designations&desigPage=${desigCurrentPage}&desigSize=${desigSize}&desigSortField=dmail&desigSortDir=${desigSortDir eq 'dmail' and desigSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Mail
                                <c:if test="${desigSortField eq 'dmail'}">
                                    <i class="fas fa-sort-${desigSortDir eq 'dmail' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=designations&desigPage=${desigCurrentPage}&desigSize=${desigSize}&desigSortField=createdDate&desigSortDir=${desigSortField eq 'createdDate' and desigSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Created Date
                                <c:if test="${desigSortField eq 'createdDate'}">
                                    <i class="fas fa-sort-${desigSortDir eq 'createdDate' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <%-- Retained action column for delete, adjust if needed --%>
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="desig" items="${designations}">
                        <tr>
                            <td>${desig.desigId}</td>
                            <td>${desig.title}</td>
                            <td>${desig.dmail}</td>
                            <td>${desig.createdDate}</td>
                            
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <div class="pagination-container">
            <c:forEach begin="0" end="${desigTotalPages - 1}" var="i">
                <a href="${pageContext.request.contextPath}/emp-dashboard?desigPage=${i}&tab=designations&desigSize=${desigSize}&desigSortField=${desigSortField}&desigSortDir=${desigSortDir}"
                   class="${i == desigCurrentPage ? 'font-weight-bold' : ''}">
                    ${i + 1}
                </a>
            </c:forEach>
        </div>

        <%-- Removed Add Designation Button and Modal --%>
    </div>

   <div id="employees-section" class="${activeTab == 'employees' ? '' : 'd-none'}">
        <c:choose>
            <c:when test="${not empty loggedInEmployee}">
                <h3 class="text-center text-primary my-4">Welcome, ${loggedInEmployee.firstName} ${loggedInEmployee.last_name}</h3>
                <div class="card shadow-sm p-4 mx-auto" style="max-width: 600px;">
                    <div class="row mb-2">
                        <div class="col-md-4 text-muted"><b>ID:</b></div>
                        <div class="col-md-8">${loggedInEmployee.empId}</div>
                    </div>
                    <div class="row mb-2">
                        <div class="col-md-4 text-muted"><b>Name:</b></div>
                        <div class="col-md-8">${loggedInEmployee.name}</div>
                    </div>
                    <div class="row mb-2">
                        <div class="col-md-4 text-muted"><b>Email:</b></div>
                        <div class="col-md-8">${loggedInEmployee.email}</div>
                    </div>
                    <div class="row mb-2">
                        <div class="col-md-4 text-muted"><b>Phone:</b></div>
                        <div class="col-md-8">${loggedInEmployee.phone}</div>
                    </div>
                    <div class="row mb-2">
                        <div class="col-md-4 text-muted"><b>Hire Date:</b></div>
                        <div class="col-md-8">${loggedInEmployee.hiredate}</div>
                    </div>
                    <div class="row mb-2">
                        <div class="col-md-4 text-muted"><b>Salary:</b></div>
                        <div class="col-md-8">${loggedInEmployee.salary}</div>
                    </div>
                    <div class="row mb-2">
                        <div class="col-md-4 text-muted"><b>Department:</b></div>
                        <div class="col-md-8">${loggedInEmployee.department.name}</div>
                    </div>
                    <div class="row mb-2">
                        <div class="col-md-4 text-muted"><b>Designation:</b></div>
                        <div class="col-md-8">${loggedInEmployee.designation.title}</div>
                    </div>
                </div>
            </c:when>
            <c:otherwise>
                <h2 class="text-center text-primary mb-4 ">Employees</h2>

                <%-- Search Input (Top and Center) --%>
                <div class="search-bar-container text-center mb-3">
                    <input type="text" id="searchInputEmp" onkeyup="searchTable('dataTableEmp', 'searchInputEmp')" placeholder="Search..." class="form-control mx-auto">
                </div>

                <div class="table-controls-row d-flex flex-wrap justify-content-between align-items-center mb-3">
                    <%-- Records per page (Left) --%>
                    <div class="records-per-page-container d-flex align-items-center mb-2 mb-md-0">
                        <label for="empSize" class="form-label me-2 mb-0">Records per page:</label>
                        <form method="get" action="${pageContext.request.contextPath}/emp-dashboard" class="d-inline-flex align-items-center">
                            <input type="number" id="empSize" name="empSize" value="${empSize}" min="1" max="100" class="form-control form-control-sm me-2" style="width: 80px;" required 
                                   onchange="this.form.submit()" />
                            <input type="hidden" name="empPage" value="${empCurrentPage}" />
                            <input type="hidden" name="tab" value="employees" />
                            <input type="hidden" name="empSortField" value="${empSortField}" />
                            <input type="hidden" name="empSortDir" value="${empSortDir}" />
                        </form>
                    </div>
                    
                    <!-- Sorting Options Dropdown (Right) --%>
                    <div class="dropdown ms-auto mb-2 mb-md-0">
                        <button class="btn btn-secondary dropdown-toggle" type="button" id="dropdownMenuButtonEmpSort" data-bs-toggle="dropdown" aria-expanded="false">
                            Sort By
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="dropdownMenuButtonEmpSort">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=empId&empSortDir=${empSortField eq 'empId' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                ID <c:if test="${empSortField eq 'empId'}"><i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'} ms-2"></i></c:if>
                            </a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=name&empSortDir=${empSortField eq 'name' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Name <c:if test="${empSortField eq 'name'}"><i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'} ms-2"></i></c:if>
                            </a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=email&empSortDir=${empSortField eq 'email' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Email <c:if test="${empSortField eq 'email'}"><i class="fas fa-sort-${empSortDir eq 'email' ? 'up' : 'down'} ms-2"></i></c:if>
                            </a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=phone&empSortDir=${empSortField eq 'phone' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Phone <c:if test="${empSortField eq 'phone'}"><i class="fas fa-sort-${empSortDir eq 'phone' ? 'up' : 'down'} ms-2"></i></c:if>
                            </a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=hiredate&empSortDir=${empSortField eq 'hiredate' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Hire Date <c:if test="${empSortField eq 'hiredate'}"><i class="fas fa-sort-${empSortDir eq 'hiredate' ? 'up' : 'down'} ms-2"></i></c:if>
                            </a></li>
                             <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=firstName&empSortDir=${empSortField eq 'firstName' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                First Name <c:if test="${empSortField eq 'firstName'}"><i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'} ms-2"></i></c:if>
                            </a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=lastName&empSortDir=${empSortField eq 'lastName' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Last Name <c:if test="${empSortField eq 'lastName'}"><i class="fas fa-sort-${empSortDir eq 'lastName' ? 'up' : 'down'} ms-2"></i></c:if>
                            </a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=salary&empSortDir=${empSortField eq 'salary' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Salary <c:if test="${empSortField eq 'salary'}"><i class="fas fa-sort-${empSortDir eq 'salary' ? 'up' : 'down'} ms-2"></i></c:if>
                            </a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=dept.name&empSortDir=${empSortField eq 'dept.name' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Department <c:if test="${empSortField eq 'dept.name'}"><i class="fas fa-sort-${empSortDir eq 'dept.name' ? 'up' : 'down'} ms-2"></i></c:if>
                            </a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=desig.title&empSortDir=${empSortField eq 'desig.title' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Designation <c:if test="${empSortField eq 'desig.title'}"><i class="fas fa-sort-${empSortDir eq 'desig.title' ? 'up' : 'down'} ms-2"></i></c:if>
                            </a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><span class="dropdown-item-text text-muted">Current: 
                                <c:choose>
                                    <c:when test="${not empty empSortField}">${empSortField} (<c:if test="${empSortDir eq 'asc'}">Asc</c:if><c:if test="${empSortDir eq 'desc'}">Desc</c:if>)</c:when>
                                    <c:otherwise>None</c:otherwise>
                                </c:choose>
                            </span></li>
                        </ul>
                    </div>-->
                </div>
                
                <div class="table-responsive">
                    <table id="dataTableEmp" class="table table-striped table-hover table-bordered shadow-sm">
                        <thead class="table-primary">
                            <tr>
                                <th>
                                    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=empId&empSortDir=${empSortField eq 'empId' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                        ID
                                        <c:if test="${empSortField eq 'empId'}">
                                            <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                        </c:if>
                                    </a>
                                </th>
                                <th>
                                    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=name&empSortDir=${empSortField eq 'name' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                        Name
                                        <c:if test="${empSortField eq 'name'}">
                                            <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                        </c:if>
                                    </a>
                                </th>
                                <th>
                                    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=email&empSortDir=${empSortField eq 'email' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                        Email
                                        <c:if test="${empSortField eq 'email'}">
                                            <i class="fas fa-sort-${empSortDir eq 'email' ? 'up' : 'down'}"></i>
                                        </c:if>
                                    </a>
                                </th>
                                <th>
                                    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=phone&empSortDir=${empSortField eq 'phone' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                        Phone
                                        <c:if test="${empSortField eq 'phone'}">
                                            <i class="fas fa-sort-${empSortDir eq 'phone' ? 'up' : 'down'}"></i>
                                        </c:if>
                                    </a>
                                </th>
                                <th>
                                    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=hiredate&empSortDir=${empSortField eq 'hiredate' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                        Hire Date
                                        <c:if test="${empSortField eq 'hiredate'}">
                                            <i class="fas fa-sort-${empSortDir eq 'hiredate' ? 'up' : 'down'}"></i>
                                        </c:if>
                                    </a>
                                </th>
                                <th>
                                    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=firstName&empSortDir=${empSortField eq 'firstName' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                        First Name
                                        <c:if test="${empSortField eq 'firstName'}">
                                            <i class="fas fa-sort-${empSortDir eq 'firstName' ? 'up' : 'down'}"></i>
                                        </c:if>
                                    </a>
                                </th>
                                <th>
                                    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=lastName&empSortDir=${empSortField eq 'lastName' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                        Last Name
                                        <c:if test="${empSortField eq 'lastName'}">
                                            <i class="fas fa-sort-${empSortDir eq 'lastName' ? 'up' : 'down'}"></i>
                                        </c:if>
                                    </a>
                                </th>
                                <th>
                                    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=salary&empSortDir=${empSortField eq 'salary' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                        Salary
                                        <c:if test="${empSortField eq 'salary'}">
                                            <i class="fas fa-sort-${empSortDir eq 'salary' ? 'up' : 'down'}"></i>
                                        </c:if>
                                    </a>
                                </th>
                                <th>
                                    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=dept.name&empSortDir=${empSortField eq 'dept.name' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                        Department
                                        <c:if test="${empSortField eq 'dept.name'}">
                                            <i class="fas fa-sort-${empSortDir eq 'dept.name' ? 'up' : 'down'}"></i>
                                        </c:if>
                                    </a>
                                </th>
                                <th>
                                    <a href="${pageContext.request.contextPath}/emp-dashboard?tab=employees&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=desig.title&empSortDir=${empSortField eq 'desig.title' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                        Designation
                                        <c:if test="${empSortField eq 'desig.title'}">
                                            <i class="fas fa-sort-${empSortDir eq 'desig.title' ? 'up' : 'down'}"></i>
                                        </c:if>
                                    </a>
                                </th>
                                 <%-- Retained action column for delete, adjust if needed --%>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="emp" items="${employees}">
                                <tr>
                                    <td>${emp.empId}</td>
                                    <td>${emp.name}</td>
                                    <td>${emp.email}</td>
                                    <td>${emp.phone}</td>
                                    <td>${emp.hiredate}</td>
                                    <td>${emp.firstName}</td>
                                    <td>${emp.lastName}</td>
                                    <td>${emp.salary}</td>
                                    <td>${emp.dept.name}</td>
                                    <td>${emp.desig.title}</td>
                                    
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </c:otherwise>
        </c:choose>
        
        <div class="pagination-container">
            <c:forEach begin="0" end="${empTotalPages - 1}" var="i">
                <a href="${pageContext.request.contextPath}/emp-dashboard?empPage=${i}&tab=employees&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}"
                   class="${i == empCurrentPage ? 'font-weight-bold' : ''}">
                    ${i + 1}
                </a>
            </c:forEach>
        </div>

        <%-- Removed Add Employee Button and Modal --%>
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
    <label for="deptSize" class="form-label me-2 mb-0">Records per page:</label>
    <form id="deptPageSizeForm" method="get" action="${pageContext.request.contextPath}/emp-dashboard" class="d-inline-flex align-items-center">
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
        </div>
        
        <div class="table-responsive">
            <table id="dataTableUser" class="table table-striped table-hover table-bordered shadow-sm">
                <thead class="table-primary">
                    <tr>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=users&userPage=${userCurrentPage}&userSize=${userSize}&userSortField=userId&userSortDir=${userSortField eq 'userId' and userSortDir eq 'asc' ? 'desc' : 'asc'}">
                                ID
                                <c:if test="${userSortField eq 'userId'}">
                                    <i class="fas fa-sort-${userSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=users&userPage=${userCurrentPage}&userSize=${userSize}&userSortField=username&userSortDir=${userSortField eq 'username' and userSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Username
                                <c:if test="${userSortField eq 'username'}">
                                    <i class="fas fa-sort-${userSortDir eq 'username' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=users&userPage=${userCurrentPage}&userSize=${userSize}&userSortField=email&userSortDir=${userSortField eq 'email' and userSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Email
                                <c:if test="${userSortField eq 'email'}">
                                    <i class="fas fa-sort-${userSortDir eq 'email' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=users&userPage=${userCurrentPage}&userSize=${userSize}&userSortField=role&userSortDir=${userSortField eq 'role' and userSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Role
                                <c:if test="${userSortField eq 'role'}">
                                    <i class="fas fa-sort-${userSortDir eq 'role' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                       
                    </tr>
                </thead>
                <tbody>
                    <c:forEach var="user" items="${users}">
                        <tr>
                            <td>${user.userId}</td>
                            <td>${user.username}</td>
                            <td>${user.email}</td>
                            <td>${user.role}</td>
                           
                        </tr>
                    </c:forEach>
                </tbody>
            </table>
        </div>

        <div class="pagination-container">
            <c:forEach begin="0" end="${userTotalPages - 1}" var="i">
                <a href="${pageContext.request.contextPath}/emp-dashboard?userPage=${i}&tab=users&userSize=${userSize}&userSortField=${userSortField}&userSortDir=${userSortDir}"
                   class="${i == userCurrentPage ? 'font-weight-bold' : ''}">
                    ${i + 1}
                </a>
            </c:forEach>
        </div>

        <%-- Removed Add User Button and Modal --%>
    </div>
<div id="leave-section" class="${activeTab == 'leaves' ? '' : 'd-none'}">
    <h4 class="mt-4">Request Leave</h4>
    <form method="post" action="${pageContext.request.contextPath}/employee/request-leave">
        <div class="row">
            <div class="col-md-3">
                <label>Start Date</label>
                <input type="date" name="startDate" class="form-control" required />
            </div>
            <div class="col-md-3">
                <label>End Date</label>
                <input type="date" name="endDate" class="form-control" required />
            </div>
            <div class="col-md-6">
                <label>Reason</label>
                <input type="text" name="reason" class="form-control" required />
            </div>
        </div>
        <button type="submit" class="btn btn-primary mt-3">Submit Leave Request</button>
    </form>

    <h5 class="mt-4">My Leave Requests</h5>
    <table class="table table-bordered table-striped">
        <thead>
            <tr>
                <th>Date Range</th>
                <th>Reason</th>
                <th>Status</th>
                <th>Requested On</th>
            </tr>
        </thead>
        <tbody>
            <c:forEach items="${leaveRequests}" var="leave">
                <tr>
                    <td>${leave.startDate} to ${leave.endDate}</td>
                    <td>${leave.reason}</td>
                   <td>
    <c:choose>
        <c:when test="${leave.status == 'PENDING'}">
            <span class="badge bg-warning text-dark">Pending</span>
        </c:when>
        <c:when test="${leave.status == 'Accepted'}">
            <span class="badge bg-success">Accepted</span>
        </c:when>
        <c:when test="${leave.status == 'Rejected'}">
            <span class="badge bg-danger">Rejected</span>
        </c:when>
        <c:otherwise>
            ${leave.status}
        </c:otherwise>
    </c:choose>
</td>

                    <td>${leave.requestDate}</td>
                </tr>
            </c:forEach>
        </tbody>
    </table>
</div>
<div id="statistics-section" class="${activeTab == 'statistics' ? '' : 'd-none'}">
    <h3 class="text-center my-3">📊 My Attendance Statistics</h3>

    <form method="get" action="emp-dashboard" class="text-center mb-4">
        <input type="hidden" name="tab" value="statistics">
        <select name="period" onchange="this.form.submit()" class="form-select w-auto d-inline">
            <option value="month" ${period == 'month' ? 'selected' : ''}>This Month</option>
            <option value="year" ${period == 'year' ? 'selected' : ''}>This Year</option>
        </select>
    </form>

    <div class="row justify-content-center">
        <div class="col-md-4">
            <div class="card shadow-sm p-4 mb-3">
                <h5 class="text-primary">✅ Working Days</h5>
                <p class="fs-4">${presentDays} / ${totalWorkingDays}</p>
            </div>
        </div>

        <div class="col-md-4">
            <div class="card shadow-sm p-4 mb-3">
                <h5 class="text-danger">🛌 Leaves Taken</h5>
                <p class="fs-4">${leavesTaken}</p>
            </div>
        </div>
    </div>
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
    <form id="salaryPageSizeForm" method="get" action="${pageContext.request.contextPath}/emp-dashboard" class="d-inline-flex align-items-center">
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
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=salaries&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=empId&empSortDir=${empSortField eq 'empId' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Employee ID
                                <c:if test="${empSortField eq 'empId'}">
                                    <i class="fas fa-sort-${empSortDir eq 'asc' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=salaries&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=accountNumber&empSortDir=${empSortField eq 'accountNumber' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Account Number
                                <c:if test="${empSortField eq 'accountNumber'}">
                                    <i class="fas fa-sort-${empSortDir eq 'accountNumber' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=salaries&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=name&empSortDir=${empSortField eq 'name' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
                                Employee Name
                                <c:if test="${empSortField eq 'name'}">
                                    <i class="fas fa-sort-${empSortDir eq 'name' ? 'up' : 'down'}"></i>
                                </c:if>
                            </a>
                        </th>
                        <th>
                            <a href="${pageContext.request.contextPath}/emp-dashboard?tab=salaries&empPage=${empCurrentPage}&empSize=${empSize}&empSortField=salary&empSortDir=${empSortField eq 'salary' and empSortDir eq 'asc' ? 'desc' : 'asc'}">
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
            <c:forEach begin="0" end="${empTotalPages - 1}" var="i">
                <a href="${pageContext.request.contextPath}/emp-dashboard?tab=salaries&empPage=${i}&empSize=${empSize}&empSortField=${empSortField}&empSortDir=${empSortDir}" 
                   class="${empCurrentPage == i ? 'font-weight-bold' : ''}">
                    ${i + 1}
                </a>
            </c:forEach>
        </div>
    </div>

</div> 
<div class="footer">
    Address: Kavuri Hills, Madhapur, Hyderabad, India | Phone: +91-9876543210
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>
 <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>

     <script src="${pageContext.request.contextPath}/js/emp-dashboard.js"></script>
     <script>
    const contextPath = '${pageContext.request.contextPath}';
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
</script>


</body>
</html>