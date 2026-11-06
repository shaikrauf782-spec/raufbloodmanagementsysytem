# 🩸 Rauf Blood Management System

> **Tagline:** Every Drop Counts. Every Donor Matters.  
> **Platform:** Certified Full-Stack Blood Bank & Transfusion Management System  
> **Target Database:** MySQL Server 8.0 (InnoDB)  
> **Backend:** Node.js + Express.js + REST APIs + `mysql2/promise`  
> **Frontend:** React 19 + Tailwind CSS + Lucide Icons + Chart.js  

---

## 🌟 Overview & Key Features

Rauf Blood Management System is a complete, enterprise-grade healthcare platform designed for blood transfusion banks, emergency trauma centers, and voluntary donor networks.

### 1. Real-time Inventory Management (All 8 Blood Groups)
- Tracks **A+, A-, B+, B-, AB+, AB-, O+, O-** in real time.
- Manages **Whole Blood, Packed Red Cells (PRBC), Platelets, Fresh Frozen Plasma (FFP)**.
- Enforces strict shelf-life monitoring (35-day whole blood expiry, 5-day platelets).
- Quarantines reactive or untested bags; never issues untested units.

### 2. Atomic Stock Deduction Transactions
- Hospital requisitions require clinical justification, patient reference ID, and priority triage (`Emergency - Critical`, `Urgent`, `Standard`).
- Upon fulfillment, database transactions atomically decrement group balances and mark physical bags (`LD-2026-XXX`) as `Issued` to eliminate negative inventory.

### 3. Voluntary Donor Lifecycle
- Registration with age (18–65), weight (≥ 45 kg), hemoglobin, and address.
- Encrypted password storage using **bcrypt**.
- Digital Donor ID Card with automated next eligible donation countdown (56-day whole blood buffer).
- Completed donation logs automatically restock blood bank reserves and generate certificates.

### 4. Accredited Hospital Portal
- Verified healthcare facilities can raise emergency and scheduled surgical requisitions.
- Administrator verification workflow prevents unaccredited access.

### 5. Central Administrator Master Console
- Live KPI cards: Total Donors, Total Blood Units, Requisitions, Pending Triage, Completed Donations.
- Interactive blood group distribution visualizer.
- Real-time critical low-stock alerts.
- Hospital verification controls & audit log compliance trail.

---

## 🗄️ MySQL Database Setup (Your Local MySQL Server 8.0)

Your project is pre-configured to connect to your local MySQL 8.0 instance using:

```env
DB_HOST=localhost
DB_USER=root
DB_PASSWORD=shaikrauf@12
DB_NAME=blood_bank
DB_PORT=3306
```

### Step 1: Start MySQL Server 8.0
On **Windows** (PowerShell or Administrator CMD):
```bash
net start MySQL80
```
On **Linux / macOS**:
```bash
sudo systemctl start mysql
```

### Step 2: Initialize Database and Tables
Run the provided `database.sql` script into your MySQL server:
```bash
mysql -u root -p"shaikrauf@12" < database.sql
```
*(Or open MySQL Workbench, load `database.sql`, and execute all statements).*

This creates the `blood_bank` database and all 12 relational tables:
1. `users`
2. `blood_banks`
3. `donors`
4. `hospitals`
5. `blood_stock`
6. `blood_units`
7. `blood_requests`
8. `donations`
9. `donation_appointments`
10. `inventory_transactions`
11. `notifications`
12. `audit_logs`

---

## 🚀 Running the Project

### 1. Install Dependencies
```bash
npm install
```

### 2. Start the Development Server
```bash
npm run dev
```

### 3. Open in Browser
Visit:
```
http://localhost:3000
```

---

## 🔑 Pre-Seeded Test Credentials

| Role | Email | Password | Access Rights |
| :--- | :--- | :--- | :--- |
| **Admin** | `admin@lifedrop.org` | `admin123` | Full Master Console, Approvals, Hospital Verification |
| **Donor** | `robert.chen@email.com` | `admin123` | Digital Donor Card, Donation History, Appointments |
| **Hospital** | `stjude@metrohealth.org` | `admin123` | St. Jude General Hospital Requisitions & Dispatch Tracking |

*(You can also click the 1-click **"Quick Seed Test Fill"** buttons directly on the login page!)*

---

## 🛠️ Project File Architecture

```
├── .env                  # MySQL 8.0 and JWT credentials (local)
├── .env.example          # Template credentials for distribution
├── database.sql          # 12-table schema, InnoDB FKs, and medical seed data
├── package.json          # Node scripts and dependencies
├── server.ts             # Express server + Vite middleware on port 3000
├── src/
│   ├── server/
│   │   ├── db.ts         # mysql2/promise connection pool & live memory mirror
│   │   └── routes.ts     # Express REST APIs (Auth, Donors, Inventory, Requests)
│   ├── api/
│   │   └── client.ts     # Frontend fetch client
│   ├── components/
│   │   ├── DbStatusBanner.tsx   # MySQL live status indicator & diagnostics
│   │   ├── Navbar.tsx           # Multi-portal navigation bar & mobile drawer
│   │   ├── Footer.tsx           # Transfusion 24/7 hotline & emergency info
│   │   └── QuickRequestModal.tsx# Instant emergency requisition modal
│   ├── pages/
│   │   ├── HomePage.tsx               # Landing page with live inventory grid
│   │   ├── FindBloodPage.tsx          # Real-time search by group & city
│   │   ├── DonorRegistrationPage.tsx  # Full donor registration form
│   │   ├── HospitalRegistrationPage.tsx# Hospital onboarding & verification
│   │   ├── LoginPage.tsx              # Multi-role login (Admin, Donor, Hosp)
│   │   ├── AdminDashboardPage.tsx     # Admin KPI metrics & stock deduction
│   │   ├── DonorManagementPage.tsx    # Donor CRUD, search, and edit modal
│   │   ├── BloodInventoryPage.tsx     # 8 blood group cards & bag barcodes
│   │   ├── BloodRequestsPage.tsx      # Requisitions ledger & deduction
│   │   ├── DonationsPage.tsx          # Record donations & auto-restock
│   │   ├── DonorDashboardPage.tsx     # Digital donor card & eligibility
│   │   ├── HospitalDashboardPage.tsx  # Hospital requisitions tracking
│   │   ├── AboutPage.tsx              # Mission & quality testing standards
│   │   ├── FaqPage.tsx                # Transfusion biology & eligibility FAQs
│   │   ├── ContactPage.tsx            # Emergency center hotlines & map
│   │   └── DatabaseStudioPage.tsx     # MySQL schema explorer & row counters
│   ├── types.ts          # Complete TypeScript types and interfaces
│   ├── main.tsx          # React application root
│   └── App.tsx           # Top-level state and 17-page router
```

---

## 🛡️ Medical Safety & Compliance
- **Antigen Matching:** Enforces compatibility rules (O- as Universal Red Cell Donor, AB+ as Universal Recipient).
- **Zero Expired Release:** Bags past the 35-day window are automatically flagged and excluded from available search results.
- **Audit Logging:** Every user login, stock inflow, and requisition issue is logged with user ID and IP address into `blood_bank.audit_logs`.
