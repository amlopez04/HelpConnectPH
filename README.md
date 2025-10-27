# ParañaqueConnect

A community reporting system for Parañaque City barangays built with Rails 8 and PostgreSQL. Residents can report issues, barangay officials can track progress, and admins can manage the entire system.

## 🚀 Quick Start

### Prerequisites
- Ruby 3.x
- PostgreSQL
- Node.js (for asset pipeline)
- Git

### Installation

```bash
# Clone the repository
git clone https://github.com/yourusername/help_connect_ph.git
cd help_connect_ph

# Install dependencies
bundle install
npm install

# Setup database
rails db:create
rails db:migrate
rails db:seed

# Start the server
bin/dev
```

Visit `http://localhost:3000`

## 📋 Features

### For Residents
- 📝 Submit community reports with photos and location
- 📍 Interactive Google Maps location picker
- 🔔 Email notifications for report status updates
- 📊 View reports by category on dashboard
- 🔄 Request to reopen closed or resolved reports
- 🏘️ Auto-fill barangay during signup and reporting

### For Barangay Officials
- ✅ Approve or reject pending reports
- 🏃 Update report status and priority
- 💬 Add comments to reports
- 📧 Receive email notifications for new reports

### For Admins
- 👥 Manage users and assign barangay captains
- 📊 Full access to all reports across all barangays
- 📍 Filter reports by barangay location
- 🏷️ Manage categories
- 📧 Receive daily admin summaries
- ✅ Approve reopen requests from residents

## 🛠️ Tech Stack

- **Framework:** Rails 8.0
- **Database:** PostgreSQL
- **Authentication:** Devise
- **Authorization:** Pundit
- **Maps:** Google Maps API
- **Email:** Resend
- **Styling:** TailwindCSS
- **File Storage:** Active Storage
- **Image Processing:** Image Processing gem
- **Geocoding:** Geocoder gem

## 🌐 Deployment

### Coolify Deployment

**Coolify** is a self-hosted platform-as-a-service that uses Docker containers for deployment.

