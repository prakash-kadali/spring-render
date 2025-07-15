package com.example.service;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.Date;
import java.util.List;

import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.FillPatternType;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.stereotype.Service;
import org.apache.poi.ss.usermodel.DataFormat; // Import for DataFormat

// Adjust these imports to match your actual entity package names
import com.example.entity.Department;
import com.example.entity.Designation;
import com.example.entity.Employee;
import com.example.entity.User;

import jakarta.servlet.ServletOutputStream;
import jakarta.servlet.http.HttpServletResponse;

@Service
public class ExcelExportService {

    // --- Configuration Constants ---
    private static final int DEFAULT_FONT_SIZE = 10;
    private static final int SMALL_FONT_SIZE = 8; // Font size for long text
    private static final int MAX_CHARS_FOR_DEFAULT_FONT = 30; // Threshold to reduce font size

    // --- Helper Methods for common Excel operations ---

    private void prepareResponse(HttpServletResponse response, String filename) {
        response.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        String headerKey = "Content-Disposition";
        String headerValue = "attachment; filename=" + filename;
        response.setHeader(headerKey, headerValue);
    }

    private void createHeaderRow(Sheet sheet, Workbook workbook, String[] headers) {
        Row headerRow = sheet.createRow(0);

        CellStyle style = workbook.createCellStyle();
        Font font = workbook.createFont();
        font.setBold(true);
        font.setFontHeightInPoints((short) 12);
        style.setFont(font);
        style.setFillForegroundColor(IndexedColors.GREY_25_PERCENT.getIndex());
        style.setFillPattern(FillPatternType.SOLID_FOREGROUND);
        style.setAlignment(HorizontalAlignment.CENTER);
        style.setWrapText(false);

        for (int i = 0; i < headers.length; i++) {
            Cell cell = headerRow.createCell(i);
            cell.setCellValue(headers[i]);
            cell.setCellStyle(style);
        }
    }

    private void createCell(Row row, int columnCount, Object value, CellStyle baseStyle, Workbook workbook) {
        Cell cell = row.createCell(columnCount);
        String stringValue = "";

        // Determine the actual type and set cell value
        if (value instanceof String) {
            stringValue = (String) value;
            cell.setCellValue(stringValue);
        } else if (value instanceof Integer) {
            cell.setCellValue((Integer) value);
            stringValue = value.toString();
        } else if (value instanceof Long) {
            cell.setCellValue((Long) value);
            stringValue = value.toString();
        } else if (value instanceof Double) {
            cell.setCellValue((Double) value);
            stringValue = value.toString();
        } else if (value instanceof Boolean) {
            cell.setCellValue((Boolean) value);
            stringValue = value.toString();
        } else if (value instanceof Date) {
            cell.setCellValue((Date) value);
            stringValue = new java.text.SimpleDateFormat("yyyy-MM-dd").format((Date) value);
        } else if (value instanceof LocalDate) {
            stringValue = ((LocalDate) value).format(DateTimeFormatter.ISO_LOCAL_DATE);
            cell.setCellValue(stringValue);
        } else if (value != null) {
            stringValue = value.toString();
            cell.setCellValue(stringValue);
        } else {
            cell.setCellValue("");
            stringValue = "";
        }

        CellStyle cellStyle = workbook.createCellStyle();
        cellStyle.cloneStyleFrom(baseStyle);

        if (stringValue.length() > MAX_CHARS_FOR_DEFAULT_FONT) {
            Font smallFont = workbook.createFont();
            smallFont.setFontHeightInPoints((short) SMALL_FONT_SIZE);
            cellStyle.setFont(smallFont);
        } else {
             Font defaultFont = workbook.createFont();
             defaultFont.setFontHeightInPoints((short) DEFAULT_FONT_SIZE);
             cellStyle.setFont(defaultFont);
        }

        cellStyle.setWrapText(false);

        cell.setCellStyle(cellStyle);
    }

    private void autoSizeColumnsByHeaderCount(Sheet sheet) {
        Row headerRow = sheet.getRow(0);
        if (headerRow != null) {
            for (int i = 0; i < headerRow.getLastCellNum(); i++) {
                sheet.autoSizeColumn(i);
            }
        }
    }


    // --- Export Methods for Different Entities ---

