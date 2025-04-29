fetch('navbar.html')
    .then(res => res.text())
    .then(html => {
        const navbarContainer = document.createElement('div');
        navbarContainer.innerHTML = html;
        document.body.prepend(navbarContainer);

        // Fade-in effect
        navbarContainer.style.opacity = '0';
        navbarContainer.style.transition = 'opacity 0.4s ease';
        requestAnimationFrame(() => navbarContainer.style.opacity = '1');

        // Highlight current link
        const currentPath = window.location.pathname.split('/').pop();
        const navLinks = navbarContainer.querySelectorAll('.nav-link');
        navLinks.forEach(link => {
            if (link.getAttribute('href') === currentPath) {
                link.classList.add('active-link');
            }
        });

        // Load session and build profile UI
        fetch('/auth/session')
            .then(res => res.json())
            .then(user => {
                const nav = document.getElementById('nav-right');
                if (user && user.username) {
                    const isAdmin = user.role === 'admin';

                    nav.innerHTML = `
                        <div class="nav-user-area">
                            <div id="notification-bell" title="Notifications">
                                <a href="notifications.html">
                                    <img src="assets/bell-icon.png" alt="!" width="22" height="22" />
                                    <span id="notification-count" class="notification-badge">0</span>
                                </a>
                            </div>

                            <div class="profile-menu" id="profile-menu">
                                <div class="profile-trigger" id="profile-trigger">
                                    <div class="avatar-small">${user.username.slice(0, 2).toUpperCase()}</div>
                                    <span>${user.username} ▾</span>
                                </div>
                                <div class="profile-dropdown" id="profile-dropdown">
                                    <a href="home.html">Profile</a>
                                    ${isAdmin ? '<a href="admin.html">Admin</a>' : ''}
                                    <a href="/auth/logout">Logout</a>
                                </div>
                            </div>
                        </div>
                    `;

                    setupDropdownToggle();
                    fetchNotificationCount();
                } else {
                    nav.innerHTML = `
                        <a href="login.html" class="nav-link">Login</a>
                        <a href="register.html" class="nav-link">Register</a>
                    `;
                }
            });
    });

function fetchNotificationCount() {
    fetch('/barter/notifications/unread-count')
        .then(res => res.json())
        .then(data => {
            const badge = document.getElementById('notification-count');
            const count = data.unread || 0;
            if (badge) {
                badge.textContent = count;
                badge.style.display = count > 0 ? 'inline-block' : 'none';
            }
        })
        .catch(() => console.error('Failed to fetch notification count.'));
}

function setupDropdownToggle() {
    const trigger = document.getElementById('profile-trigger');
    const dropdown = document.getElementById('profile-dropdown');

    if (trigger && dropdown) {
        trigger.addEventListener('click', (e) => {
            e.stopPropagation();
            dropdown.classList.toggle('show');
        });

        // Close dropdown on outside click
        document.addEventListener('click', (e) => {
            if (!trigger.contains(e.target) && !dropdown.contains(e.target)) {
                dropdown.classList.remove('show');
            }
        });
    }
}
