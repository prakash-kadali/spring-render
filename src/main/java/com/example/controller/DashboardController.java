package com.example.controller;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.DayOfWeek;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.YearMonth; // New import for calendar logic
import java.util.HashMap; // New import for JSON response map
import java.util.HashSet;
import java.util.List;
import java.util.Map;   // New import for JSON response map
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody; // New import for API endpoints
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import com.example.entity.Announcement;
import com.example.entity.Attendance;
import com.example.entity.Department;
import com.example.entity.Designation;
import com.example.entity.Employee;
import com.example.entity.Holiday; // New: Import Holiday entity
import com.example.entity.LeaveRequest;
import com.example.entity.User;
import com.example.repository.AnnouncementRepository;
import com.example.repository.AttendanceRepository;
import com.example.repository.DepartmentRepository;
import com.example.repository.DesignationRepository;
import com.example.repository.EmployeeRepository;
import com.example.repository.HolidayRepository; // Already present, good!
import com.example.repository.LeaveRequestRepository;
import com.example.repository.UserRepository;
import com.example.service.ExcelExportService;
import com.example.service.PdfExportService;
import com.itextpdf.text.DocumentException;

import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

@Controller
public class DashboardController {
    @Autowired private DepartmentRepository deptRepo;
    @Autowired private DesignationRepository desigRepo;    
    @Autowired private EmployeeRepository empRepo;    
    @Autowired private UserRepository userRepo;
    @Autowired private HolidayRepository holidayRepo; // Already present
    @Autowired private AnnouncementRepository announcementRepo;
    @Autowired private ExcelExportService excelExportService; 
    @Autowired private PdfExportService pdfExportService;  
   @Autowired private AttendanceRepository  attendanceRepo;
   @Autowired private LeaveRequestRepository leaveRequestRepo;
    
    private static final double OFFICE_LATITUDE = 17.4379991; // Example: Madhapur, Hyderabad
    private static final double OFFICE_LONGITUDE = 78.3942691;
    private static final double ALLOWED_RADIUS_METERS = 100.0;

    @GetMapping("/")
public String redirectToLogin() {
    return "redirect:/login";
}

    @GetMapping("/login")
    public String showLoginForm(@RequestParam(value = "sessionExpired", required = false) String sessionExpired, Model model) {
        if (sessionExpired != null && sessionExpired.equals("true")) {
            model.addAttribute("errorMessage", "Your session has expired. Please log in again.");
        }
        return "login"; 
    }

    @PostMapping("/login")
    public String login(@RequestParam String email,
                        @RequestParam String password,
                        @RequestParam String role,
                        HttpSession session,
                        Model model) {

        Optional<User> optionalUser = userRepo.findByEmailAndPasswordAndRole(email, password, role);

        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            System.out.println("User found in DB - Email: " + user.getEmail() + ", Password: " + user.getPassword() + ", Role: " + user.getRole());

            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userRole", user.getRole());
            if (!user.getRole().equals(role)) {
                model.addAttribute("error", "Incorrect role selected");
                return "login";
            }

            session.setAttribute("userEmail", user.getEmail());
            session.setAttribute("userRole", user.getRole());
            session.setAttribute("password", user.getPassword());

            if ("admin".equals(role)) {
                System.out.println("Redirecting");
                return "redirect:/admin-dashboard";
            } else if ("employee".equals(role)) {
                return "redirect:/emp-dashboard";
            }
        }

