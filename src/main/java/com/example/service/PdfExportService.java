package com.example.service;

import java.io.IOException;
import java.util.List;
import java.time.LocalDate; // Make sure this is imported
import java.time.format.DateTimeFormatter; // Make sure this is imported

import org.springframework.stereotype.Service;

import com.example.entity.Department;
import com.example.entity.Designation;
import com.example.entity.Employee;
import com.example.entity.User;
import com.itextpdf.text.BaseColor;
import com.itextpdf.text.Chunk;
import com.itextpdf.text.Document;
import com.itextpdf.text.DocumentException;
import com.itextpdf.text.Font;
import com.itextpdf.text.FontFactory;
import com.itextpdf.text.PageSize;
import com.itextpdf.text.Paragraph;
import com.itextpdf.text.Phrase;
import com.itextpdf.text.pdf.PdfPCell;
import com.itextpdf.text.pdf.PdfPTable;
import com.itextpdf.text.pdf.PdfWriter;

import jakarta.servlet.http.HttpServletResponse;

@Service
public class PdfExportService {

    // --- Configuration Constants ---
    private static final int DEFAULT_PDF_FONT_SIZE = 9; // Default font size for data cells
    private static final int SMALL_PDF_FONT_SIZE = 7; // Smaller font size for long text
    private static final int MAX_CHARS_BEFORE_REDUCING_FONT = 20; // Threshold for text length

    /**
     * Prepares the HttpServletResponse for PDF download.
     * @param response The HttpServletResponse object.
     * @param filename The desired filename for the downloaded PDF.
     * @param contentType The content type (e.g., "application/pdf").
     */
    private void prepareResponse(HttpServletResponse response, String filename, String contentType) {
        response.setContentType(contentType);
        String headerKey = "Content-Disposition";
        String headerValue = "attachment; filename=" + filename;
        response.setHeader(headerKey, headerValue);
    }

    /**
     * Adds header cells to the PDF table with consistent styling.
     * @param table The PdfPTable to add headers to.
     * @param headers An array of header strings.
     */
    private void addTableHeader(PdfPTable table, String[] headers) {
        Font headerFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, DEFAULT_PDF_FONT_SIZE + 1, BaseColor.WHITE);
        BaseColor headerBgColor = new BaseColor(64, 64, 64); // Dark grey