    public void exportDepartmentsToExcel(List<Department> departments, HttpServletResponse response) throws IOException {
        Workbook workbook = new XSSFWorkbook();

        if (workbook.getNumberOfSheets() > 0) {
            workbook.removeSheetAt(0);
        }

        Sheet sheet = workbook.createSheet("Departments");

        String[] headers = {"Department ID", "Name", "Created Date", "Mail"};
        createHeaderRow(sheet, workbook, headers);

        sheet.createFreezePane(0, 1); // Freeze the first row (row 0)

        CellStyle dataStyle = workbook.createCellStyle();
        Font defaultDataFont = workbook.createFont();
        defaultDataFont.setFontHeightInPoints((short) DEFAULT_FONT_SIZE);
        dataStyle.setFont(defaultDataFont);
        dataStyle.setAlignment(HorizontalAlignment.CENTER);
        dataStyle.setWrapText(false);

        CellStyle dateStyle = workbook.createCellStyle();
        dateStyle.cloneStyleFrom(dataStyle);
        dateStyle.setDataFormat(workbook.createDataFormat().getFormat("yyyy-MM-dd"));

        int rowNum = 1;
        for (Department dept : departments) {
            Row row = sheet.createRow(rowNum++);
            createCell(row, 0, dept.getDeptId(), dataStyle, workbook);
            createCell(row, 1, dept.getName(), dataStyle, workbook);

            Cell dateCell = row.createCell(2);
            if (dept.getCreatedDate() != null) {
                dateCell.setCellValue(dept.getCreatedDate());
            } else {
                dateCell.setCellValue("");
            }
            dateCell.setCellStyle(dateStyle);

            createCell(row, 3, dept.getMail(), dataStyle, workbook);
        }

        autoSizeColumnsByHeaderCount(sheet);

        prepareResponse(response, "departments.xlsx");
        ServletOutputStream outputStream = response.getOutputStream();
        workbook.write(outputStream);
        workbook.close();
        outputStream.close();
    }

    public void exportDesignationsToExcel(List<Designation> designations, HttpServletResponse response) throws IOException {
        Workbook workbook = new XSSFWorkbook();

        if (workbook.getNumberOfSheets() > 0) {
            workbook.removeSheetAt(0);
        }

        Sheet sheet = workbook.createSheet("Designations");

        String[] headers = {"Designation ID", "Title", "Created Date", "Mail"};
        createHeaderRow(sheet, workbook, headers);

        sheet.createFreezePane(0, 1); // Freeze the first row (row 0)

        CellStyle dataStyle = workbook.createCellStyle();
        Font defaultDataFont = workbook.createFont();
        defaultDataFont.setFontHeightInPoints((short) DEFAULT_FONT_SIZE);
        dataStyle.setFont(defaultDataFont);
        dataStyle.setAlignment(HorizontalAlignment.CENTER);
        dataStyle.setWrapText(false);

        CellStyle dateStyle = workbook.createCellStyle();
        dateStyle.cloneStyleFrom(dataStyle);
        dateStyle.setDataFormat(workbook.createDataFormat().getFormat("yyyy-MM-dd"));

        int rowNum = 1;
        for (Designation desig : designations) {
            Row row = sheet.createRow(rowNum++);
            createCell(row, 0, desig.getDesigId(), dataStyle, workbook);
            createCell(row, 1, desig.getTitle(), dataStyle, workbook);

            Cell dateCell = row.createCell(2);
            if (desig.getCreatedDate() != null) {
                dateCell.setCellValue(desig.getCreatedDate());
            } else {
                dateCell.setCellValue("");
            }
            dateCell.setCellStyle(dateStyle);

            createCell(row, 3, desig.getDmail(), dataStyle, workbook);
        }

        autoSizeColumnsByHeaderCount(sheet);

        prepareResponse(response, "designations.xlsx");
        ServletOutputStream outputStream = response.getOutputStream();
        workbook.write(outputStream);
        workbook.close();
        outputStream.close();
    }