        model.addAttribute("error", "Invalid credentials");
        return "login";
    }

    @GetMapping("/admin-dashboard")
    public String adminDashboard(
            @RequestParam(defaultValue = "0") int deptPage,
            @RequestParam(defaultValue = "0") int desigPage,
            @RequestParam(defaultValue = "0") int empPage,
            @RequestParam(defaultValue = "0") int userPage,
            @RequestParam(defaultValue = "5") int deptSize,
            @RequestParam(defaultValue = "5") int desigSize,    
            @RequestParam(defaultValue = "5") int empSize,    
            @RequestParam(defaultValue = "5") int userSize,
            @RequestParam(defaultValue = "0") int announcementPage,
            @RequestParam(defaultValue = "5") int announcementSize,
            @RequestParam(defaultValue = "createdAt") String announcementSortField, // Default sort to createdAt
            @RequestParam(defaultValue = "desc") String announcementSortDir,
            @RequestParam(defaultValue = "deptId") String deptSortField,
            @RequestParam(defaultValue = "asc") String deptSortDir,
            @RequestParam(defaultValue = "desigId") String desigSortField,
            @RequestParam(defaultValue = "asc") String desigSortDir,
            @RequestParam(defaultValue = "empId") String empSortField,
            @RequestParam(defaultValue = "asc") String empSortDir,
            @RequestParam(defaultValue = "userId") String userSortField,
            @RequestParam(defaultValue = "asc") String userSortDir,
            @RequestParam(required = false) String openPopup,
            @RequestParam(value = "tab", required = false) String tabb,
            @RequestParam(value = "employeeQuery", required = false) String employeeQuery,
            @RequestParam(value = "period", required = false, defaultValue = "month") String periodd,
            @RequestParam(value = "selectedDate", required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate selectedDate,
            // New: For active tab in JSP
            @RequestParam(name = "tab", required = false) String tab, 
            Model model) {

        // Set activeTab for JSP to correctly highlight sidebar/content
        model.addAttribute("activeTab", tab);

        if (deptSize < 1 || deptSize > 100) deptSize = 5;
        if (desigSize < 1 || desigSize > 100) desigSize = 5;
        if (empSize < 1 || empSize > 100) empSize = 5;
        if (userSize < 1 || userSize > 100) userSize = 5;

        // Populate department data
        Sort deptSort = Sort.by(deptSortDir.equalsIgnoreCase("asc") ? Sort.Direction.ASC : Sort.Direction.DESC, deptSortField);
        Pageable deptPageable = PageRequest.of(deptPage, deptSize, deptSort);
        Page<Department> departmentsPage = deptRepo.findAll(deptPageable);
        model.addAttribute("departments", departmentsPage.getContent());
        model.addAttribute("deptTotalPages", departmentsPage.getTotalPages());
        model.addAttribute("deptCurrentPage", deptPage);
        model.addAttribute("deptSize", deptSize);
        model.addAttribute("deptSortField", deptSortField);
        model.addAttribute("deptSortDir", deptSortDir);
        // Added for department badge count
        model.addAttribute("totalDepartments", deptRepo.count()); 

        // Populate designation data
        Sort desigSort = Sort.by(desigSortDir.equalsIgnoreCase("asc") ? Sort.Direction.ASC : Sort.Direction.DESC, desigSortField);
        Pageable desigPageable = PageRequest.of(desigPage, desigSize, desigSort);
        Page<Designation> designationPage = desigRepo.findAll(desigPageable);
        model.addAttribute("designations", designationPage.getContent());
        model.addAttribute("desigTotalPages", designationPage.getTotalPages());
        model.addAttribute("desigCurrentPage", desigPage);
        model.addAttribute("desigSize", desigSize);
        model.addAttribute("desigSortField", desigSortField);
        model.addAttribute("desigSortDir", desigSortDir);

        // Populate employee data
        Sort empSort = Sort.by(empSortDir.equalsIgnoreCase("asc") ? Sort.Direction.ASC : Sort.Direction.DESC, empSortField);
        Pageable empPageable = PageRequest.of(empPage, empSize, empSort);
        Page<Employee> employeePage = empRepo.findAll(empPageable);
        model.addAttribute("employees", employeePage.getContent());
        model.addAttribute("empTotalPages", employeePage.getTotalPages());
        model.addAttribute("empCurrentPage", empPage);
        model.addAttribute("empSize", empSize);
        model.addAttribute("empSortField", empSortField);
        model.addAttribute("empSortDir", empSortDir);
        model.addAttribute("totalEmployees", employeePage.getTotalElements()); // Already present, good!

        // Populate user data
        Sort userSort = Sort.by(userSortDir.equalsIgnoreCase("asc") ? Sort.Direction.ASC : Sort.Direction.DESC, userSortField);
        Pageable userPageable = PageRequest.of(userPage, userSize, userSort);
        Page<User> userPaged = userRepo.findAll(userPageable);
        model.addAttribute("users", userPaged.getContent());
        model.addAttribute("userTotalPages", userPaged.getTotalPages());
        model.addAttribute("userCurrentPage", userPage);
        model.addAttribute("userSize", userSize);
        model.addAttribute("userSortField", userSortField);
        model.addAttribute("userSortDir", userSortDir);
        
     // Validate announcementSize to prevent invalid values
        if (announcementSize < 1 || announcementSize > 100) announcementSize = 5;

        // For the "Active & Archived Announcements" list on the home tab
        Sort announcementListSort = Sort.by(announcementSortDir.equalsIgnoreCase("asc") ? Sort.Direction.ASC : Sort.Direction.DESC, announcementSortField);
        Pageable announcementPageable = PageRequest.of(announcementPage, announcementSize, announcementListSort);
        Page<Announcement> announcementsPage = announcementRepo.findAll(announcementPageable);
        model.addAttribute("allAnnouncements", announcementsPage.getContent());
        model.addAttribute("announcementTotalPages", announcementsPage.getTotalPages());
        model.addAttribute("announcementCurrentPage", announcementPage);
        model.addAttribute("announcementSize", announcementSize);
        model.addAttribute("announcementSortField", announcementSortField);
        model.addAttribute("announcementSortDir", announcementSortDir);


        // For the scrolling banner (only active announcements)
        List<Announcement> activeAnnouncements = announcementRepo.findByActiveTrueOrderByCreatedAtDesc();
        model.addAttribute("activeAnnouncements", activeAnnouncements);
        List<LeaveRequest> leaveRequests = leaveRequestRepo.findAll();
        long pendingLeaves = leaveRequestRepo.countByStatus("Pending");
        model.addAttribute("leaveRequests", leaveRequests);
        model.addAttribute("pendingLeaves", pendingLeaves);
        
        model.addAttribute("openPopup", openPopup);
        model.addAttribute("activeTab", tabb);
        model.addAttribute("period", periodd);
        model.addAttribute("selectedDate", selectedDate != null ? selectedDate : LocalDate.now());

        // Load all employees for suggestion list
        List<Employee> allEmployees = empRepo.findAll();
        model.addAttribute("employeeList", allEmployees);

        if ("statistics".equals(tab) && employeeQuery != null && !employeeQuery.isEmpty()) {
            Employee selectedEmployee = null;

            // Try to match by ID
            try {
                long id = Long.parseLong(employeeQuery.split("-")[0].trim());
                selectedEmployee = empRepo.findById(id).orElse(null);
            } catch (Exception e) {
                // Not ID, fallback to name/email
                for (Employee emp : allEmployees) {
                    String full = emp.getFirstName() + " " + emp.getLastName();
                    if (full.equalsIgnoreCase(employeeQuery) || emp.getEmail().equalsIgnoreCase(employeeQuery)) {
                        selectedEmployee = emp;
                        break;
                    }
                }
            }

            if (selectedEmployee != null) {
                model.addAttribute("selectedEmployee", selectedEmployee);

                LocalDate now = LocalDate.now();
                LocalDate start = periodd.equals("year") ? now.withDayOfYear(1) : now.withDayOfMonth(1);
                LocalDate end = periodd.equals("year") ? now.withDayOfYear(now.lengthOfYear()) : now.withDayOfMonth(now.lengthOfMonth());

                Set<LocalDate> holidays = new HashSet<>(holidayRepo.findHolidayDatesBetween(start, end));

                long totalWorkingDays = 0;
                for (LocalDate date = start; !date.isAfter(end); date = date.plusDays(1)) {
                    if (!isSunday(date) && !isSecondSaturday(date) && !holidays.contains(date)) {
                        totalWorkingDays++;
                    }
                }

                long presentDays = attendanceRepo.countByEmployeeAndAttendanceDateBetweenAndPresentTrue(selectedEmployee, start, end);

                List<LeaveRequest> approvedLeaves = leaveRequestRepo.findByEmployeeAndStatus(selectedEmployee, "Accepted");

                long leaveDays = approvedLeaves.stream()
                        .flatMap(lr -> lr.getStartDate().datesUntil(lr.getEndDate().plusDays(1)))
                        .filter(d -> !d.isBefore(start) && !d.isAfter(end))
                        .filter(d -> !isSunday(d) && !isSecondSaturday(d) && !holidays.contains(d))
                        .distinct()
                        .count();

                LocalDate date = selectedDate != null ? selectedDate : LocalDate.now();
                Optional<Attendance> attendance = attendanceRepo.findByEmployeeAndAttendanceDate(selectedEmployee, date);

                model.addAttribute("totalWorkingDays", totalWorkingDays);
                model.addAttribute("presentDays", presentDays);
                model.addAttribute("leavesTaken", leaveDays);
                model.addAttribute("checkInTime", attendance.map(Attendance::getCheckInTime).orElse(null));
                model.addAttribute("checkOutTime", attendance.map(Attendance::getCheckOutTime).orElse(null));
                model.addAttribute("leaveRequests", leaveRequestRepo.findByEmployee(selectedEmployee));
            } else {
                model.addAttribute("searchError", "No matching employee found.");
            }
        }
        return "admin-dashboard"  ;
    }
    
    @PostMapping("/admin/addAnnouncement")
    public String addAnnouncement(@RequestParam("message") String message,
                                  RedirectAttributes redirectAttributes) {
        if (message == null || message.trim().isEmpty()) {
            redirectAttributes.addFlashAttribute("error", "Announcement message cannot be empty.");
        } else {
            Announcement announcement = new Announcement(message);
            announcementRepo.save(announcement);
            redirectAttributes.addFlashAttribute("message", "Announcement added successfully!");
        }
        // Redirect back to the admin dashboard (home tab by default)
        return "redirect:/admin-dashboard";
    }

    @PostMapping("/admin/deleteAnnouncement")
    public String deleteAnnouncement(@RequestParam("id") Long id,
                                     RedirectAttributes redirectAttributes) {
        try {
            announcementRepo.deleteById(id);
            redirectAttributes.addFlashAttribute("message", "Announcement deleted successfully!");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "Failed to delete announcement: " + e.getMessage());
            System.err.println("Error deleting announcement: " + e.getMessage());
        }
        return "redirect:/admin-dashboard";
    }

    @PostMapping("/admin/toggleAnnouncementStatus")
    public String toggleAnnouncementStatus(@RequestParam("id") Long id,
                                           RedirectAttributes redirectAttributes) {
        Optional<Announcement> optionalAnnouncement = announcementRepo.findById(id);
        if (optionalAnnouncement.isPresent()) {
            Announcement announcement = optionalAnnouncement.get();
            announcement.setActive(!announcement.isActive()); // Toggle active status
            announcementRepo.save(announcement);
            redirectAttributes.addFlashAttribute("message", "Announcement status updated successfully!");
        } else {
            redirectAttributes.addFlashAttribute("error", "Announcement not found.");
        }
        return "redirect:/admin-dashboard";
    }

 // --- Holiday API Endpoints (New for Calendar) ---

    // Endpoint to fetch holidays for a given month and year
    @GetMapping("/api/holidays")
    @ResponseBody // This tells Spring to serialize the return object to JSON
    public List<Holiday> getHolidays(
            @RequestParam(name = "year", required = true) Integer year,
            @RequestParam(name = "month", required = true) Integer month) {

        YearMonth yearMonth = YearMonth.of(year, month);
        LocalDate startDate = yearMonth.atDay(1);
        LocalDate endDate = yearMonth.atEndOfMonth();

        return holidayRepo.findByDateBetween(startDate, endDate);
    }

    // Endpoint to declare a new holiday
    @PostMapping("/declare-holiday")
    @ResponseBody // This tells Spring to serialize the return object to JSON
    public Map<String, Object> declareHoliday(
            @RequestParam("date") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate date,
            @RequestParam("description") String description,
            @RequestParam(required = false) boolean recurring) {

        Map<String, Object> response = new HashMap<>();
        try {
            Optional<Holiday> existingHoliday = holidayRepo.findByDate(date);
            if (existingHoliday.isPresent()) {
                Holiday holidayToUpdate = existingHoliday.get();
                holidayToUpdate.setDescription(description);
                holidayRepo.save(holidayToUpdate);
                response.put("success", true);
                response.put("message", "Holiday for " + date + " updated successfully!");
            } else {
                Holiday holiday = new Holiday(date, description);
                holidayRepo.save(holiday);
                response.put("success", true);
                response.put("message", "Holiday declared successfully!");
            }
        } catch (DataIntegrityViolationException e) {
            response.put("success", false);
            response.put("message", "A holiday for this date already exists.");
            System.err.println("Data integrity violation declaring holiday: " + e.getMessage());
        } catch (Exception e) {
            response.put("success", false);
            response.put("message", "Failed to declare holiday: " + e.getMessage());
            System.err.println("Error declaring holiday: " + e.getMessage());
        }
        return response;
    } 

    @GetMapping("/emp-dashboard")
    public String showDashboard(
            @RequestParam(defaultValue = "0") int deptPage,
            @RequestParam(defaultValue = "0") int desigPage,
            @RequestParam(defaultValue = "0") int empPage,
            @RequestParam(defaultValue = "0") int userPage,
            @RequestParam(defaultValue = "5") int deptSize,
            @RequestParam(defaultValue = "5") int desigSize,    
            @RequestParam(defaultValue = "5") int empSize,    
            @RequestParam(defaultValue = "5") int userSize,
            @RequestParam(defaultValue = "0") int announcementPage,
            @RequestParam(defaultValue = "5") int announcementSize,
            @RequestParam(defaultValue = "createdAt") String announcementSortField, // Default sort to createdAt
            @RequestParam(defaultValue = "desc") String announcementSortDir,
            @RequestParam(defaultValue = "deptId") String deptSortField,
            @RequestParam(defaultValue = "asc") String deptSortDir,
            @RequestParam(defaultValue = "desigId") String desigSortField,
            @RequestParam(defaultValue = "asc") String desigSortDir,
            @RequestParam(defaultValue = "empId") String empSortField,
            @RequestParam(defaultValue = "asc") String empSortDir,
            @RequestParam(defaultValue = "userId") String userSortField,
            @RequestParam(defaultValue = "asc") String userSortDir,
            @RequestParam(required = false) String openPopup,
            @RequestParam(defaultValue = "home") String tab,
            @RequestParam(defaultValue = "month") String period,
                
            HttpSession  session,
            Model model) {

        if (deptSize < 1 || deptSize > 100) deptSize = 5;
        if (desigSize < 1 || desigSize > 100) desigSize = 5;
        if (empSize < 1 || empSize > 100) empSize = 5;
        if (userSize < 1 || userSize > 100) userSize = 5;

        Sort deptSort = Sort.by(deptSortDir.equalsIgnoreCase("asc") ? Sort.Direction.ASC : Sort.Direction.DESC, deptSortField);
        Pageable deptPageable = PageRequest.of(deptPage, deptSize, deptSort);
        Page<Department> departmentsPage = deptRepo.findAll(deptPageable);
        model.addAttribute("departments", departmentsPage.getContent());
        model.addAttribute("deptTotalPages", departmentsPage.getTotalPages());
        model.addAttribute("deptCurrentPage", deptPage);
        model.addAttribute("deptSize", deptSize);
        model.addAttribute("deptSortField", deptSortField);
        model.addAttribute("deptSortDir", deptSortDir);

        Sort desigSort = Sort.by(desigSortDir.equalsIgnoreCase("asc") ? Sort.Direction.ASC : Sort.Direction.DESC, desigSortField);
        Pageable desigPageable = PageRequest.of(desigPage, desigSize, desigSort);
        Page<Designation> designationPage = desigRepo.findAll(desigPageable);
        model.addAttribute("designations", designationPage.getContent());
        model.addAttribute("desigTotalPages", designationPage.getTotalPages());
        model.addAttribute("desigCurrentPage", desigPage);
        model.addAttribute("desigSize", desigSize);
        model.addAttribute("desigSortField", desigSortField);
        model.addAttribute("desigSortDir", desigSortDir);

        Sort empSort = Sort.by(empSortDir.equalsIgnoreCase("asc") ? Sort.Direction.ASC : Sort.Direction.DESC, empSortField);
        Pageable empPageable = PageRequest.of(empPage, empSize, empSort);
        Page<Employee> employeePage = empRepo.findAll(empPageable);
        model.addAttribute("employees", employeePage.getContent());
        model.addAttribute("empTotalPages", employeePage.getTotalPages());
        model.addAttribute("empCurrentPage", empPage);
        model.addAttribute("empSize", empSize);
        model.addAttribute("empSortField", empSortField);
        model.addAttribute("empSortDir", empSortDir);
        model.addAttribute("totalEmployees", employeePage.getTotalElements());

        Sort userSort = Sort.by(userSortDir.equalsIgnoreCase("asc") ? Sort.Direction.ASC : Sort.Direction.DESC, userSortField);
        Pageable userPageable = PageRequest.of(userPage, userSize, userSort);
        Page<User> userPaged = userRepo.findAll(userPageable);
        model.addAttribute("users", userPaged.getContent());
        model.addAttribute("userTotalPages", userPaged.getTotalPages());
        model.addAttribute("userCurrentPage", userPage);
        model.addAttribute("userSize", userSize);
        model.addAttribute("userSortField", userSortField);
        model.addAttribute("userSortDir", userSortDir);
        
        if (announcementSize < 1 || announcementSize > 100) announcementSize = 5;

        // For the "Active & Archived Announcements" list on the home tab
        Sort announcementListSort = Sort.by(announcementSortDir.equalsIgnoreCase("asc") ? Sort.Direction.ASC : Sort.Direction.DESC, announcementSortField);
        Pageable announcementPageable = PageRequest.of(announcementPage, announcementSize, announcementListSort);
        Page<Announcement> announcementsPage = announcementRepo.findAll(announcementPageable);
        model.addAttribute("allAnnouncements", announcementsPage.getContent());
        model.addAttribute("announcementTotalPages", announcementsPage.getTotalPages());
        model.addAttribute("announcementCurrentPage", announcementPage);
        model.addAttribute("announcementSize", announcementSize);
        model.addAttribute("announcementSortField", announcementSortField);
        model.addAttribute("announcementSortDir", announcementSortDir);


        // For the scrolling banner (only active announcements)
        List<Announcement> activeAnnouncements = announcementRepo.findByActiveTrueOrderByCreatedAtDesc();
        model.addAttribute("activeAnnouncements", activeAnnouncements);
        
        String email = (String) session.getAttribute("userEmail");
        Employee employee = empRepo.findByEmail(email);
        if (employee != null) {
            List<LeaveRequest> leaveRequests = leaveRequestRepo.findByEmployee(employee);
            model.addAttribute("leaveRequests", leaveRequests);
        }
        if ("statistics".equals(tab) && employee != null) {
            LocalDate now = LocalDate.now();
            LocalDate start, end;

            if ("year".equals(period)) {
                start = now.withDayOfYear(1);
                end = now.withDayOfYear(now.lengthOfYear());
            } else {
                start = now.withDayOfMonth(1);
                end = now.withDayOfMonth(now.lengthOfMonth());
            }

            // Get holidays between start and end
            List<LocalDate> holidays = holidayRepo.findHolidayDatesBetween(start, end);
            Set<LocalDate> holidaySet = new HashSet<>(holidays);

            // Count total working days (excluding Sundays, 2nd Saturdays, and holidays)
            long totalWorkingDays = 0;
            LocalDate date = start;
            while (!date.isAfter(end)) {
                if (!isSunday(date) && !isSecondSaturday(date) && !holidaySet.contains(date)) {
                    totalWorkingDays++;
                }
                date = date.plusDays(1);
            }

            // Count Present Days
            long presentDays = attendanceRepo.countByEmployeeAndAttendanceDateBetweenAndPresentTrue(employee, start, end);

            // Count actual leave days taken (not just requests)
            List<LeaveRequest> approvedLeaves = leaveRequestRepo.findByEmployeeAndStatus(employee, "Accepted"); // fix status

            long leaveDaysInPeriod = approvedLeaves.stream()
                .flatMap(lr -> lr.getStartDate().datesUntil(lr.getEndDate().plusDays(1)))
                .filter(d -> !d.isBefore(start) && !d.isAfter(end))
                .filter(d -> !isSunday(d) && !isSecondSaturday(d) && !holidaySet.contains(d))
                .distinct()
                .count();

            model.addAttribute("presentDays", presentDays);
            model.addAttribute("totalWorkingDays", totalWorkingDays);
            model.addAttribute("leavesTaken", leaveDaysInPeriod);
            model.addAttribute("period", period);
        }
        




        
        model.addAttribute("openPopup", openPopup);
        model.addAttribute("activeTab", tab); // for tab switching in JSP


        return "emp-dashboard";
    }

    @GetMapping("/export/departments/excel")
    public void exportDepartmentsToExcel(HttpServletResponse response) throws IOException {
        List<Department> departments = deptRepo.findAll();
        excelExportService.exportDepartmentsToExcel(departments, response);
    }

    @GetMapping("/export/departments/pdf")
    public void exportDepartmentsToPdf(HttpServletResponse response) throws DocumentException, IOException {
        List<Department> departments = deptRepo.findAll();
        pdfExportService.exportDepartmentsToPdf(departments, response);
    }

    @GetMapping("/export/designations/excel")
    public void exportDesignationsToExcel(HttpServletResponse response) throws IOException {
        List<Designation> designations = desigRepo.findAll();
        excelExportService.exportDesignationsToExcel(designations, response);
    }

    @GetMapping("/export/designations/pdf")
    public void exportDesignationsToPdf(HttpServletResponse response) throws DocumentException, IOException {
        List<Designation> designations = desigRepo.findAll();
        pdfExportService.exportDesignationsToPdf(designations, response);
    }
    
    @GetMapping("/export/employees/excel")
    public void exportEmployeesToExcel(HttpServletResponse response) throws IOException {
        List<Employee> employees = empRepo.findAll();
        excelExportService.exportEmployeesToExcel(employees, response);
    }

    @GetMapping("/export/employees/pdf")
    public void exportEmployeesToPdf(HttpServletResponse response) throws DocumentException, IOException {
        List<Employee> employees = empRepo.findAll();
        pdfExportService.exportEmployeesToPdf(employees, response);
    }

    @GetMapping("/export/users/excel")
    public void exportUsersToExcel(HttpServletResponse response) throws IOException {
        List<User> users = userRepo.findAll();
        excelExportService.exportUsersToExcel(users, response);
    }

    @GetMapping("/export/users/pdf")
    public void exportUsersToPdf(HttpServletResponse response) throws DocumentException, IOException {
        List<User> users = userRepo.findAll();
        pdfExportService.exportUsersToPdf(users, response);
    }

    @PostMapping("/addDepartment")
    public String addDepartment(@RequestParam Long deptId, @RequestParam String name,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate createdDate,
            @RequestParam String mail, RedirectAttributes redirectAttributes) {
        Department dept = new Department();
        dept.setDeptId(deptId);
        dept.setName(name);
        dept.setCreatedDate(createdDate);
        dept.setMail(mail);
        deptRepo.save(dept);
        redirectAttributes.addFlashAttribute("message", "Department added successfully");
        return "redirect:/admin-dashboard?tab=departments";
    }

    @PostMapping("/deleteDepartment")
    public String deleteDepartment(@RequestParam Long id, RedirectAttributes redirectAttributes) {
        try {
            deptRepo.deleteById(id);
            redirectAttributes.addFlashAttribute("message", "Department deleted successfully");
        } catch (DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("error", "Cannot delete department: It is currently assigned to one or more employees. Please reassign the employees before deleting this department.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "An unexpected error occurred while deleting the department. Please try again.");
            e.printStackTrace(); 
        }
        return "redirect:/admin-dashboard?tab=departments";
    }

    @PostMapping("/deleteDesignation")
    public String deleteDesignation(@RequestParam("id") Long id, RedirectAttributes redirectAttributes) {
        try {
            desigRepo.deleteById(id);
            redirectAttributes.addFlashAttribute("message", "Designation deleted successfully.");
        } catch (DataIntegrityViolationException e) {
            redirectAttributes.addFlashAttribute("error", "Cannot delete designation: It is currently assigned to one or more employees. Please reassign the employees before deleting this designation.");
        } catch (Exception e) {
            redirectAttributes.addFlashAttribute("error", "An unexpected error occurred while deleting the designation. Please try again.");
            e.printStackTrace(); 
        }
        return "redirect:/admin-dashboard?tab=designations";
    }

    @PostMapping("/addDesignation")
    public String addDesignation(@RequestParam Long desigId,
            @RequestParam("title") String title,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate createdDate,
            @RequestParam String dmail, RedirectAttributes redirectAttributes) {
        Designation desig = new Designation();
        desig.setTitle(title);
        desig.setDesigId(desigId);
        desig.setDmail(dmail);
        desig.setCreatedDate(createdDate);
        desigRepo.save(desig);
        redirectAttributes.addFlashAttribute("message", "Designation added successfully.");
        return "redirect:/admin-dashboard?tab=designations";
    }

    @PostMapping("/deleteEmployee")
    public String deleteEmployee(@RequestParam("id") Long empId, RedirectAttributes redirectAttributes) {
        empRepo.deleteById(empId);
        redirectAttributes.addFlashAttribute("message", "Employee deleted successfully.");
        return "redirect:/admin-dashboard?tab=employees";
    }

    @PostMapping("/employee/upload-photo")
    public String uploadPhoto(
            @RequestParam("empId") Long empId,
            @RequestParam("file") MultipartFile file,
            RedirectAttributes redirectAttributes) {
        try {
            if (!file.isEmpty()) {
                Employee employee = empRepo.findById(empId)
                        .orElseThrow(() -> new IllegalArgumentException("Invalid employee ID"));

                String fileName = "emp_" + empId + "_" + file.getOriginalFilename();
                Path path = Paths.get("src/main/resources/static/images/employees/" + fileName);
                Files.createDirectories(path.getParent());
                Files.write(path, file.getBytes());

                employee.setPhotoUrl("/images/employees/" + fileName);
                empRepo.save(employee);

                redirectAttributes.addFlashAttribute("message", "Photo uploaded successfully.");
            } else {
                redirectAttributes.addFlashAttribute("error", "Please select a file to upload.");
            }
        } catch (IOException e) {
            redirectAttributes.addFlashAttribute("error", "Failed to upload photo: " + e.getMessage());
        }
        return "redirect:/admin-dashboard?tab=employees";
    }

    @GetMapping("/employee/photo/{empId}")
    public String viewPhoto(@RequestParam Long empId, Model model) {
        Employee employee = empRepo.findById(empId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid employee ID"));
        model.addAttribute("photoUrl", employee.getPhotoUrl() != null ? employee.getPhotoUrl() : "/images/default.jpg");
        return "view-photo";
    }

    @PostMapping("/addEmployee")
    public String addEmployee(
            @RequestParam("empId") Long empId,
            @RequestParam("name") String name,
            @RequestParam("email") String email,
            @RequestParam("phone") Long phone,
            @RequestParam("hiredate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate hiredate,
            @RequestParam("firstName") String firstName,
            @RequestParam("lastName") String lastName,
            @RequestParam("salary") Double salary,
            @RequestParam("deptId") Long deptId,
            @RequestParam("desigId") Long desigId,
            @RequestParam("accountNumber") Long accountNumber,
            @RequestParam(value = "file", required = false) MultipartFile file,
            RedirectAttributes redirectAttributes) {

        Employee emp = new Employee();
        Department dept = deptRepo.findById(deptId).orElse(null);
        Designation desig = desigRepo.findById(desigId).orElse(null);
        emp.setEmpId(empId);
        emp.setName(name);
        emp.setEmail(email);
        emp.setPhone(phone);
        emp.setHiredate(hiredate);
        emp.setFirstName(firstName);
        emp.setLastName(lastName);
        emp.setSalary(salary);
        emp.setDept(dept);
        emp.setDesig(desig);
        emp.setAccountNumber(accountNumber);
        try {
            if (file != null && !file.isEmpty()) {
                String fileName = "emp_" + empId + "_" + file.getOriginalFilename();
                Path path = Paths.get("src/main/resources/static/images/employees/" + fileName);
                Files.createDirectories(path.getParent());
                Files.write(path, file.getBytes());
                emp.setPhotoUrl("/images/employees/" + fileName);
            }
        } catch (IOException e) {
            redirectAttributes.addFlashAttribute("error", "Failed to upload photo: " + e.getMessage());
        }

        empRepo.save(emp);
        redirectAttributes.addFlashAttribute("message", "Employee added successfully.");
        return "redirect:/admin-dashboard?tab=employees";
    }
       
    @PostMapping("/add-user")
    public String addUser(
                          @RequestParam String username,
                          @RequestParam String password,
                          @RequestParam String email,
                          @RequestParam String role,
                          RedirectAttributes redirectAttributes) {

        User user = new User();
     
        user.setUsername(username);
        user.setEmail(email);
        user.setPassword(password);
        user.setRole(role);
        userRepo.save(user);

        redirectAttributes.addAttribute("tab", "users");
        return "redirect:/admin-dashboard?tab=users";
    }

    @PostMapping("/delete-user") 
    public String deleteUser(@RequestParam Long id, RedirectAttributes redirectAttributes) {
        Optional<User> userOpt = userRepo.findById(id);
        if (userOpt.isPresent()) {
            User user = userOpt.get();
            
            if ("admin".equalsIgnoreCase(user.getRole())) {
                redirectAttributes.addFlashAttribute("error", "Admin user cannot be deleted.");
            } else {
                userRepo.deleteById(id);
                redirectAttributes.addFlashAttribute("message", "User deleted successfully.");
            }
        } else {
            redirectAttributes.addFlashAttribute("error", "User not found.");
        }
        return "redirect:/admin-dashboard?tab=users";
    }
    @GetMapping("/api/employee/suggestions")
    @ResponseBody
    public List<Map<String, String>> getEmployeeSuggestions(@RequestParam("query") String query) {
        List<Employee> matches;
        try {
            Long id = Long.parseLong(query);
            matches = empRepo.findByEmpIdOrFirstNameContainingIgnoreCaseOrLastNameContainingIgnoreCaseOrEmailContainingIgnoreCase(
                id, query, query, query);
        } catch (NumberFormatException e) {
            matches = empRepo.findByFirstNameContainingIgnoreCaseOrLastNameContainingIgnoreCaseOrEmailContainingIgnoreCase(
                query, query, query);
        }

        return matches.stream().map(emp -> {
            Map<String, String> map = new HashMap<>();
            map.put("empId", emp.getEmpId().toString());
            map.put("name", emp.getFirstName() + " " + emp.getLastName());
            map.put("email", emp.getEmail());
            return map;
        }).collect(Collectors.toList());
    }
    @GetMapping("/search-employees")
    @ResponseBody
    public List<Map<String, String>> searchEmployees(@RequestParam("query") String query) {
        List<Employee> matches = empRepo.findByEmpIdOrNameOrEmailContaining(query);
        return matches.stream().map(emp -> {
            Map<String, String> map = new HashMap<>();
            map.put("empId", emp.getEmpId() + "");
            map.put("firstName", emp.getFirstName());
            map.put("lastName", emp.getLastName());
            map.put("email", emp.getEmail());
            return map;
        }).collect(Collectors.toList());
    }


    @PostMapping("/employee/check-in")
    public String checkIn(@RequestParam("latitude") double latitude,
                          @RequestParam("longitude") double longitude,
                          HttpSession session, RedirectAttributes redirectAttributes) {
        String email = (String) session.getAttribute("userEmail");
        Employee employee = empRepo.findByEmail(email);
        

        if (employee == null) {
            redirectAttributes.addFlashAttribute("error", "Employee not found.");
            return "redirect:/emp-dashboard";
        }

        double distance = calculateDistance(latitude, longitude, OFFICE_LATITUDE, OFFICE_LONGITUDE);
        if (distance > ALLOWED_RADIUS_METERS) {
            redirectAttributes.addFlashAttribute("error", "Check-in denied. You are not at office location.");
            return "redirect:/emp-dashboard";
        }

        LocalDate today = LocalDate.now();
        Optional<Attendance> existing = attendanceRepo.findByEmployeeAndAttendanceDate(employee, today);

        if (existing.isPresent()) {
            redirectAttributes.addFlashAttribute("error", "You have already checked in today.");
        } else {
            Attendance attendance = new Attendance();
            attendance.setEmployee(employee);
            attendance.setAttendanceDate(today);
            attendance.setCheckInTime(LocalDateTime.now());
            
            attendanceRepo.save(attendance);
            redirectAttributes.addFlashAttribute("message", "Check-in successful.");
        }

        return "redirect:/emp-dashboard";
    }


    @PostMapping("/employee/check-out")
    public String checkOut(@RequestParam("latitude") double latitude,
                           @RequestParam("longitude") double longitude,
                           HttpSession session, RedirectAttributes redirectAttributes) {

        String email = (String) session.getAttribute("userEmail");
        Employee employee = empRepo.findByEmail(email);

        if (employee == null) {
            redirectAttributes.addFlashAttribute("error", "Employee not found.");
            return "redirect:/emp-dashboard";
        }

        double distance = calculateDistance(latitude, longitude, OFFICE_LATITUDE, OFFICE_LONGITUDE);
        if (distance > ALLOWED_RADIUS_METERS) {
            redirectAttributes.addFlashAttribute("error", "Check-out denied. You are not at office location.");
            return "redirect:/emp-dashboard";
        }

        LocalDate today = LocalDate.now();
        Optional<Attendance> existing = attendanceRepo.findByEmployeeAndAttendanceDate(employee, today);

        if (existing.isPresent()) {
            Attendance attendance = existing.get();
            if (attendance.getCheckOutTime() != null) {
                redirectAttributes.addFlashAttribute("error", "You have already checked out.");
                return "redirect:/emp-dashboard";
            }

            if (attendance.getCheckInTime() == null) {
                redirectAttributes.addFlashAttribute("error", "Check-in not found for today.");
                return "redirect:/emp-dashboard";
            }

            // ✅ Calculate duration between check-in and now
            Duration duration = Duration.between(attendance.getCheckInTime(), LocalDateTime.now());

            if (duration.toHours() < 8) {
                long hours = duration.toHours();
                long minutes = duration.toMinutesPart(); // Java 9+
                redirectAttributes.addFlashAttribute("error",
                    "You can check out only after 8 hours. Time worked so far: " + hours + "h " + minutes + "m");
                return "redirect:/emp-dashboard";
            }

            // ✅ All conditions passed — save check-out time
            attendance.setCheckOutTime(LocalDateTime.now());
            attendanceRepo.save(attendance);
            redirectAttributes.addFlashAttribute("message", "Check-out successful.");

        } else {
            redirectAttributes.addFlashAttribute("error", "Check-in not found for today.");
        }

        return "redirect:/emp-dashboard";
    }

    private double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
        final int R = 6371000; // Radius of the earth in meters
        double latDistance = Math.toRadians(lat2 - lat1);
        double lonDistance = Math.toRadians(lon2 - lon1);
        double a = Math.sin(latDistance / 2) * Math.sin(latDistance / 2)
                + Math.cos(Math.toRadians(lat1)) * Math.cos(Math.toRadians(lat2))
                * Math.sin(lonDistance / 2) * Math.sin(lonDistance / 2);
        double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }

    @PostMapping("/employee/request-leave")
    public String requestLeave(@RequestParam("startDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
                               @RequestParam("endDate") @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
                               @RequestParam("reason") String reason,
                               HttpSession session,
                               RedirectAttributes redirectAttributes) {

        String email = (String) session.getAttribute("userEmail");
        Employee employee = empRepo.findByEmail(email);

        if (employee == null) {
            redirectAttributes.addFlashAttribute("error", "Employee not found.");
            return "redirect:/emp-dashboard?tab=leaves";
        }

        if (endDate.isBefore(startDate)) {
            redirectAttributes.addFlashAttribute("error", "End date cannot be before start date.");
            return "redirect:/emp-dashboard?tab=leaves";
        }

        LeaveRequest request = new LeaveRequest(employee, startDate, endDate, reason);
        leaveRequestRepo.save(request);
        redirectAttributes.addFlashAttribute("message", "Leave request submitted.");
        return "redirect:/emp-dashboard?tab=leaves";
    }
    @PostMapping("/admin/handle-leave")
    public String handleLeave(@RequestParam Long requestId,
                              @RequestParam String action,
                              RedirectAttributes redirectAttributes) {

        Optional<LeaveRequest> optional = leaveRequestRepo.findById(requestId);
        if (optional.isPresent()) {
            LeaveRequest request = optional.get();
            request.setStatus("approve".equalsIgnoreCase(action) ? "Accepted" : "Rejected");
            leaveRequestRepo.save(request);
            redirectAttributes.addFlashAttribute("message", "Leave request " + action + "d.");
        } else {
            redirectAttributes.addFlashAttribute("error", "Leave request not found.");
        }

        return "redirect:/admin-dashboard?tab=leaves";
    }
    
    public long calculateWorkingDays(LocalDate startDate, LocalDate endDate, List<LocalDate> holidays) {
        long workingDays = 0;
        LocalDate date = startDate;

        while (!date.isAfter(endDate)) {
            boolean isWeekend = date.getDayOfWeek() == java.time.DayOfWeek.SATURDAY ||
                                date.getDayOfWeek() == java.time.DayOfWeek.SUNDAY;
            boolean isHoliday = holidays.contains(date);

            if (!isWeekend && !isHoliday) {
                workingDays++;
            }

            date = date.plusDays(1);
        }

        return workingDays;
    }
    private boolean isSunday(LocalDate date) {
        return date.getDayOfWeek() == DayOfWeek.SUNDAY;
    }

    private boolean isSecondSaturday(LocalDate date) {
        if (date.getDayOfWeek() != DayOfWeek.SATURDAY) return false;

        // Find how many Saturdays occurred before this date in the same month
        LocalDate firstDay = date.withDayOfMonth(1);
        int count = 0;

        for (int i = 0; i < date.getDayOfMonth(); i++) {
            LocalDate current = firstDay.plusDays(i);
            if (current.getDayOfWeek() == DayOfWeek.SATURDAY) {
                count++;
            }
        }

        return count == 2;
    }


    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}