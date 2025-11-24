Comprehensive Implementation Plan for the Project-Based Offline-First Mobile App
I. Project Overview
This app is a project-scoped mobile management system built for organizations running multiple projects. Each user can only access, view, and interact with data related to the specific project(s) they are assigned to.
It provides:
•
Secure authentication (with MFA and biometrics).
•
Project-level dashboards, issues, requests, and reports.
•
Media handling (upload, view, download).
•
Offline-first capabilities (read/write offline, auto-sync when online).
•
Role-based access control (actions limited by user’s project and role).
•
Push notifications for workflow events.
Core Tech Stack
•
Frontend: Flutter (Dart)
•
Architecture: Feature-Based Clean Architecture
•
Storage: Drift (SQLite) + Secure Storage + GetStorage
•
Networking: Dio + Interceptors
•
State Management: Bloc or Riverpod
•
Background Jobs: WorkManager + BackgroundFetch
•
Notifications: Firebase Cloud Messaging
•
CI/CD: GitHub Actions or Codemagic
II. Project Modules
The system is divided into 9 modules, all scoped by project_id. Every API call, UI screen, and offline cache will be filtered by the user’s assigned projects.
1. Authentication Module
Purpose
Authenticate users, enforce MFA, manage sessions, and enable biometric login. After login, fetch the list of projects assigned to the user to scope the rest of the app.
Key APIs
•
/api/v1/auth/login
•
/api/v1/auth/mfa/verify
•
/api/v1/auth/refresh
•
/api/v1/auth/logout
•
/api/v1/auth/mfa/setup
•
/api/v1/auth/mfa/enable
•
/api/v1/auth/mfa/disable
•
/api/v1/auth/password-reset/*
UI Components
•
Login screen (email/password).
•
MFA verification screen.
•
Project selection screen (if user has multiple projects).
•
Biometric setup & login screen.
•
Logout dialog.
Implementation Steps
1.
Setup Dio client and GetIt service locator.
2.
Implement AuthRepository with login and MFA endpoints.
3.
On login, cache user tokens securely using flutter_secure_storage.
4.
Fetch assigned projects and store them locally (user_projects table).
5.
Implement token refresh and auto logout when expired.
6.
Enable offline login using cached tokens or biometric authentication.
2. Project Management Module
Purpose
Serve as the home base for all user operations. The app’s state (and all features) will be scoped by the active project.
Key APIs
•
/api/v1/projects
•
/api/v1/projects/{id}
•
/api/v1/projects/{id}/approval-workflows
•
/api/v1/projects/{id}/media/gallery
UI Components
•
Project List Screen (all assigned projects).
•
Project Overview (dashboard metrics, recent reports/issues).
•
Project Details page (status, dates, team, etc.).
Implementation Steps
1.
Create ProjectRepository and DAO (local DB caching).
2.
On project selection, update global state (active project context).
3.
Filter all subsequent API calls by active project_id.
4.
Cache project metadata and workflows for offline access.
5.
Integrate analytics widgets (reports summary, requests count, etc.).
3. Reports Module
Purpose
Allow users to create, edit, and view reports under their current project. Reports can include media attachments and are synced offline.
Key APIs
•
/api/v1/projects/{id}/reports
•
/api/v1/reports/{id}
•
/api/v1/reports/search
•
/api/v1/reports/{id}/media
•
/api/v1/reports/{id}/comments (if supported)
UI Components
•
Reports List Screen (filter by date/status).
•
Report Form (new/edit).
•
Report Details Screen.
•
Media Attachment Modal.
•
Sync Status Indicator.
Implementation Steps
1.
Create local DB tables for reports, report_media, pending_reports.
2.
Implement CRUD UI tied to Drift database first (not directly API).
3.
Queue unsynced reports in sync_queue.
4.
When online, background worker uploads new/edited reports.
5.
Integrate conflict resolution view for any mismatches.
6.
Allow search using cached data or API fallback.
4. Issues Module
Purpose
Manage project-related issues, including creation, assignment, comments, and media uploads.
Key APIs
•
/api/v1/projects/{id}/issues
•
/api/v1/issues/{id}
•
/api/v1/issues/{id}/assign
•
/api/v1/issues/{id}/status
•
/api/v1/issues/{id}/comments
•
/api/v1/issues/{id}/media
UI Components
•
Issue List (filters: status, priority).
•
Issue Details View (with comments, activity log).
•
Issue Form (new/edit).
•
Attach Media & Comment Panels.
Implementation Steps
1.
Build IssueRepository (API + DB).
2.
Cache issues by project_id.
3.
Support offline creation with status “pending_sync”.
4.
Allow adding comments offline; sync when connected.
5.
Implement issue assignment with proper role validation.
6.
Add local notifications for newly assigned issues.
5. Requests Module
Purpose
Allow users to create and manage approval requests tied to a project (funds, materials, etc.).
Key APIs
•
/api/v1/projects/{id}/requests
•
/api/v1/projects/{id}/requests/analytics
•
/api/v1/requests/{id}
•
/api/v1/requests/{id}/approve
•
/api/v1/requests/{id}/reject
•
/api/v1/requests/pending
UI Components
•
Request List Screen.
•
Request Form Screen (Create/Edit).
•
Request Detail Screen.
•
Approve/Reject Popup.
•
Analytics View (from /analytics endpoint).
Implementation Steps
1.
Implement local caching for all requests and analytics.
2.
Allow request creation and offline submission.
3.
Queue new/updated requests for sync.
4.
Auto-update status when approval comes from API.
5.
Add role-based permission checks for approving/rejecting.
6. Media Module
Purpose
Manage all file uploads and downloads across the app, centralized for reuse.
Key APIs
•
/api/v1/media
•
/api/v1/media/upload
•
/api/v1/media/{id}
•
/api/v1/media/{id}/download
•
/api/v1/projects/{id}/media/gallery
UI Components
•
Media Picker (camera/gallery).
•
Media Upload Screen (progress bar).
•
Gallery View (per project).
•
File Preview Modal.
Implementation Steps
1.
Centralize file handling utilities.
2.
Compress and save files locally before upload.
3.
Handle queued media uploads via background tasks.
4.
Associate media with reports/issues using local IDs.
5.
Retry failed uploads automatically.
7. Notifications Module
Purpose
Deliver real-time and offline notifications for issues, reports, and approvals.
Key APIs
•
/api/v1/notifications
•
/api/v1/notifications/{id}/read
UI Components
•
Notifications List Screen.
•
Notification Detail View.
•
Push Notification Listener Service.
Implementation Steps
1.
Setup Firebase Messaging for push alerts.
2.
Cache notifications locally.
3.
Mark notifications as read locally and sync later.
4.
Integrate in-app banners for important updates.
8. Sync & Conflict Resolution Engine
Purpose
Manage background data synchronization and handle merge conflicts.
Key APIs
•
/api/v1/sync/batch
•
/api/v1/sync/download
•
/api/v1/sync/conflicts
•
/api/v1/sync/conflicts/{id}/resolve
UI Components
•
Sync Progress Indicator (header/footer).
•
Conflict Resolution Screen.
•
Offline/Online status bar.
Implementation Steps
1.
Create sync_queue table in Drift.
2.
Add SyncManager service to handle background jobs.
3.
Run periodic sync every 15 minutes or when connectivity resumes.
4.
Detect and display conflicts to the user for manual resolution.
5.
Log sync history in local DB for diagnostics.
9. Dashboard & Analytics Module
Purpose
Provide overview insights for the active project.
Key APIs
•
/api/v1/projects/{id}/requests/analytics
•
/api/v1/reports/search
•
/api/v1/issues/{id}/history
UI Components
•
Project Dashboard Screen.
•
Charts for Reports/Requests/Issues.
•
Sync Status Widget.
•
Recent Activity Timeline.
Implementation Steps
1.
Integrate analytics widgets for quick project insights.
2.
Cache analytics for offline mode.
3.
Refresh periodically during sync cycles.
4.
Allow drill-down navigation from analytics cards.
III. Implementation Timeline
Phase
Duration
Key Deliverables
Phase 1
Week 1–2
Project setup, environment config, folder structure, dependency setup.
Phase 2
Week 3–4
Authentication + Project selection module.
Phase 3
Week 5–6
Reports, Issues, and Requests modules (offline storage integrated).
Phase 4
Week 7–8
Media module, Sync engine, background jobs.
Phase 5
Week 9
Dashboard, Analytics, Notifications.
Phase 6
Week 10
Testing, bug fixes, performance optimization, CI/CD setup.
IV. Offline Data Flow
User Action → Local Database (cache/pending) → Sync Queue
→ Background Sync (when online) → Server → Local DB updated
→ Conflict Resolution (if needed) → UI refreshed
V. Maintenance & Scalability
•
Feature Modularity: Each module is self-contained.
•
Project Scoping: Every API and local DB operation filtered by active project.
•
Offline Cache Lifespan: Configurable retention per table (e.g., 30 days).
•
Sync Resilience: Retry exponential backoff for failed uploads.
•
Extensibility: Can easily add Inventory, Assets, or Time Tracking modules.