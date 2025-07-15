
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

    function openArchivePopup() {
        var archiveModal = new bootstrap.Modal(document.getElementById('archiveModal'));
        archiveModal.show();
    }

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
