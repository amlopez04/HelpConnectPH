# ParañaqueConnect

A modern community reporting system for Parañaque City barangays built with Rails 8 that enables residents to report issues, barangay officials to track progress, and admins to manage the entire system. ParañaqueConnect provides a clean and intuitive interface for community engagement and efficient issue resolution.

## Screenshots

### Landing Page

![Landing Page](Paranaque%20Connect%20Landing%20Page.png)

### Resident Dashboard

![Resident Dashboard](Paranaque%20Connect%20Resident%20Dashboard.png)

### Resident Reports

![Resident Reports](Paranaque%20Connect%20Resident%20Reports.png)

### New Report

![New Report](Paranaque%20Connect%20New%20Report.png)

### Barangay Dashboard

![Barangay Dashboard](Paranaque%20Connect%20Barangay%20Dashboard.png)

### Barangay Reports

![Barangay Reports](Paranaque%20Connect%20Barangay%20Reports.png)

### Admin Dashboard

![Admin Dashboard](Paranaque%20Connect%20Admin%20Dashboard.png)

### Admin Reports

![Admin Reports](Paranaque%20Connect%20Admin%20Reports.png)

### Admin Barangays

![Admin Barangays](Paranaque%20Connect%20Admin%20Barangays.png)

### Admin Categories

![Admin Categories](Paranaque%20Connect%20Admin%20Categories.png)

### User Management

![User Management](Paranaque%20Connect%20User%20Management.png)

### Edit Profile

![Edit Profile](Paranaque%20Connect%20Edit%20Profile.png)

## Features

* **User Authentication & Authorization**  
   * Secure user registration and login with Devise  
   * Protected routes with authentication guards  
   * Role-based access control (Resident, Barangay Official, Admin)  
   * Session management with token-based authentication

* **Report Management**  
   * Submit community reports with photos and location  
   * Interactive Google Maps location picker  
   * Categorize reports by issue type  
   * Track report status (Pending, Approved, In Progress, Resolved, Closed)  
   * Request to reopen closed or resolved reports

* **Barangay Management**  
   * Auto-fill barangay during signup and reporting  
   * Filter reports by barangay location  
   * Manage barangay information and officials

* **Real-time Notifications**  
   * Email notifications for report status updates  
   * Barangay officials receive notifications for new reports  
   * Admins receive daily summary emails

* **Dashboard & Analytics**  
   * View reports by category on dashboard  
   * Track report progress and statistics  
   * Full access to all reports across all barangays (Admin)

* **User Management**  
   * Manage users and assign barangay captains (Admin)  
   * View all team members and user profiles  
   * User activity tracking

* **Protected Routes**  
   * Secure navigation with route guards  
   * Automatic redirect to login for unauthenticated users  
   * Seamless authentication flow

* **Modern UI/UX**  
   * TailwindCSS for responsive design  
   * Material-UI inspired components  
   * Responsive layout for all screen sizes  
   * Intuitive navigation and user experience  
   * Clean and modern interface

## Tech Stack

* **Framework**: Rails 8.0.3
* **Database**: PostgreSQL
* **Authentication**: Devise
* **Authorization**: Pundit
* **Maps**: Google Maps API
* **Email**: Resend
* **Styling**: TailwindCSS
* **File Storage**: Active Storage
* **Image Processing**: Image Processing gem
* **Geocoding**: Geocoder gem
* **Pagination**: Kaminari
* **Audit Trail**: Paper Trail
* **Background Jobs**: Solid Queue
* **Caching**: Solid Cache
* **Web Server**: Puma
* **JavaScript**: Stimulus, Turbo Rails

## Installation

1. **Clone the repository**  
   ```bash
   git clone https://github.com/amlopez04/paranaqueconnect.git
   cd paranaqueconnect
   ```

2. **Install dependencies**  
   ```bash
   bundle install
   npm install
   ```

3. **Set up environment variables**  
   Create a `.env` file in the root directory:
   ```bash
   # Database
   DATABASE_URL=postgresql://localhost/paranaqueconnect_development
   
   # Email (Resend)
   RESEND_API_KEY=your_resend_api_key
   MAILER_HOST=localhost:3000
   
   # Google Maps
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   
   # Rails
   SECRET_KEY_BASE=your_secret_key_base
   RAILS_MASTER_KEY=your_master_key
   ```