    public void exportEmployeesToExcel(List<Employee> employees, HttpServletResponse response) throws IOException {
        Workbook workbook = new XSSFWorkbook();

        if (workbook.getNumberOfSheets() > 0) {
            workbook.removeSheetAt(0);
        }

        Sheet sheet = workbook.createSheet("Employees");

        String[] headers = {"Employee ID", "Name", "Email", "Phone", "Hire Date", "First Name", "Last Name", "Salary", "Department", "Designation", "Account Number"};
        createHeaderRow(sheet, workbook, headers);

        sheet.createFreezePane(0, 1); // Freeze the first row (row 0)

        CellStyle dataStyle = workbook.createCellStyle();
        Font defaultDataFont = workbook.createFont();
        defaultDataFont.setFontHeightInPoints((short) DEFAULT_FONT_SIZE);
        dataStyle.setFont(defaultDataFont);
        dataStyle.setAlignment(HorizontalAlignment.CENTER);
        dataStyle.setWrapText(false);

        CellStyle dateStyle = workbook.createCellStyle();
        dateStyle.cloneStyleFrom(dataStyle);
        dateStyle.setDataFormat(workbook.createDataFormat().getFormat("yyyy-MM-dd"));

        // --- NEW STYLE FOR ACCOUNT NUMBER (TEXT FORMAT) ---
        CellStyle accountNumberStyle = workbook.createCellStyle();
        accountNumberStyle.cloneStyleFrom(dataStyle); // Inherit alignment and font
        // Crucial for displaying large numbers as text
        accountNumberStyle.setDataFormat(workbook.createDataFormat().getFormat("@")); // "@" is the text format

        int rowNum = 1;
        for (Employee emp : employees) {
            Row row = sheet.createRow(rowNum++);
            createCell(row, 0, emp.getEmpId(), dataStyle, workbook);
            createCell(row, 1, emp.getName(), dataStyle, workbook);
            createCell(row, 2, emp.getEmail(), dataStyle, workbook);
            createCell(row, 3, emp.getPhone(), dataStyle, workbook);

            Cell hireDateCell = row.createCell(4);
            if (emp.getHiredate() != null) {
                hireDateCell.setCellValue(emp.getHiredate());
            } else {
                hireDateCell.setCellValue("");
            }
            hireDateCell.setCellStyle(dateStyle);

            createCell(row, 5, emp.getFirstName(), dataStyle, workbook);
            createCell(row, 6, emp.getLastName(), dataStyle, workbook);
            createCell(row, 7, emp.getSalary(), dataStyle, workbook);
            createCell(row, 8, emp.getDept() != null ? emp.getDept().getName() : "N/A", dataStyle, workbook);
            createCell(row, 9, emp.getDesig() != null ? emp.getDesig().getTitle() : "N/A", dataStyle, workbook);

            // Apply the new account number style
            createCell(row, 10, emp.getAccountNumber(), accountNumberStyle, workbook);
        }

        autoSizeColumnsByHeaderCount(sheet);

        prepareResponse(response, "employees.xlsx");
        ServletOutputStream outputStream = response.getOutputStream();
        workbook.write(outputStream);
        workbook.close();
        outputStream.close();
    }

    public void exportUsersToExcel(List<User> users, HttpServletResponse response) throws IOException {
        Workbook workbook = new XSSFWorkbook();

        if (workbook.getNumberOfSheets() > 0) {
            workbook.removeSheetAt(0);
        }

        Sheet sheet = workbook.createSheet("Users");

        String[] headers = {"User ID", "Username", "Email", "Role"};
        createHeaderRow(sheet, workbook, headers);

        sheet.createFreezePane(0, 1); // Freeze the first row (row 0)

        CellStyle dataStyle = workbook.createCellStyle();
        Font defaultDataFont = workbook.createFont();
        defaultDataFont.setFontHeightInPoints((short) DEFAULT_FONT_SIZE);
        dataStyle.setFont(defaultDataFont);
        dataStyle.setAlignment(HorizontalAlignment.CENTER);
        dataStyle.setWrapText(false);

        int rowNum = 1;
        for (User user : users) {
            Row row = sheet.createRow(rowNum++);
            createCell(row, 0, user.getUserId(), dataStyle, workbook);
            createCell(row, 1, user.getUsername(), dataStyle, workbook);
            createCell(row, 2, user.getEmail(), dataStyle, workbook);
            createCell(row, 3, user.getRole(), dataStyle, workbook);
        }

        autoSizeColumnsByHeaderCount(sheet);

        prepareResponse(response, "users.xlsx");
        ServletOutputStream outputStream = response.getOutputStream();
        workbook.write(outputStream);
        workbook.close();
        outputStream.close();
    }
}