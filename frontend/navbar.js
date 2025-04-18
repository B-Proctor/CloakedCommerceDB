// navbar.js
fetch('navbar.html')
    .then(res => res.text())
    .then(html => {
        const navbarContainer = document.createElement('div');
        navbarContainer.innerHTML = html;
        document.body.prepend(navbarContainer);

        // Load user session and update the nav-right
        fetch('/auth/session')
            .then(res => res.json())
            .then(user => {
                const nav = document.getElementById('nav-right');
                if (user && user.username) {
                    const isAdmin = user.role === 'admin';

                    nav.innerHTML = `
                        <div class="profile-menu">
                            <span>Hello, ${user.username} ▾</span>
                            <div class="profile-dropdown">
                                <a href="home.html">Profile</a>
                                ${isAdmin ? '<a href="admin.html">Admin</a>' : ''}
                                <a href="/auth/logout">Logout</a>
                            </div>
                        </div>
                        <div id="notification-bell" style="position: relative; margin-left: 10px;">
                            <a href="notifications.html" title="Notifications">
                                <img src="assets/bell-icon.png" alt="!" width="24" height="24">
                                <span id="notification-count" class="notification-badge" style="display: none;">0</span>
                            </a>
                        </div>
                    `;

                    fetchNotificationCount(); // 🔔 Count unread notifs
                } else {
                    nav.innerHTML = '<a href="login.html">Login</a> <a href="register.html">Register</a>';
                }
            });
    });

// Fetch notification count for bell
function fetchNotificationCount() {
    fetch('/barter/notifications/unread-count')
        .then(res => res.json())
        .then(data => {
            const count = data.unread || 0;
            const badge = document.getElementById('notification-count');
            if (badge) {
                badge.style.display = count > 0 ? 'inline-block' : 'none';
                badge.textContent = count;
            }
        })
        .catch(() => {
            console.error("Failed to fetch notification count.");
        });
}
