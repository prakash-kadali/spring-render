<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Multywave Technologies</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">

    <style>
        body {
            font-family: Arial, sans-serif;
            background: #ecf0f1; /* Light background for the whole page */
            height: 100vh;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
        }

        /*
         * We're moving away from .login-box for most styling,
         * as Bootstrap's .card will handle it.
         * Keeping this only if you have very specific non-Bootstrap styles
         * you want to retain or override.
         */
        /* .login-box {
            background: #fff;
            padding: 40px 30px;
            border-radius: 10px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.15);
            width: 350px;
            transition: transform 0.3s ease;
        }

        .login-box:hover {
            transform: scale(1.02);
        } */

        /*
         * You can keep this if you want a custom hover effect
         * on the Bootstrap card, but Bootstrap cards already have
         * subtle shadow effects.
         */
        .card:hover {
             transform: scale(1.01); /* Slightly less aggressive than original login-box hover */
             box-shadow: 0 10px 25px rgba(0, 0, 0, 0.2); /* Enhance shadow on hover */
             transition: transform 0.3s ease, box-shadow 0.3s ease;
        }

        /*
         * No longer needed as Bootstrap's form-control handles this
         * input, select {
         * width: 100%;
         * padding: 10px;
         * margin-bottom: 20px;
         * border-radius: 6px;
         * border: 1px solid #ccc;
         * transition: border-color 0.2s;
         * }
         */

        /*
         * No longer needed as Bootstrap's form-control handles this
         * input:focus, select:focus {
         * border-color: #3498db;
         * outline: none;
         * }
         */

        /*
         * No longer needed as Bootstrap's btn btn-primary handles this
         * button {
         * width: 100%;
         * padding: 12px;
         * background-color: #3498db;
         * color: #fff;
         * border: none;
         * border-radius: 6px;
         * font-size: 16px;
         * transition: background-color 0.3s;
         * }
         * button:hover {
         * background-color: #2980b9;
         * cursor: pointer;
         * }
         */

        /* Error message now uses Bootstrap .alert-danger or .alert-warning */
        /* .error-msg {
            color: red;
            text-align: center;
            margin-top: -10px;
            margin-bottom: 10px;
        } */
    </style>
</head>
<body>

<div class="container">
    <div class="row justify-content-center">
        <div class="col-md-5 col-lg-4"> <%-- Adjust column size for better responsiveness --%>
            <div class="card shadow-lg p-4"> <%-- Bootstrap card with shadow and padding --%>
                <div class="card-body">
                    <h2 class="card-title text-center mb-4 text-dark">Multywave Technologies</h2> <%-- Bootstrap card title --%>
                    
                    <%-- Consolidated Error and Session Expired Messages using Bootstrap Alerts --%>
                    <c:if test="${not empty error}">
                        <div class="alert alert-danger text-center" role="alert">
                            ${error}
                        </div>
                    </c:if>
                    <c:if test="${param.sessionExpired eq 'true'}">
                        <div class="alert alert-warning text-center" role="alert">
                            Session expired. Please log in again.
                        </div>
                    </c:if>

                    <form action="${pageContext.request.contextPath}/login" method="post">
                        <div class="mb-3"> <%-- Margin bottom for form groups --%>
                            <label for="email" class="form-label">Email:</label>
                            <input type="email" class="form-control" id="email" name="email" required>
                        </div>

                        <div class="mb-3">
                            <label for="password" class="form-label">Password:</label>
                            <input type="password" class="form-control" id="password" name="password" required>
                        </div>

                        <div class="mb-4"> <%-- Slightly more margin before the button --%>
                            <label for="role" class="form-label">Role:</label>
                            <select class="form-select" id="role" name="role" required>
                                <option value="">-- Select Role --</option>
                                <option value="admin">Admin</option>
                                <option value="employee">Employee</option>
                            </select>
                        </div>

                        <div class="d-grid gap-2"> <%-- Makes the button full width and adds spacing if multiple buttons --%>
                            <button type="submit" class="btn btn-primary btn-lg">Login</button> <%-- Larger primary button --%>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js" integrity="sha384-YvpcrYf0tY3lHB60NNkmXc5s9fDVZLESaAA55NDzOxhy9GkcIdslK1eN7N6jIeHz" crossorigin="anonymous"></script>

</body>
</html>