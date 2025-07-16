package com.example.config;

import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public class AuthFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;
        HttpSession session = req.getSession(false);

        String uri = req.getRequestURI();
        String role = (session != null) ? (String) session.getAttribute("userRole") : null;

        if (session == null || session.getAttribute("userEmail") == null || role == null) {
            res.sendRedirect("/login?sessionExpired=true");
            return;
        }

        // Role-based access check
        if (uri.contains("/admin-dashboard") && !role.equals("admin")) {
            res.sendRedirect("/login?error=AccessDenied");
            return;
        }
        if (uri.contains("/emp-dashboard") && !role.equals("employee")) {
            res.sendRedirect("/login?error=AccessDenied");
            return;
        }

        chain.doFilter(request, response);
    }
}