1. **Install Coolify** (if self-hosting)
   - Follow [Coolify documentation](https://coolify.io/docs)
   - Or use Coolify Cloud at [coolify.io](https://coolify.io)

2. **Create New Project**
   - Click "New Project" in Coolify dashboard
   - Connect your Git repository (GitHub/GitLab)
   - Select your parañaqueconnect repository

3. **Configure Application**
   - **Service Type:** Web Application
   - **Build Pack:** Docker
   - **Dockerfile:** Auto-detected (uses existing `Dockerfile`)
   - **Port:** 80 (or 3000 if using Puma directly)

4. **Add Environment Variables**
   ```bash
   # Required
   RAILS_ENV=production
   RAILS_MASTER_KEY=<value from config/master.key>
   SECRET_KEY_BASE=<generate with 'rails secret'>
   
   # Email (Resend)
   RESEND_API_KEY=<your-resend-api-key>
   MAILER_HOST=<your-domain.com>
   
   # Google Maps
   GOOGLE_MAPS_API_KEY=<your-google-maps-key>
   
   # Database
   DATABASE_URL=postgresql://user:password@host:5432/dbname
   
   # Optional
   PORT=3000
   ```

5. **Database Setup**
   - Add PostgreSQL service in Coolify
   - Or use external PostgreSQL database
   - Set `DATABASE_URL` environment variable
   - Run migrations on first deploy

6. **Deploy and Test**
   - Click "Deploy"
   - Wait for build to complete (5-10 mins)
   - Run migrations via Coolify shell: `rails db:migrate`
   - Run seeds if needed: `rails db:seed`
   - Visit your app at your configured domain

### Alternative: Render Deployment

1. **Create a Render Account** at [render.com](https://render.com)

2. **Create New Web Service**
   - Connect your GitHub repository
   - Choose your parañaqueconnect repo

3. **Configure Service**
   - **Name:** `paranaqueconnect`
   - **Build Command:** `bundle install && rails assets:precompile && rails db:migrate`
   - **Start Command:** `rails server -p $PORT`

4. **Add Environment Variables**
   ```bash
   RAILS_ENV=production
   SECRET_KEY_BASE=<generate with 'rails secret'>
   RESEND_API_KEY=<your-resend-api-key>
   GOOGLE_MAPS_API_KEY=<your-google-maps-key>
   MAILER_HOST=<your-app-name.onrender.com>
   ```

5. **Deploy and Test**
   - Click "Create Web Service"
   - Wait for deployment (5-10 mins)
   - Visit your app at `https://your-app-name.onrender.com`

### Custom Domain Setup

1. Add custom domain in Coolify/Render dashboard
2. Update DNS records to point to your deployment
3. Update `MAILER_HOST` environment variable
4. SSL certificate provided automatically

## 📧 Email Configuration

ParañaqueConnect uses **Resend** for transactional emails. Setup steps:

1. **Create Resend account** at [resend.com](https://resend.com)
2. **Get API key** from Resend dashboard
3. **Add to environment variables:**
   ```bash
   RESEND_API_KEY=your_api_key_here
   MAILER_HOST=your-domain.com
   ```
4. **Domain verification** (optional) for custom domain

## 🗺️ Google Maps Setup

1. **Get API Key** from [Google Cloud Console](https://console.cloud.google.com)
2. **Enable Maps JavaScript API** and **Geocoding API**
3. **Add API key** to environment variables:
   ```bash
   GOOGLE_MAPS_API_KEY=your_api_key_here
   ```
4. **Enable billing** in Google Cloud Console

## 👥 Default Test Accounts

After running `rails db:seed`:

**Admin:**
- Email: `alea.mikaela04@gmail.com`
- Password: `password123`

**Resident:**
- Email: `ammlopez04@gmail.com`
- Password: `password123`

**Barangay Official:**
- Email: `amlopez14@up.edu.ph`
- Password: `password123`

## 🔧 Environment Variables

Required environment variables:

```bash
# Database (auto-set by Coolify/Render/Heroku)
DATABASE_URL=postgresql://user:password@host:5432/dbname

# Rails
RAILS_ENV=production
RAILS_MASTER_KEY=<value from config/master.key>
SECRET_KEY_BASE=<generated with 'rails secret'>

# Email (Resend)
RESEND_API_KEY=<your-resend-key>
MAILER_HOST=<your-domain.com>

# Google Maps
GOOGLE_MAPS_API_KEY=<your-google-maps-key>
```

## 🐛 Troubleshooting

### Build Failures
- Verify `Gemfile.lock` is committed
- Check all gems are compatible with Ruby version
- Review build logs for specific errors
- Ensure Dockerfile is properly configured

### Database Issues
- Ensure PostgreSQL service is running
- Check `DATABASE_URL` is set correctly
- Run migrations via shell: `rails db:migrate`
- For Coolify: Check if PostgreSQL addon is properly linked

### Email Issues
- Verify `RESEND_API_KEY` is correct
- Check Resend dashboard for delivery status
- Test with simple email first
- Verify `MAILER_HOST` matches your domain

### Maps Issues
- Verify `GOOGLE_MAPS_API_KEY` is set
- Check API key restrictions in Google Cloud
- Ensure billing is enabled in Google Cloud

### Coolify Specific Issues
- Check Dockerfile builds successfully locally
- Verify `RAILS_MASTER_KEY` is set (required for production)
- Ensure port is properly configured (default 80)
- Check container logs in Coolify dashboard

## 📊 Monitoring

- **Coolify Dashboard:** View logs, resource usage, deployment history, container logs
- **Render Dashboard:** View logs, resource usage, deployment history
- **Resend Dashboard:** Monitor email delivery, bounce rates, statistics
- **Application Logs:** Check Rails console output for errors
- Access Rails console via Coolify shell feature

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is part of a university course project.

## 👨‍💻 Author

Built as part of a Software Engineering course project.

---

**Last Updated:** November 2025  
**Status:** ✅ Production Ready