        for (String header : headers) {
            PdfPCell headerCell = new PdfPCell();
            headerCell.setPhrase(new Phrase(header, headerFont));
            headerCell.setBackgroundColor(headerBgColor);
            headerCell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER);
            headerCell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE);
            headerCell.setPadding(5);
            table.addCell(headerCell);
        }
    }

    /**
     * Helper method to add a cell to the PDF table with dynamic font sizing and consistent styling.
     * Font size is reduced if the text content exceeds MAX_CHARS_BEFORE_REDUCING_FONT.
     * @param table The PdfPTable to add the cell to.
     * @param text The text content for the cell.
     */
    private void addCellWithDynamicFontSize(PdfPTable table, String text) {
        Font font;
        // Ensure null text is handled to avoid NullPointerException
        String content = (text != null) ? text : ""; 

        if (content.length() > MAX_CHARS_BEFORE_REDUCING_FONT) {
            font = FontFactory.getFont(FontFactory.HELVETICA, SMALL_PDF_FONT_SIZE);
        } else {
            font = FontFactory.getFont(FontFactory.HELVETICA, DEFAULT_PDF_FONT_SIZE);
        }

        PdfPCell cell = new PdfPCell(new Phrase(content, font));
        cell.setHorizontalAlignment(PdfPCell.ALIGN_CENTER); // Center align data
        cell.setVerticalAlignment(PdfPCell.ALIGN_MIDDLE); // Vertically center data
        cell.setPadding(3); // Add padding
        table.addCell(cell);
    }

    // --- Export Methods for Different Entities ---

    public void exportDepartmentsToPdf(List<Department> departments, HttpServletResponse response) throws DocumentException, IOException {
        Document document = new Document(PageSize.A4);
        prepareResponse(response, "departments.pdf", "application/pdf");
        PdfWriter.getInstance(document, response.getOutputStream());

        document.open();
        document.add(new Paragraph("Departments List", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, BaseColor.BLACK)));
        document.add(Chunk.NEWLINE);

        PdfPTable table = new PdfPTable(4); // 4 columns
        table.setWidthPercentage(100);
        table.setSpacingBefore(10f);
        table.setSpacingAfter(10f);
        table.setPaddingTop(5f);

        addTableHeader(table, new String[]{"Department ID", "Name", "Created Date", "Mail"});

        // Consistent DateTimeFormatter for LocalDate fields
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        for (Department dept : departments) {
            addCellWithDynamicFontSize(table, String.valueOf(dept.getDeptId()));
            addCellWithDynamicFontSize(table, dept.getName());
            // Corrected: Use LocalDate.format() method with DateTimeFormatter
            addCellWithDynamicFontSize(table, dept.getCreatedDate() != null ? dept.getCreatedDate().format(dateFormatter) : "");
            
            addCellWithDynamicFontSize(table, dept.getMail());
        }

        document.add(table);
        document.close();
    }

    public void exportDesignationsToPdf(List<Designation> designations, HttpServletResponse response) throws DocumentException, IOException {
        Document document = new Document(PageSize.A4);
        prepareResponse(response, "designations.pdf", "application/pdf");
        PdfWriter.getInstance(document, response.getOutputStream());

        document.open();
        document.add(new Paragraph("Designations List", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, BaseColor.BLACK)));
        document.add(Chunk.NEWLINE);

        PdfPTable table = new PdfPTable(4); // 4 columns
        table.setWidthPercentage(100);
        table.setSpacingBefore(10f);
        table.setSpacingAfter(10f);
        table.setPaddingTop(5f);

        addTableHeader(table, new String[]{"Designation ID", "Title", "Created Date", "Mail"});

        // Consistent DateTimeFormatter for LocalDate fields
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        for (Designation desig : designations) {
            addCellWithDynamicFontSize(table, String.valueOf(desig.getDesigId()));
            addCellWithDynamicFontSize(table, desig.getTitle());
            // Corrected: Use LocalDate.format() method with DateTimeFormatter
            addCellWithDynamicFontSize(table, desig.getCreatedDate() != null ? desig.getCreatedDate().format(dateFormatter) : "");
            addCellWithDynamicFontSize(table, desig.getDmail());
        }

        document.add(table);
        document.close();
    }

    public void exportEmployeesToPdf(List<Employee> employees, HttpServletResponse response) throws DocumentException, IOException {
        Document document = new Document(PageSize.A4.rotate()); // Landscape for more columns
        prepareResponse(response, "employees.pdf", "application/pdf");
        PdfWriter.getInstance(document, response.getOutputStream());

        document.open();
        document.add(new Paragraph("Employees List", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, BaseColor.BLACK)));
        document.add(Chunk.NEWLINE);

        PdfPTable table = new PdfPTable(11); // 11 columns
        table.setWidthPercentage(100);
        table.setSpacingBefore(10f);
        table.setSpacingAfter(10f);
        table.setPaddingTop(5f);
        try {
            // Adjusted widths to prevent Phone number wrapping
            table.setWidths(new float[]{
                1.0f,   // Emp ID
                2.0f,   // Name
                2.8f,   // Email
                2.2f,   // Phone - Increased width
                2.2f,   // Hire Date
                1.8f,   // First Name - Slightly reduced
                1.8f,   // Last Name - Slightly reduced
                1.3f,   // Salary - Slightly reduced
                2.0f,   // Dept
                2.0f,   // Desig
                2.4f    // Acc Num - Slightly reduced
            });
        } catch (DocumentException e) {
            System.err.println("Error setting table widths for Employees PDF: " + e.getMessage());
            e.printStackTrace();
        }

        addTableHeader(table, new String[]{"Emp ID", "Name", "Email", "Phone", "Hire Date", "First Name", "Last Name", "Salary", "Dept", "Desig", "Acc Num"});

        // Consistent DateTimeFormatter for LocalDate (assuming Hiredate is LocalDate)
        DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");

        for (Employee emp : employees) {
            addCellWithDynamicFontSize(table, String.valueOf(emp.getEmpId()));
            addCellWithDynamicFontSize(table, emp.getName());
            addCellWithDynamicFontSize(table, emp.getEmail());
            addCellWithDynamicFontSize(table, String.valueOf(emp.getPhone()));
            // Correctly format LocalDate to String, handling potential null
            addCellWithDynamicFontSize(table, emp.getHiredate() != null ? emp.getHiredate().format(dateFormatter) : "");
            addCellWithDynamicFontSize(table, String.valueOf(emp.getFirstName()));
            addCellWithDynamicFontSize(table, String.valueOf(emp.getLastName()));
            addCellWithDynamicFontSize(table, String.valueOf(emp.getSalary()));
            addCellWithDynamicFontSize(table, emp.getDept() != null ? emp.getDept().getName() : "N/A");
            addCellWithDynamicFontSize(table, emp.getDesig() != null ? emp.getDesig().getTitle() : "N/A");
            addCellWithDynamicFontSize(table, String.valueOf(emp.getAccountNumber()));
        }

        document.add(table);
        document.close();
    }

    public void exportUsersToPdf(List<User> users, HttpServletResponse response) throws DocumentException, IOException {
        Document document = new Document(PageSize.A4);
        prepareResponse(response, "users.pdf", "application/pdf");
        PdfWriter.getInstance(document, response.getOutputStream());

        document.open();
        document.add(new Paragraph("Users List", FontFactory.getFont(FontFactory.HELVETICA_BOLD, 18, BaseColor.BLACK)));
        document.add(Chunk.NEWLINE);

        PdfPTable table = new PdfPTable(4);
        table.setWidthPercentage(100);
        table.setSpacingBefore(10f);
        table.setSpacingAfter(10f);
        table.setPaddingTop(5f);

        addTableHeader(table, new String[]{"User ID", "Username", "Email", "Role"});

        for (User user : users) {
            addCellWithDynamicFontSize(table, String.valueOf(user.getUserId()));
            addCellWithDynamicFontSize(table, user.getUsername());
            addCellWithDynamicFontSize(table, user.getEmail());
            addCellWithDynamicFontSize(table, user.getRole());
        }

        document.add(table);
        document.close();
    }
}