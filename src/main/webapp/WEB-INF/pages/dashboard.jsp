<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>

<!DOCTYPE html>
<html>
<head>
    <title>Dashboard - Multywave Technologies</title>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; background-color: #fff; }

        .sidebar {
            position: fixed;
            left: 0;
            top: 0;
            width: 200px;
            height: 100vh;
            background-color: #2c2c2c;
            padding-top: 20px;
        }

        .sidebar h2 { color: white; text-align: center; margin-bottom: 20px; }

        .sidebar a {
            display: block;
            padding: 12px 20px;
            color: white;
            text-decoration: none;
            font-size: 15px;
        }

        .sidebar a:hover { background-color: #1a1a1a; }

        .content {
            margin-left: 200px;
            padding: 30px;
        }

        .footer {
            position: fixed;
            bottom: 0;
            left: 200px;
            width: calc(100% - 200px);
            background-color: #f0f0f0;
            padding: 10px;
            font-size: 13px;
            color: #333;
            text-align: center;
        }

        .popup {
            position: fixed;
            top: 0;
            left: 200px;
            width: calc(100% - 200px);
            height: 100vh;
            background-color: white;
            overflow-y: auto;
            padding: 20px;
            z-index: 999;
            border-left: 1px solid #ccc;
            box-shadow: -2px 0 5px rgba(0,0,0,0.1);
        }

        .popup h3 { margin-top: 0; font-size: 18px; }

        .close-btn {
            margin-top: 20px;
            padding: 8px 12px;
            background-color: #f44336;
            color: white;
            border: none;
            cursor: pointer;
            border-radius: 4px;
        }

        table {
            width: 100%;
            margin-top: 10px;
            border-collapse: collapse;
        }

        th, td {
            padding: 8px;
            border: 1px solid #ccc;
            text-align: left;
        }

        .message { color: green; font-weight: bold; margin-bottom: 15px; }

        .login-columns {
            display: flex;
            justify-content: space-around;
            gap: 40px;
            margin-top: 20px;
            flex-wrap: wrap;
        }

        .login-box {
            background-color: #f9f9f9;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
            padding: 25px 30px;
            width: 300px;
            transition: transform 0.3s ease;
        }

        .login-box:hover { transform: translateY(-5px); }

        .login-box h4 {
            margin-bottom: 20px;
            font-size: 20px;
            color: #333;
            text-align: center;
        }

        .login-box label {
            display: block;
            margin: 10px 0 5px;
            font-weight: bold;
            font-size: 14px;
            color: #555;
        }

        .login-box input[type="text"],
        .login-box input[type="password"],
        .login-box input[type="email"] {
            width: 100%;
            padding: 10px;
            margin-bottom: 15px;
            border: 1px solid #ccc;
            border-radius: 6px;
            font-size: 14px;
        }

        .login-box input[type="submit"] {
            width: 100%;
            background-color: #007BFF;
            border: none;
            color: white;
            padding: 10px;
            font-size: 16px;
            border-radius: 6px;
            cursor: pointer;
            transition: background-color 0.3s ease;
        }

        .login-box input[type="submit"]:hover {
            background-color: #0056b3;
        }
    </style>
</head>
<body>

<div class="sidebar">
    <h2>Multywave<br>Technologies</h2>
    <a href="#" onclick="showDepartmentPopup()">Departments</a>
    <a href="#" onclick="showDesignationPopup()">Designations</a>
    <a href="#" onclick="showEmployeePopup()">Employees</a>
    <!-- <a href="#" onclick="showUserPopup()">Users</a> -->
    <a href="#" onclick="showUserRolePopup()">User Roles</a>
    <a href="#" onclick="showLeavePopup()">Leaves</a>
    <a href="#" onclick="showSalaryPopup()">Salaries</a>
</div>

<div class="content">
    <h1>Welcome to Multywave Technologies</h1>
    <p>Security at your fingertips</p>
    <h3><b>About the Company</b></h3>

    <c:if test="${not empty message}">
        <div class="message">${message}</div>
    </c:if>
</div>

<!-- Department Popup -->
<div id="departmentPopup" class="popup" style="display:none;">
    <h3>Departments List</h3>
    <h2>Departments</h2>
<table border="1">
    <tr><th>ID</th><th>Name</th></tr>
    <c:forEach var="dept" items="${departments}">
        <tr>
            <td>${dept.dept_id}</td>
            <td>${dept.name}</td>
        </tr>
    </c:forEach>
</table>

    <button class="close-btn" onclick="closePopup('departmentPopup')">Close</button>
</div>

<!-- Designation Popup -->
<div id="designationPopup" class="popup" style="display:none;">
    <h3>Designations List</h3>
    <table>
        <tr><th>ID</th><th>Designation Name</th></tr>
        <c:forEach var="desig" items="${designations}">
            <tr><td>${desig.id}</td><td>${desig.title}</td></tr>
        </c:forEach>
    </table>
    <button class="close-btn" onclick="closePopup('designationPopup')">Close</button>
</div>

<!-- Employee Popup -->
  <div id="employeePopup" class="popup" style="display: ${showEmployeePopup ? 'block' : 'none'};">
    <c:choose>
        <c:when test="${not empty loggedInEmployee}">
            <h3>Welcome, ${loggedInEmployee.first_name} ${loggedInEmployee.last_name}</h3>
            <table>
                <tr><td><b>ID:</b></td><td>${loggedInEmployee.emp_id}</td></tr>
                <tr><td><b>Name:</b></td><td>${loggedInEmployee.name}</td></tr>
                <tr><td><b>Email:</b></td><td>${loggedInEmployee.email}</td></tr>
                <tr><td><b>Phone:</b></td><td>${loggedInEmployee.phone}</td></tr>
                <tr><td><b>Hire Date:</b></td><td>${loggedInEmployee.hiredate}</td></tr>
                <tr><td><b>Salary:</b></td><td>${loggedInEmployee.salary}</td></tr>
                <tr><td><b>Department:</b></td><td>${loggedInEmployee.department.name}</td></tr>
                <tr><td><b>Designation:</b></td><td>${loggedInEmployee.designation.title}</td></tr>
            </table>
        </c:when>
        <c:otherwise>
            <h3>Employees List</h3>
            <table>
                <tr>
                    <th>ID</th><th>Name</th><th>Email</th><th>Phone</th><th>Hire Date</th>
                    <th>First Name</th><th>Last Name</th><th>Salary</th><th>Department</th><th>Designation</th>
                </tr>
                <c:forEach var="emp" items="${employees}">
                    <tr>
                        <td>${emp.emp_id}</td>
                        <td>${emp.name}</td>
                        <td>${emp.email}</td>
                        <td>${emp.phone}</td>
                        <td>${emp.hiredate}</td>
                        <td>${emp.first_name}</td>
                        <td>${emp.last_name}</td>
                        <td>${emp.salary}</td>
                        <td>${emp.department.name}</td>
                        <td>${emp.designation.title}</td>
                    </tr>
                </c:forEach>
            </table>
        </c:otherwise>
    </c:choose>
    <button class="close-btn" onclick="closePopup('employeePopup')">Close</button>
</div>

<!-- User Login Popup -->
<div id="userPopup" class="popup" style="display:none;">
    <h3 align="center">Login As</h3>
    <div class="login-columns">
        <div class="login-box">
            <h4>Admin Login</h4>
            <form action="adminLogin" method="post">
                <label>Username:</label>
                <input type="text" name="username" required>
                <label>Password:</label>
                <input type="password" name="password" required>
                <input type="submit" value="Login">
            </form>
        </div>
        <div class="login-box">
            <h4>Employee Login</h4>
            <form action="employeeLogin" method="post">
                <label>Email:</label>
                <input type="email" name="email" required>
                <label>Password:</label>
                <input type="password" name="password" required>
                <input type="submit" value="Login">
            </form>
        </div>
    </div>
    <button class="close-btn" onclick="closePopup('userPopup')">Close</button>
</div>

<!-- User Role Popup -->
<div id="userRolePopup" class="popup" style="display:none;">
    <h3>User Roles</h3>
    <table>
        <tr><th>ID</th><th>Role Name</th></tr>
        <c:forEach var="role" items="${roles}">
            <tr><td>${role.id}</td><td>${role.name}</td></tr>
        </c:forEach>
    </table>
    <button class="close-btn" onclick="closePopup('userRolePopup')">Close</button>
</div>

<!-- Leave Popup -->
<div id="leavePopup" class="popup" style="display:none;">
    <h3>Leave Requests</h3>
    <table>
        <tr><th>ID</th><th>Employee Name</th><th>From</th><th>To</th><th>Reason</th><th>Status</th></tr>
        <c:forEach var="leave" items="${leaves}">
            <tr>
                <td>${leave.id}</td>
                <td>${leave.employee.name}</td>
                <td>${leave.startDate}</td>
                <td>${leave.endDate}</td>
                <td>${leave.reason}</td>
                <td>${leave.status}</td>
            </tr>
        </c:forEach>
    </table>
    <button class="close-btn" onclick="closePopup('leavePopup')">Close</button>
</div>

<!-- Salary Popup -->
<div id="salaryPopup" class="popup" style="display:none;">
    <h3>Salary Details</h3>
    <table>
        <tr><th>Employee ID</th><th>Employee Name</th><th>Salary Id</th><th>Amount</th><th>Paid Date</th></tr>
        
        <c:forEach var="sal" items="${salaries}">
            <tr>
                <td>${sal.employee.id}</td>
                <td>${sal.employee.name}</td>
                <td>${sal.id}</td>
                <td>${sal.amount}</td>
                <td>${sal.paidDate}</td>
            </tr>
        </c:forEach>
    </table>
    <button class="close-btn" onclick="closePopup('salaryPopup')">Close</button>
</div>

<!-- Footer -->
<div class="footer">
    Address: Kavuri Hills, Madhapur, Hyderabad, India | Phone: +91-9876543210
</div>

<script>
    function showDepartmentPopup() { hideAllPopups(); document.getElementById("departmentPopup").style.display = "block"; }
    function showDesignationPopup() { hideAllPopups(); document.getElementById("designationPopup").style.display = "block"; }
    function showEmployeePopup() { hideAllPopups(); document.getElementById("employeePopup").style.display = "block"; }
    function showUserPopup() { hideAllPopups(); document.getElementById("userPopup").style.display = "block"; }
    function showUserRolePopup() { hideAllPopups(); document.getElementById("userRolePopup").style.display = "block"; }
    function showLeavePopup() { hideAllPopups(); document.getElementById("leavePopup").style.display = "block"; }
    function showSalaryPopup() { hideAllPopups(); document.getElementById("salaryPopup").style.display = "block"; }

    function closePopup(id) {
        document.getElementById(id).style.display = "none";
    }

    function hideAllPopups() {
        const popups = ["departmentPopup", "designationPopup", "employeePopup", "userPopup", "userRolePopup", "leavePopup", "salaryPopup"];
        popups.forEach(popup => document.getElementById(popup).style.display = "none");
    }
</script>

</body>
</html>
