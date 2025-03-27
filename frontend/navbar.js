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
      `;
                } else {
                    nav.innerHTML = '<a href="login.html">Login</a> <a href="register.html">Register</a>';
                }
            });

    });