4. **Set up the database**  
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

5. **Start the development server**  
   ```bash
   bin/dev
   ```

6. **Visit the application**  
   Open your browser and navigate to `http://localhost:3000`

## Configuration

### API Configuration

The application uses Google Maps API for location features. Configure the API key via environment variables:

* `GOOGLE_MAPS_API_KEY` - Google Maps JavaScript API and Geocoding API key

### Email Configuration

ParañaqueConnect uses **Resend** for transactional emails:

1. **Create Resend account** at [resend.com](https://resend.com)
2. **Get API key** from Resend dashboard
3. **Add to environment variables:**
   ```bash
   RESEND_API_KEY=your_api_key_here
   MAILER_HOST=your-domain.com
   ```
4. **Domain verification** (optional) for custom domain

### Google Maps Setup

1. **Get API Key** from [Google Cloud Console](https://console.cloud.google.com)
2. **Enable Maps JavaScript API** and **Geocoding API**
3. **Add API key** to environment variables:
   ```bash
   GOOGLE_MAPS_API_KEY=your_api_key_here
   ```
4. **Enable billing** in Google Cloud Console

### Authentication

The app uses Devise for authentication with the following features:

* Email confirmation
* Password reset
* Session management
* Role-based authorization with Pundit

## Usage

### For Residents

1. **Sign Up / Login**  
   * Navigate to `/users/sign_up` to create an account  
   * Or `/users/sign_in` to login  
   * Access the dashboard upon successful authentication

2. **Submit Reports**  
   * Go to `/reports/new` to create a new report  
   * Add photos, description, and select location on map  
   * Choose appropriate category  
   * Submit and track your report status

3. **View Reports**  
   * Go to `/reports` to view all your submitted reports  
   * Filter by status or category  
   * View report details and comments

4. **Dashboard**  
   * Check the home dashboard to see report statistics  
   * View reports by category  
   * Track pending and resolved issues

5. **Request Reopen**  
   * For closed or resolved reports, request to reopen  
   * Add comments explaining why reopening is needed

### For Barangay Officials

1. **Approve Reports**  
   * View pending reports in your barangay  
   * Approve or reject reports  
   * Update report status and priority

2. **Manage Reports**  
   * Update report status (In Progress, Resolved, Closed)  
   * Add comments to communicate with residents  
   * Track all reports in your barangay

3. **Dashboard**  
   * View barangay-specific statistics  
   * Monitor report progress  
   * Receive email notifications for new reports

### For Admins

1. **User Management**  
   * Navigate to `/admin/users` to manage all users  
   * Assign barangay captains  
   * View user profiles and activity

2. **Report Management**  
   * Full access to all reports across all barangays  
   * Filter reports by barangay location  
   * Approve reopen requests from residents

3. **Barangay Management**  
   * Manage barangay information  
   * View and edit barangay details

4. **Category Management**  
   * Create and manage report categories  
   * Organize issue types

5. **Dashboard**  
   * View system-wide statistics  
   * Monitor all activities  
   * Receive daily admin summaries

## Testing

Run the test suite with RSpec:

```bash
bundle exec rspec
```

For specific test files:

```bash
bundle exec rspec spec/models/user_spec.rb
```

The application includes:

* Model tests for all models
* Factory definitions for test data
* Geocoder stubs for location testing

## Project Structure

```
paranaqueconnect/
├── app/
│   ├── assets/
│   │   ├── images/
│   │   ├── stylesheets/
│   │   └── tailwind/
│   ├── controllers/
│   │   ├── admin/
│   │   ├── users/
│   │   └── concerns/
│   ├── helpers/
│   ├── javascript/
│   │   └── controllers/
│   ├── jobs/
│   ├── mailers/
│   ├── models/
│   │   └── concerns/
│   ├── policies/
│   │   └── admin/
│   └── views/
│       ├── admin/
│       ├── dashboards/
│       ├── devise/
│       ├── home/
│       ├── layouts/
│       ├── reports/
│       └── shared/
├── config/
│   ├── environments/
│   ├── initializers/
│   └── locales/
├── db/
│   ├── migrate/
│   └── seeds.rb
├── docs/
│   ├── COOLIFY_DEPLOYMENT.md
│   ├── DEMO_SCRIPT.md
│   ├── DEVELOPMENT_STEPS.md
│   └── ...
├── spec/
│   ├── factories/
│   ├── models/
│   └── support/
├── Dockerfile
├── Gemfile
├── Procfile
└── README.md
```

## Deployment

This application can be deployed using Docker and Coolify, or Render. See the deployment configuration files:

* `Dockerfile` - Multi-stage Docker build configuration
* `Procfile` - Process configuration for deployment
* `.dockerignore` - Files excluded from Docker build

### Quick Deploy to Coolify

1. Push your code to GitHub repository `paranaqueconnect`
2. In Coolify dashboard, create a new resource
3. Connect your `paranaqueconnect` repository
4. Select "Dockerfile" as build pack
5. Set port to `80`
6. Add environment variables (see Configuration section)
7. Deploy!

### Deploy to Render

1. **Create a Render Account** at [render.com](https://render.com)
2. **Create New Web Service**
   * Connect your GitHub repository
   * Choose your `paranaqueconnect` repo
3. **Configure Service**
   * **Name:** `paranaqueconnect`
   * **Build Command:** `bundle install && rails assets:precompile && rails db:migrate`
   * **Start Command:** `rails server -p $PORT`
4. **Add Environment Variables** (see Configuration section)
5. **Deploy and Test**

### Custom Domain Setup

1. Add custom domain in Coolify/Render dashboard
2. Update DNS records to point to your deployment
3. Update `MAILER_HOST` environment variable
4. SSL certificate provided automatically

## Available Scripts

### `bin/dev`

Runs the app in development mode with all processes (Rails server, Tailwind CSS watcher)

### `rails server`

Starts the Rails development server at `http://localhost:3000`

### `rails console`

Opens the Rails console for interactive Ruby commands

### `rails db:migrate`

Runs database migrations

### `rails db:seed`

Seeds the database with initial data

### `bundle exec rspec`

Runs the test suite

## Default Test Accounts

After running `rails db:seed`:

**Admin:**
* Email: `alea.mikaela04@gmail.com`
* Password: `password123`

**Resident:**
* Email: `ammlopez04@gmail.com`
* Password: `password123`

**Barangay Official:**
* Email: `amlopez14@up.edu.ph`
* Password: `password123`

## Environment Variables

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

## Troubleshooting

### Build Failures
* Verify `Gemfile.lock` is committed
* Check all gems are compatible with Ruby version
* Review build logs for specific errors
* Ensure Dockerfile is properly configured

### Database Issues
* Ensure PostgreSQL service is running
* Check `DATABASE_URL` is set correctly
* Run migrations via shell: `rails db:migrate`
* For Coolify: Check if PostgreSQL addon is properly linked

### Email Issues
* Verify `RESEND_API_KEY` is correct
* Check Resend dashboard for delivery status
* Test with simple email first
* Verify `MAILER_HOST` matches your domain

### Maps Issues
* Verify `GOOGLE_MAPS_API_KEY` is set
* Check API key restrictions in Google Cloud
* Ensure billing is enabled in Google Cloud

### Coolify Specific Issues
* Check Dockerfile builds successfully locally
* Verify `RAILS_MASTER_KEY` is set (required for production)
* Ensure port is properly configured (default 80)
* Check container logs in Coolify dashboard

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## About

A community reporting system project built with Rails 8. This application demonstrates modern Rails development practices including:

* MVC architecture
* RESTful routing
* Role-based authorization with Pundit
* API integration (Google Maps, Resend)
* Active Storage for file uploads
* Background job processing
* Email notifications
* TailwindCSS for modern design

## License

This project is open source and available for educational purposes.

## Resources

* [Rails Documentation](https://guides.rubyonrails.org/)
* [Devise Documentation](https://github.com/heartcombo/devise)
* [Pundit Documentation](https://github.com/varvet/pundit)
* [TailwindCSS Documentation](https://tailwindcss.com/docs)
* [Google Maps API Documentation](https://developers.google.com/maps/documentation)
* [Resend Documentation](https://resend.com/docs)
