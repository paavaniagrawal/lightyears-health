# LightYears Health - Complete Project Context

> **Purpose of this file:** This document is the single source of truth for the LightYears Health MVP. It is written so that any AI assistant or developer can pick up this project with zero prior context and know exactly what has been built, where everything lives, what works, what doesn't, and what's left to do.

> **Last updated:** 2026-03-10

---

## 1. WHAT IS LIGHTYEARS HEALTH?

LightYears Health is a **WhatsApp-native digital physiotherapy program** focused on **knee pain recovery**. Customers purchase nutraceutical bundles from a Shopify store, and as a **free add-on**, they get enrolled into a structured 12-week exercise and recovery program delivered entirely via WhatsApp.

### Core Concept
- Customer discovers the program via a **website survey** or a **community WhatsApp group**
- They fill an **intake assessment** (pain score, medical history, functional goals)
- Based on their pain score, they're classified into one of **3 exercise tiers**
- They purchase nutraceuticals on **Shopify** (exercises/yoga/program are FREE add-ons)
- They receive a **12-week structured program** via WhatsApp with:
  - Exercise video links (one message with one link to 5 videos per tier)
  - **Biweekly check-ins** every 2 weeks (6 check-in points: weeks 2, 4, 6, 8, 10, 12)
  - Safety escalation if pain scores worsen
- Program is marked **complete at the end of week 12**

### Exercise Bank Framework (3 Tiers)
| Pain Score | Tier | Exercise Types |
|-----------|------|---------------|
| 0-3 (Mild) | **Strengthening** | Squat variations, step ups, supported split squats, RDLs, single leg sit to stand, planks |
| 4-6 (Moderate) | **Recovery** | Bridge variations, clam shells, wall supported squats, hip mobility, core activation, resistance band work |
| 7-8 (Severe) | **Pain Management** | Quad sets, straight leg raises, heel slides, hamstring curls, standard bridge, hip mobility, pelvic tilts |
| 9-10 | **Redirect** | Too severe for self-guided program - redirect to professional care |

### Important: This is an MVP/Demo
This is **NOT a production system**. It's a proof-of-concept demo built to show the boss that the concept works. The person building it (Parag) will pretend to be the first customer. No real Shopify purchases will be made during the demo. The **internal dashboard is the star of the demo** - it must show engagement, retention, and pain score trends to evaluate whether the protocol works.

---

## 2. TECH STACK & ACCESS DETAILS

### Services Used

| Service | Purpose | URL / Access |
|---------|---------|-------------|
| **Supabase** | PostgreSQL database + REST API | Project ref: `ycswtvovrdkbfchjjaio` |
| **n8n Cloud** | Workflow automation engine | https://parag16.app.n8n.cloud |
| **Interakt** | WhatsApp message delivery | https://api.interakt.ai/v1/public/message/ |
| **GitHub Pages** | Hosts intake form + dashboard | https://paavaniagrawal.github.io/lightyears-health/ |
| **Shopify** | Customer storefront (NOT used in MVP demo) | Access pending from boss |

### Supabase Details
- **Project Reference:** `ycswtvovrdkbfchjjaio`
- **API URL:** `https://ycswtvovrdkbfchjjaio.supabase.co`
- **Anon (Public) Key:** `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inljc3d0dm92cmRrYmZjaGpqYWlvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzIzNDAzMjMsImV4cCI6MjA4NzkxNjMyM30.i1V8j18bTkWDhSF_hxFwxLm5wQDtDT8AyJCOarXViEw`
- **Service Role Key:** Stored as n8n environment variable `SUPABASE_SERVICE_KEY` (do NOT expose publicly)
- **Dashboard:** https://supabase.com/dashboard/project/ycswtvovrdkbfchjjaio

### n8n Cloud Details
- **Instance:** https://parag16.app.n8n.cloud
- **All LightYears workflows are prefixed with `LY -`** to distinguish them from other workflows on this instance
- **Environment Variables set (as of 2026-03-04):**
  - `SUPABASE_SERVICE_KEY` - Supabase service role key for full DB access
  - `INTERAKT_API_KEY` - Interakt API key (base64 encoded for Basic auth)
- **IMPORTANT: Use `$vars.VARIABLE_NAME` in n8n expressions, NOT `$env.VARIABLE_NAME`.** n8n Cloud blocks `$env`; variables set in the n8n UI must be accessed via `$vars`.
- **Note:** There is also a self-hosted n8n at `n8n.secondtheorycapital.com` - that is NOT used for this project

### GitHub Pages
- **Repository:** https://github.com/paavaniagrawal/lightyears-health
- **Live Site:** https://paavaniagrawal.github.io/lightyears-health/
- **GitHub Account:** `paavaniagrawal` (NOT `paragagrawal16` which is a different account)
- **Deployment:** Legacy GitHub Pages, auto-deploys from `main` branch root `/`
- **Local Source Files:** `/Users/paragagrawal/lightyears-health/` on Parag's MacBook
- **Git push:** Requires a GitHub Personal Access Token (PAT) as password — NOT the account password

### Interakt (WhatsApp)
- **API Endpoint:** `https://api.interakt.ai/v1/public/message/`
- **API Key:** Now set in n8n as `INTERAKT_API_KEY` (base64 encoded, ready for Basic auth header)
- **Demo phone number:** `+919167006051`

#### Registered WhatsApp Templates (5 total, all Meta-approved)

| Template Name | Header Type | headerValues | Used By |
|---------------|-------------|-------------|---------|
| `program_enrollment_confirmation` | IMAGE | `["https://paavaniagrawal.github.io/lightyears-health/assets/ly-logo.png"]` | WF1 (Intake Form Processor) |
| `day_x_exercise_delivery` | IMAGE | `["https://paavaniagrawal.github.io/lightyears-health/assets/ly-logo.png"]` | Daily Exercise Delivery |
| `daily_program_reminder` | TEXT | `["Knee Recovery"]` | Daily Program Reminder |
| `weekly_yoga_session_delivery` | NONE | *(not needed)* | Weekly Yoga Session Delivery |
| `progress_checkin` | TEXT | `["Knee Recovery"]` | Biweekly Check-in Sender |

**Critical: Header type matters!**
- IMAGE headers need an image URL in `headerValues` — the URL must be publicly accessible (404 = silent delivery failure)
- TEXT headers need a text value like `["Knee Recovery"]` — sending an image URL as a text header causes silent delivery failure
- NONE means no `headerValues` needed
- Interakt API returns `result: true` even when WhatsApp will silently fail to deliver (wrong header type, 404 image URL, etc.)
- Legacy template `wa_superusers_250925` still exists but is only used in WF2 (demo)

---

## 3. DATABASE SCHEMA (Supabase)

The original schema SQL is in `/Users/paragagrawal/Downloads/lightyears_schema.sql`. Additional migrations are in `/Users/paragagrawal/lightyears-health/migrations.sql` (added 2026-03-08).

### Tables

#### `users`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | Auto-generated |
| name | VARCHAR | |
| phone | VARCHAR | UNIQUE constraint |
| email | VARCHAR | |
| city | VARCHAR | **Added 2026-03-08** |
| gender | VARCHAR | **Added 2026-03-08** |
| source | VARCHAR | Default: 'google_form'. Options: 'google_form', 'community_whatsapp', 'website', 'intake_form' |
| created_at | TIMESTAMPTZ | Auto-set |

#### `intake_responses`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | |
| user_id | UUID (FK -> users) | CASCADE delete |
| age | INTEGER | |
| pain_score | INTEGER | CHECK: 0-10 |
| pain_location | VARCHAR | Default: 'knee' |
| functional_limitations | TEXT | Maps to "activities that worsen pain" |
| comorbidities | TEXT | Diabetes, hypertension, etc. |
| blood_marker_d3 | VARCHAR | 'low', 'normal', 'unknown' |
| blood_marker_b12 | VARCHAR | 'low', 'normal', 'unknown' |
| functional_goals | TEXT | What they want to do without pain |
| medical_history | TEXT | Surgical/medical history |
| pain_duration | VARCHAR | **Added 2026-03-08** — '<1 month', '1-3 months', etc. |
| functional_level | VARCHAR | **Added 2026-03-08** — 'independent', 'mild_limitation', etc. |
| submitted_at | TIMESTAMPTZ | |

#### `program_enrollments`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | |
| user_id | UUID (FK -> users) | |
| program_type | VARCHAR | Default: 'knee_pain_12week' |
| stage | VARCHAR | 'pain_management', 'recovery', 'strengthening' |
| eligibility | VARCHAR | 'self_guided', 'consultation', 'redirect_professional' |
| status | VARCHAR | 'enrolled' -> 'active' -> 'completed' or 'dropped_off' |
| current_week | INTEGER | 0-12 |
| start_date | DATE | Set when activated |
| expected_end_date | DATE | start_date + 84 days |
| completed_at | TIMESTAMPTZ | |
| dropped_off_at | TIMESTAMPTZ | |
| created_at | TIMESTAMPTZ | |

**Status Flow:** `enrolled` (after intake form) -> `active` (after purchase/activation) -> `completed` (week 12) or `dropped_off`

#### `health_metrics` (append-only time-series)
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | |
| user_id | UUID (FK -> users) | |
| enrollment_id | UUID (FK -> program_enrollments) | |
| metric_type | VARCHAR | 'pain_score', 'functional_test', 'exercise_adherence' |
| value | NUMERIC | The metric value |
| week_number | INTEGER | Which week (0-12) |
| notes | TEXT | |
| recorded_at | TIMESTAMPTZ | |

**IMPORTANT:** This table is append-only. Never overwrite, always insert new rows. This creates a time-series of all measurements.

#### `escalations`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | |
| user_id | UUID (FK -> users) | |
| enrollment_id | UUID (FK -> program_enrollments) | |
| trigger_reason | VARCHAR | 'pain_increase', 'high_pain_score', 'missed_checkins', 'user_request' |
| severity | VARCHAR | 'low', 'medium', 'high' |
| assigned_to | VARCHAR | |
| status | VARCHAR | 'open', 'in_progress', 'resolved' |
| resolution_notes | TEXT | |
| created_at | TIMESTAMPTZ | |
| resolved_at | TIMESTAMPTZ | |

#### `message_log`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | |
| user_id | UUID (FK -> users) | |
| enrollment_id | UUID (FK -> program_enrollments) | |
| direction | VARCHAR | 'outbound', 'inbound' |
| message_type | VARCHAR | 'welcome', 'exercise_link', 'checkin', 'yoga_reminder', 'completion', 'reengagement' |
| template_name | VARCHAR | Interakt template name |
| content_summary | TEXT | |
| delivery_status | VARCHAR | 'sent', 'delivered', 'read', 'failed' |
| sent_at | TIMESTAMPTZ | |

#### `daily_progress` (**NEW - Added 2026-03-08**)
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | Auto-generated |
| user_id | UUID (FK -> users) | CASCADE delete |
| enrollment_id | UUID (FK -> program_enrollments) | CASCADE delete |
| day_number | INTEGER | CHECK: 1-84 (12 weeks x 7 days) |
| activity_type | VARCHAR | 'exercise', 'yoga', 'rest'. Default: 'exercise' |
| status | VARCHAR | 'completed', 'missed', 'partial'. Default: 'completed' |
| completed_at | TIMESTAMPTZ | NULL if missed |
| notes | TEXT | |
| created_at | TIMESTAMPTZ | |

Tracks daily exercise adherence across the 84-day (12-week) program. Used in the Clinical Outcomes and User Profile views.

#### `purchases` (**NEW - Added 2026-03-08**)
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | Auto-generated |
| user_id | UUID (FK -> users) | CASCADE delete |
| order_id | VARCHAR | Format: '#LY-0001' |
| product_name | VARCHAR | Currently only 'Knee Recovery Bundle' |
| product_category | VARCHAR | Default: 'bundle' |
| quantity | INTEGER | Default: 1 |
| unit_price | NUMERIC | Rs 3,500 |
| total_price | NUMERIC | Rs 3,500 |
| currency | VARCHAR | Default: 'INR' |
| status | VARCHAR | Default: 'completed' |
| purchased_at | TIMESTAMPTZ | |
| created_at | TIMESTAMPTZ | |

Dummy purchase data for revenue tracking. Single product: "Knee Recovery Bundle" at Rs 3,500. Real Shopify integration would replace this.

#### `user_notes` (**NEW - Added 2026-03-10**)
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | Auto-generated |
| user_id | UUID (FK -> users) | CASCADE delete |
| note_text | TEXT | NOT NULL |
| author_name | VARCHAR | Default: 'Nutritionist' |
| created_at | TIMESTAMPTZ | Auto-set |

Stores nutritionist consultation notes per user. Displayed in the user profile right column with add/delete UI.

### Database Views (power the dashboard)

1. **`v_program_summary`** — Top-level stats: total enrollments, active, completed, dropped off, completion rate %, dropout rate %, **total_revenue**, **paying_customers** (enhanced 2026-03-08)
2. **`v_pain_score_trend`** — Pain score progression over weeks, with baseline comparison and improvement calculation
3. **`v_checkin_completion`** — Check-in completion rate per user (actual vs expected, based on biweekly schedule). **Now includes `user_id` column** (fixed 2026-03-08)
4. **`v_escalation_queue`** — Open escalations sorted by severity (high -> medium -> low)
5. **`v_active_programs`** — Joins users + enrollments + intake responses for active programs
6. **`v_user_profiles`** (**NEW 2026-03-08**) — Unified user view joining users + intake_responses + program_enrollments. Used by the User Profile page. Includes all demographic, medical, and enrollment data in one view.
7. **`v_lifecycle_funnel`** (**NEW 2026-03-08**) — Lifecycle conversion funnel: Leads → Survey Completed → Purchased → Program Active → Completed. Each row has `stage`, `stage_order`, `count`.

### Row Level Security
- RLS is **enabled** on all 9 tables (6 original + 3 new: daily_progress, purchases, user_notes)
- **Anon read policies** on all 9 tables so the dashboard (which uses the anon key) can read data
- **Anon write policies for admin actions:**
  - `anon_update_escalations` ON escalations FOR UPDATE TO anon — allows dashboard to resolve/assign escalations
  - `anon_update_enrollments` ON program_enrollments FOR UPDATE TO anon — allows dashboard to pause/restart/change stage
  - `anon_insert_message_log` ON message_log FOR INSERT TO anon — allows dashboard to log manual messages
- **Anon write policies for user_notes (added 2026-03-10):**
  - `anon_insert` ON user_notes FOR INSERT TO anon — allows adding consultation notes from dashboard
  - `anon_delete` ON user_notes FOR DELETE TO anon — allows deleting notes from dashboard
- n8n workflows use the `SUPABASE_SERVICE_KEY` which bypasses RLS entirely
- For production, tighten these policies

### Migration File
- **File:** `/Users/paragagrawal/lightyears-health/migrations.sql`
- **Contains 8 migrations** (run in Supabase SQL Editor):
  1. Add `city`, `gender` to users; `pain_duration`, `functional_level` to intake_responses
  2. Create `daily_progress` table + RLS
  3. Create `purchases` table + RLS
  4. Drop and recreate all 5 existing views + create 2 new views
  5. Anon write policies for admin actions
  6. Dummy data population (city/gender, pain_duration/functional_level, purchases, 84 days of daily_progress)
  7. *(number skipped)*
  8. Create `user_notes` table + RLS (added 2026-03-10)
- **Status:** All migrations have been run successfully in Supabase
- **Additional dummy data script** (run 2026-03-10): Populates all empty fields — user demographics, intake details, purchases, health_metrics (biweekly pain scores), daily_progress, escalations, and consultation notes. This script is idempotent (safe to re-run).

---

## 4. n8n WORKFLOWS

All 10 workflows live on **https://parag16.app.n8n.cloud** and are prefixed with `LY -`.

**Current state (as of 2026-03-10): ALL 10 workflows are ACTIVE** (6 original + 4 new scheduled message workflows)

**Critical: ALL `$env.` references have been replaced with `$vars.`** across all 16 nodes in all 6 workflows. n8n Cloud does not allow `$env` — use `$vars.VARIABLE_NAME` for any n8n environment variable.

### Workflow 1: LY - Intake Form Processor
- **ID:** `aUl9IaWnWVMJYyqV`
- **Status:** ACTIVE
- **Trigger:** Webhook at `https://parag16.app.n8n.cloud/webhook/ly-intake`
  - Path changed from `lightyears-intake` to `ly-intake` — the old path was stuck in a broken registration state. The intake-form.html has been updated to match.
- **Purpose:** Receives intake form submissions, classifies the user, creates records in Supabase
- **Nodes (8):** *(was 6, updated 2026-03-10 to send enrollment confirmation WhatsApp)*
  1. `Receive Form Submission` (Webhook) - POST endpoint, `responseMode: onReceived`
  2. `Classify User` (Code, nodeId: `code1`) - Determines stage + eligibility based on pain score and medical history. Now also parses `city`, `gender`, `painDuration`, `functionalLevel` from body.
  3. `Create User in Supabase` (HTTP Request, nodeId: `http_create_user`) - POST to /rest/v1/users. Includes `city` and `gender`.
  4. `Prepare Intake + Enrollment Data` (Code) - Formats data for both tables
  5. `Store Intake Responses` (HTTP Request, nodeId: `http_create_intake`) - POST to /rest/v1/intake_responses. Includes `pain_duration` and `functional_level`.
  6. `Create Program Enrollment` (HTTP Request) - POST to /rest/v1/program_enrollments
  7. `Send Enrollment Confirmation via Interakt` (HTTP Request) - **NEW 2026-03-10** — POST to Interakt API, template `program_enrollment_confirmation` with IMAGE header, `onError: continueRegularOutput`
  8. `Log Enrollment Message` (HTTP Request) - **NEW 2026-03-10** — POST to Supabase message_log

- **Key webhook node settings (critical for registration to work):**
  - `typeVersion: 2.1`
  - `responseMode: "onReceived"` (inside parameters)
  - `path: "ly-intake"` (inside parameters)
  - `webhookId: "e90b67b9-3b60-4c6d-b3fc-07c68b364663"` (top-level node field — required!)
  - `onError: "continueRegularOutput"` (top-level node field — required!)

- **Classification Logic (in "Classify User" node):**
  ```
  Pain 0-3 -> stage: 'strengthening'
  Pain 4-6 -> stage: 'recovery'
  Pain 7+  -> stage: 'pain_management'

  Red flags (surgery, fracture, tumor, etc.) OR pain 9+ -> eligibility: 'redirect_professional'
  Pain 7+ OR age 65+ -> eligibility: 'consultation'
  Otherwise -> eligibility: 'self_guided'
  ```

### Workflow 2: LY - Demo: Simulate Purchase & Activate
- **ID:** `4cSnHcnYoCYiJkLt`
- **Status:** ACTIVE
- **Trigger:** Manual (click to run)
- **Purpose:** Simulates a purchase and activates the program (no real Shopify in demo)
- **Demo phone number:** `+919167006051`
- **Nodes (7):**
  1. `Manual Trigger`
  2. `Set Demo Customer Data` (Set)
  3. `Find User by Phone` (HTTP Request)
  4. `Activate Program` (Code)
  5. `Update Enrollment to Active` (HTTP Request) - PATCH by `user_id` only (no status filter for re-runnability)
  6. `Send Welcome via Interakt` (HTTP Request) - Uses template `wa_superusers_250925` with `headerValues`
  7. `Log Welcome Message` (HTTP Request)

### Workflow 3: LY - Biweekly Check-in Sender
- **ID:** `ivCNGhvIZHe38en5`
- **Status:** ACTIVE
- **Trigger:** Schedule - Every day at 9am
- **Purpose:** Sends WhatsApp check-in to active users at weeks 2, 4, 6, 8, 10, 12
- **Nodes (5):** Schedule Trigger → Get Active Enrollments → Filter Due → Send via Interakt → Log Message

### Workflow 4: LY - Check-in Response Handler
- **ID:** `5pZw8RrpZVVVdLlC`
- **Status:** ACTIVE
- **Trigger:** Webhook at `https://parag16.app.n8n.cloud/webhook/lightyears-checkin`
- **Purpose:** Processes check-in responses, stores pain scores, triggers safety escalations
- **Safety escalation triggers:**
  - Pain score >= 8 -> HIGH severity
  - Pain increased by 2+ points -> MEDIUM severity
- **Nodes (8):** Webhook → Parse → Find User → Prepare Metric → Store (parallel) → Safety Check (parallel) → Escalation (if needed) → Respond OK

### Workflow 5: LY - Lifecycle Manager
- **ID:** `lEGHJ2FiMzZDSX34`
- **Status:** ACTIVE
- **Trigger:** Schedule - Daily at midnight
- **Purpose:** Advances week numbers, detects program completion at day 84
- **Nodes (5):** Schedule → Get Enrollments → Process Updates → Route → Update Supabase

### Workflow 6: LY - Demo: Boss Demo Fast-Forward
- **ID:** `UWeSnQ8Au8KqqEVo`
- **Status:** ACTIVE
- **Trigger:** Manual (click to run)
- **Purpose:** Generates 12 weeks of demo data instantly
- **Demo phone number:** `+919167006051`
- **Simulated data:** Pain scores: 6→5→4→4→3→2, Adherence: 80%→85%→85%→90%→90%→95%
- **Nodes (6):** Manual → Set Phone → Find Enrollment → Simulate Data → Insert Metrics → Mark Completed

### Workflow 7: LY - Daily Exercise Delivery (**NEW 2026-03-10**)
- **ID:** `FV3Km4IeHQkq1hsL`
- **Status:** ACTIVE
- **Trigger:** Schedule - Every day at 7:00 AM
- **Purpose:** Sends daily exercise video link via WhatsApp to active/enrolled users
- **Template:** `day_x_exercise_delivery` (IMAGE header)
- **Nodes (5):** Schedule → Get Active Enrollments → Build Message per User → Send via Interakt → Log Message
- **Supabase query:** `status=in.(enrolled,active)&select=*,users(*)`

### Workflow 8: LY - Daily Program Reminder (**NEW 2026-03-10**)
- **ID:** `0TC7ytshEQB8vQPj`
- **Status:** ACTIVE
- **Trigger:** Schedule - Every day at 6:00 PM
- **Purpose:** Sends daily motivation/reminder via WhatsApp
- **Template:** `daily_program_reminder` (TEXT header — `headerValues: ["Knee Recovery"]`)
- **Nodes (5):** Schedule → Get Active Enrollments → Build Message per User → Send via Interakt → Log Message

### Workflow 9: LY - Weekly Yoga Session Delivery (**NEW 2026-03-10**)
- **ID:** `GOc5dn6fgvDS9cb4`
- **Status:** ACTIVE
- **Trigger:** Schedule - Every Sunday at 8:00 AM
- **Purpose:** Sends weekly yoga session link via WhatsApp
- **Template:** `weekly_yoga_session_delivery` (NO header — no headerValues needed)
- **Nodes (5):** Schedule → Get Active Enrollments → Build Message per User → Send via Interakt → Log Message

### Workflow 3 (Biweekly Check-in) Update
- **Template changed to:** `progress_checkin` (TEXT header — `headerValues: ["Knee Recovery"]`)
- **Enrollment filter updated:** `status=in.(enrolled,active)` (was `status=eq.active`)
- **Note:** Filter temporarily includes week 1 for testing — should be reverted to weeks 2,4,6,8,10,12 only for production

---

## 5. FRONTEND FILES

### File: `index.html` (Landing Page)
- **Live URL:** https://paavaniagrawal.github.io/lightyears-health/
- **Local path:** `/Users/paragagrawal/lightyears-health/index.html`
- Simple landing page with two cards linking to the intake form and dashboard
- Uses Tailwind CSS CDN

### File: `intake-form.html` (Customer-Facing Intake Assessment)
- **Live URL:** https://paavaniagrawal.github.io/lightyears-health/intake-form.html
- **Local path:** `/Users/paragagrawal/lightyears-health/intake-form.html`
- **Updated 2026-03-08** with 4 new fields:
- 3-step professional form:
  - Step 1: Personal info (name, phone with +91 prefix, email, age, **city**, **gender**)
  - Step 2: Pain assessment (0-10 slider with color feedback, aggravators, relievers, functional goals, **pain duration**)
  - Step 3: Medical background (comorbidities, medical history, D3 & B12 levels, **functional level**)
- **Submits to:** `https://parag16.app.n8n.cloud/webhook/ly-intake`
- **Payload now includes:** `city`, `gender`, `pain_duration`, `functional_level` (in addition to all original fields)
- **Fallback:** If the webhook fails, classifies locally using the same logic
- Shows a personalized result screen with exercise tier recommendation after submission

### File: `dashboard.html` (CRM Dashboard — **REBUILT 2026-03-08, UPDATED 2026-03-10**)
- **Live URL:** https://paavaniagrawal.github.io/lightyears-health/dashboard.html
- **Local path:** `/Users/paragagrawal/lightyears-health/dashboard.html`
- **902 lines** — Complete single-page application with hash-based routing
- **Connects directly to Supabase** using the anon key (no n8n in between)
- Uses Tailwind CSS CDN, Chart.js 4.4.1, Supabase JS v2

#### Hash Routes (7 nav tabs + 1 dynamic route)

| Route | Tab Name | What It Shows |
|-------|----------|--------------|
| `#overview` | Overview | Summary cards (enrolled, active, completed, dropped, completion rate, revenue), Pain Score Trend chart, Stage Distribution doughnut, Check-in Completion bar, Key Clinical Metrics stats |
| `#operations` | Operations | Alert cards (high pain, missing check-ins, at-risk, open escalations), Needs Attention table, Missing Check-ins table, At-Risk Drop-offs table |
| `#clinical` | Clinical | Aggregate pain trend line chart, Before/After grouped bar, Daily Adherence chart from `daily_progress`, Program Effectiveness table by stage, Cohort filter by start month |
| `#conversion` | Conversion | Revenue cards (total, orders, AOV, customers), Lifecycle Funnel horizontal bar (Lead→Survey→Purchase→Active→Completed with conversion %), Purchase History table |
| `#users` | Users | Filterable/searchable table (status, stage, name/phone search), columns: Name, Phone, City, Stage, Status, Week, Baseline Pain, Latest Pain, Adherence %, Check-ins, Enrolled. Clickable rows → user profile. CSV export |
| `#escalations` | Escalations | Filter by status/severity, table with action buttons per row (Assign to team member, Add Note, Resolve), Resolved Cases section, CSV export |
| `#messages` | Messages | Stat cards (sent, delivered rate, read rate, inbound), Messages Over Time chart, Recent Messages table, CSV export |
| `#user/:id` | (dynamic) | **User Profile page** — two-column layout. See details below |

#### User Profile Page (`#user/:id`) — Detailed Layout

**Left column (2/3 width):**
- Personal pain score timeline (line chart)
- Daily progress grid — 84-day calendar, color-coded: green=completed, yellow=partial, red=missed, gray=future
- Check-in history table (week, pain score, notes, date)
- Message log (filtered to this user)
- Escalation history

**Right column (1/3 width):**
- Profile info card (name, phone, email, city, gender, age, source)
- Program status card (stage badge, status badge, week X/12, start date, expected end)
- Intake survey card (pain score, pain location, limitations, comorbidities, goals, blood markers, pain duration, functional level)
- Flags card (high pain severity, comorbidities, severe limitation)
- Purchase history
- **Consultation Notes card** (**NEW 2026-03-10**):
  - Add note form (textarea + author name input, default "Nutritionist")
  - Notes list with author, timestamp, full text (whitespace-pre-wrap for multiline)
  - Delete button (x) with confirm() dialog per note
  - Note count badge in header
  - Scrollable (max-h-80) for many notes
  - JS functions: `addNote(userId)`, `deleteNote(noteId)`
- **Admin action buttons:**
  - Pause Program / Restart Program (toggles based on current status)
  - Change Stage (dropdown: pain_management, recovery, strengthening)
  - Mark Dropped Off

#### JS Architecture (sections in the single file)
1. **CONFIG** — Supabase URL, anon key, `db` client (NOT `supabase` — avoids UMD conflict)
2. **STATE** — `state.route`, `state.userId`, `state.charts` (Chart.js instances)
3. **UTILITIES** — `fmt` object (date/dateTime/currency/pct/cap/trunc formatters), `statusColor` map, `B()` (badge HTML), `SC()` (stat card HTML), `AC()` (alert card HTML), `ER()` (empty table row), `csvExport()` function
4. **ROUTER** — `parseRoute()`, `navigateTo()`, `handleRoute()`, `renderView()`, hashchange listener
5. **VIEW RENDERERS** — `renderOverview()`, `renderOperations()`, `renderClinical()`, `renderConversion()`, `renderUsers()`, `renderUserProfile()`, `renderEscalations()`, `renderMessages()`
6. **FILTER FUNCTIONS** — `filterUsers()`, `filterEsc()` for client-side filtering
7. **EXPORT FUNCTIONS** — `exportUsers()`, `exportPurchases()`, `exportEsc()`, `exportMsgs()` — CSV downloads
8. **ADMIN ACTIONS** — `adminAction(userId, action)` (pause/restart/drop/changeStage), `assignEsc(id)`, `resolveEsc(id)`, `addEscNote(id)`, `addNote(userId)`, `deleteNote(noteId)`
9. **CHART MANAGEMENT** — `state.charts` object, `destroyAllCharts()` on route change
10. **INIT** — Router setup, initial data load, auto-refresh every 60 seconds (when tab visible)

**Key constants:**
- `TEAM = ['Abha', 'Dr. Devashree']` — team members for escalation assignment

---

## 6. HOW THE SYSTEM CONNECTS (Data Flow)

```
[Customer fills intake form on GitHub Pages]
        |
        v (POST to webhook)
[n8n: LY - Intake Form Processor]
        |
        v (HTTP requests)
[Supabase: creates user + intake_response + program_enrollment with status='enrolled']
        |
        v (sends WhatsApp)
[Interakt: sends enrollment confirmation via template program_enrollment_confirmation]
[Supabase: logs message in message_log]
        |
        v (form shows result page)
[Customer sees their exercise tier recommendation]


[Parag runs "LY - Demo: Simulate Purchase & Activate" in n8n]
        |
        v
[Supabase: enrollment status changes 'enrolled' -> 'active', start_date set]
[Interakt: sends welcome WhatsApp message using template wa_superusers_250925]
[Supabase: logs message in message_log]


[Every day at 9am - "LY - Biweekly Check-in Sender"]
        |
        v
[Checks which active users are at week 2, 4, 6, 8, 10, or 12]
[Interakt: sends check-in WhatsApp message to those users]
[Supabase: logs message]


[Customer replies to check-in -> Interakt forwards to n8n webhook]
        |
        v
[n8n: LY - Check-in Response Handler]
        |
        v
[Supabase: stores pain score in health_metrics (append-only)]
[If pain >= 8 or increased by 2+: creates escalation in escalations table]


[Every day at 7am - "LY - Daily Exercise Delivery"]
        |
        v
[Sends exercise video link to all active/enrolled users via WhatsApp]
[Uses template: day_x_exercise_delivery (IMAGE header)]


[Every day at 6pm - "LY - Daily Program Reminder"]
        |
        v
[Sends motivational reminder to all active/enrolled users via WhatsApp]
[Uses template: daily_program_reminder (TEXT header)]


[Every Sunday at 8am - "LY - Weekly Yoga Session Delivery"]
        |
        v
[Sends yoga session link to all active/enrolled users via WhatsApp]
[Uses template: weekly_yoga_session_delivery (no header)]


[Every day at midnight - "LY - Lifecycle Manager"]
        |
        v
[Advances current_week for active enrollments]
[At day 84 (week 12): marks enrollment as 'completed']


[CRM Dashboard on GitHub Pages]
        |
        v (direct Supabase queries using anon key)
[Reads from views: v_program_summary, v_pain_score_trend, v_checkin_completion, v_escalation_queue, v_active_programs, v_user_profiles, v_lifecycle_funnel]
[Also reads directly from: program_enrollments, intake_responses, health_metrics, message_log, daily_progress, purchases, escalations, users, user_notes]
[Writes (admin actions): escalations (resolve/assign/note), program_enrollments (pause/restart/stage change), user_notes (add/delete consultation notes)]
```

---

## 7. WHAT HAS BEEN COMPLETED

| # | Task | Status | Date | Notes |
|---|------|--------|------|-------|
| 1 | Supabase database schema | DONE | 2026-03-01 | 6 tables, 5 views, RLS enabled |
| 2 | n8n workflows (6 total) | DONE | 2026-03-02 | All created and ACTIVE |
| 3 | Supabase <> n8n connection | DONE | 2026-03-02 | Tested read/write/delete |
| 4 | Intake form (HTML) | DONE | 2026-03-02 | 3-step form with validation |
| 5 | Original dashboard (4-tab) | DONE | 2026-03-03 | Basic overview, users, escalations, messages |
| 6 | Classification logic aligned | DONE | 2026-03-03 | Matches Exercise Bank Framework |
| 7 | Deploy to GitHub Pages | DONE | 2026-03-03 | Live at paavaniagrawal.github.io |
| 8 | Fix $env -> $vars in all workflows | DONE | 2026-03-04 | 16 nodes across 6 workflows |
| 9 | Set INTERAKT_API_KEY in n8n | DONE | 2026-03-04 | Set in n8n Cloud Variables |
| 10 | Fix WF1 webhook registration | DONE | 2026-03-04 | Changed path, added webhookId |
| 11 | Fix WF2 Interakt image header | DONE | 2026-03-04 | Added headerValues |
| 12 | Fix WF2 re-runnability | DONE | 2026-03-04 | Removed status filter from PATCH |
| 13 | Add Supabase anon RLS policies | DONE | 2026-03-04 | All 6 tables have anon SELECT |
| 14 | Fix dashboard JS naming conflict | DONE | 2026-03-04 | const supabase -> const db |
| 15 | Activate all 6 workflows | DONE | 2026-03-04 | All ACTIVE |
| 16 | End-to-end demo test | DONE | 2026-03-04 | Full flow tested successfully |
| 17 | Database migrations (new tables/views) | DONE | 2026-03-08 | daily_progress, purchases tables; v_user_profiles, v_lifecycle_funnel views; updated existing views; anon write policies; dummy data |
| 18 | Rebuild dashboard as full CRM SPA | DONE | 2026-03-08 | 8-view SPA with hash routing (overview, operations, clinical, conversion, users, escalations, messages, user profile) |
| 19 | Add user profile page | DONE | 2026-03-08 | Two-column layout with pain timeline, daily progress grid, check-ins, messages, escalations, admin actions |
| 20 | Add intake form new fields | DONE | 2026-03-08 | city, gender, pain_duration, functional_level added to form |
| 21 | Update n8n WF1 for new fields | DONE | 2026-03-08 | Classify User, Create User, Store Intake nodes updated via MCP |
| 22 | Admin actions in dashboard | DONE | 2026-03-08 | Pause/restart program, change stage, resolve/assign/note escalations |
| 23 | CSV export | DONE | 2026-03-08 | Export from Users, Purchases, Escalations, Messages views |
| 24 | Push all changes to GitHub | DONE | 2026-03-08 | Commits: b1594f8 (full rebuild), ac106aa (migration fix) |
| 25 | Wire enrollment confirmation to WF1 | DONE | 2026-03-10 | Added 2 nodes: Send Enrollment Confirmation via Interakt + Log Enrollment Message |
| 26 | Push LY logo to GitHub Pages | DONE | 2026-03-10 | `/assets/ly-logo.png` — resolves 404 for Interakt image headers |
| 27 | Create 4 scheduled WhatsApp workflows | DONE | 2026-03-10 | Daily Exercise, Daily Reminder, Weekly Yoga, updated Biweekly Check-in |
| 28 | Debug & fix all 5 WhatsApp templates | DONE | 2026-03-10 | Fixed IMAGE vs TEXT header types, enrollment status filter, 404 image URL |
| 29 | Add Consultation Notes feature | DONE | 2026-03-10 | user_notes table + dashboard UI (add/delete notes in user profile) |
| 30 | Populate dummy data for all empty fields | DONE | 2026-03-10 | User demographics, intake details, purchases, health metrics, daily progress, escalations, consultation notes |

---

## 8. WHAT STILL NEEDS TO BE DONE

### Immediate (Verify & Fix)
1. **Revert biweekly check-in week 1 test filter** — WF3 (Biweekly Check-in Sender) was temporarily modified to include week 1 for testing. Revert to only weeks 2,4,6,8,10,12 before production.
2. **Test on mobile** — Dashboard and intake form should be responsive.

### For a Polished Demo
1. **Clear demo data before boss demo** — Truncate all tables and start fresh, then re-run intake form + dummy data script.
2. **Verify all 4 scheduled workflows fire on schedule** — They've been tested manually; confirm cron triggers work.

### Nice to Have (Post-Demo)
- Connect real Shopify purchase webhook to trigger activation automatically
- Tighten Supabase RLS policies for production security
- Add authentication to the dashboard (currently open to anyone with the URL)
- Build proper exercise video hosting/linking
- Real Interakt webhook integration for inbound messages
- Content management tab for exercise videos per tier
- Add edit capability to consultation notes (currently only add/delete)

---

## 9. KNOWN ISSUES & GOTCHAS

### Critical Things to Know

1. **n8n Cloud: `$vars` not `$env`**: All environment variables in n8n Cloud expressions must use `$vars.VARIABLE_NAME`. Using `$env.VARIABLE_NAME` causes a "blocked for security reasons" error.

2. **n8n webhook registration quirks:**
   - Webhook nodes need a `webhookId` UUID field at the top level of the node object.
   - `onError: "continueRegularOutput"` must also be a top-level node property.
   - If a webhook path gets stuck, change the path AND add a `webhookId`.
   - WF1's path was changed from `lightyears-intake` to `ly-intake` for this reason.

3. **n8n `responseMode: responseNode` + parallel branches = HTTP 500**: Fix: use `responseMode: "onReceived"` and remove the Respond to Webhook node.

4. **Interakt template `wa_superusers_250925` has image header**: Must include `"headerValues": ["<image_url>"]`. Empty array or missing field causes 400.

5. **Supabase RLS with anon key**: Must have explicit `FOR SELECT TO anon USING (true)` policy. Added to all 8 tables.

6. **dashboard.html uses `db` not `supabase`**: The Supabase UMD JS sets `window.supabase` as a global. Using `const supabase = ...` causes `SyntaxError`. Use `const db = window.supabase.createClient(...)` instead.

7. **WF2 Update Enrollment PATCH — no status filter**: URL must NOT filter by `&status=eq.enrolled` for re-runnability.

8. **PostgreSQL: no window functions in UPDATE SET**: `ROW_NUMBER() OVER()` cannot be used directly in an UPDATE SET clause. Must wrap in a subquery/CTE. This was fixed in migrations.sql migration 6a on 2026-03-08.

9. **n8n `updateNode` MCP operation**: Must use `"nodeId"` (e.g., `"code1"`) not node name, and `"updates": {...}` wrapper object.

10. **Supabase MCP connection**: The Supabase MCP tool in the dev environment is connected to a different project (SecondTheoryCapital's), NOT the LightYears project. SQL changes for LightYears must be done via the Supabase SQL Editor in the browser, NOT via MCP.

11. **n8n MCP**: Use `mcp__n8n-mcp-cloud__` tools (for parag16.app.n8n.cloud), NOT `mcp__n8n-mcp__` (which connects to a different self-hosted instance).

12. **Interakt silent delivery failures**: Interakt API returns `result: true` even when WhatsApp will silently fail to deliver. Causes include: wrong header type (sending image URL for a TEXT header), 404 image URL for an IMAGE header. Always verify the template's header type in Interakt before configuring headerValues.

13. **n8n Cloud URL prefix `=`**: Expression-enabled fields in n8n nodes (like HTTP Request URL) need the `=` prefix for expressions to evaluate. Removing it breaks Supabase queries silently (returns 0 results).

14. **n8n `addConnection` MCP syntax**: Uses `source`/`target` objects (NOT `from`/`to`). Example: `{"source": {"node": "NodeA", "output": "main", "index": 0}, "target": {"node": "NodeB", "input": "main", "index": 0}}`.

15. **Supabase PostgREST `in` filter**: For multiple values use `status=in.(enrolled,active)` — parentheses required.

16. **PostgreSQL `EXTRACT(WEEK FROM interval)`**: Not supported. Use `EXTRACT(DAY FROM interval)::int / 7` instead.

---

## 10. FILE STRUCTURE

```
/Users/paragagrawal/lightyears-health/     (local source, also GitHub repo)
  index.html                                Landing page
  intake-form.html                          Customer-facing intake assessment (updated 2026-03-08)
  dashboard.html                            CRM Dashboard - 8-view SPA (rebuilt 2026-03-08, updated 2026-03-10)
  migrations.sql                            Database migrations (8 migrations, last added 2026-03-10)
  PROJECT_CONTEXT.md                        This file
  assets/
    ly-logo.png                             LightYears Health logo (added 2026-03-10, used in WhatsApp image headers)

/Users/paragagrawal/Downloads/
  lightyears_schema.sql                     Original database schema (already executed)
  LightYears Health Product Vision.pdf      Original product vision document
  Knee Pain Questionnaire.pdf               5 core intake questions + vitamin question
  Exercise Bank Framework.pdf               3-tier exercise classification
```

---

## 11. HOW TO RUN THE BOSS DEMO (Step-by-Step)

### Before the Demo: Reset Demo Data
1. Go to Supabase SQL editor: https://supabase.com/dashboard/project/ycswtvovrdkbfchjjaio/sql
2. Run the following to clear all data:
   ```sql
   DELETE FROM daily_progress;
   DELETE FROM purchases;
   DELETE FROM health_metrics;
   DELETE FROM message_log;
   DELETE FROM escalations;
   DELETE FROM program_enrollments;
   DELETE FROM intake_responses;
   DELETE FROM users;
   ```
3. Confirm all 6 workflows are ACTIVE at https://parag16.app.n8n.cloud

### During the Demo
1. **Open the intake form:** https://paavaniagrawal.github.io/lightyears-health/intake-form.html
2. **Fill it out** as a demo patient:
   - Phone: `9167006051` (form prepends +91)
   - Pain score: 5 or 6 (Recovery tier)
   - Fill city, gender, pain duration, functional level
3. **Show the result screen** — exercise tier recommendation
4. **Go to n8n** and run `LY - Demo: Simulate Purchase & Activate`
   - Activates enrollment, sends WhatsApp to +919167006051
   - Show WhatsApp message on phone
5. **Run** `LY - Demo: Boss Demo Fast-Forward`
   - Generates 12 weeks of data (pain 6→2, adherence 80→95%)
6. **Then run migrations.sql Migration 6** in Supabase SQL editor to populate daily_progress, purchases, city/gender, pain_duration/functional_level for the demo user
7. **Open the dashboard:** https://paavaniagrawal.github.io/lightyears-health/dashboard.html
8. **Walk through each tab:**
   - **Overview:** Summary cards, pain trend chart, stage distribution, clinical metrics
   - **Operations:** Alert cards for high pain, missing check-ins, at-risk users
   - **Clinical:** Aggregate pain trends, before/after comparison, daily adherence, program effectiveness
   - **Conversion:** Revenue cards, lifecycle funnel, purchase history
   - **Users:** Searchable/filterable user table → click a user to see their full profile
   - **User Profile:** Pain timeline, 84-day progress grid, check-ins, messages, escalations, admin actions
   - **Escalations:** Case management with assign/resolve/notes
   - **Messages:** WhatsApp engagement stats and message log
9. **Demo admin actions:** Resolve an escalation, pause/restart a program

### Key Talking Points
- Pain scores decreased from 6 to 2 over 12 weeks — 67% reduction
- 95% exercise adherence by end of program
- Automated safety escalation if pain worsens
- Full lifecycle funnel: Lead → Survey → Purchase → Active → Completed
- All delivered via WhatsApp with zero manual work
- Comprehensive CRM with user profiles, clinical analytics, revenue tracking

---

## 12. QUICK REFERENCE: API ENDPOINTS

### Supabase REST API
All requests need these headers:
```
apikey: [SUPABASE_ANON_KEY or SUPABASE_SERVICE_KEY]
Authorization: Bearer [same key]
Content-Type: application/json
```

| Action | Method | URL |
|--------|--------|-----|
| List users | GET | `https://ycswtvovrdkbfchjjaio.supabase.co/rest/v1/users` |
| Create user | POST | `https://ycswtvovrdkbfchjjaio.supabase.co/rest/v1/users` |
| Get enrollments | GET | `https://ycswtvovrdkbfchjjaio.supabase.co/rest/v1/program_enrollments` |
| Get pain trends | GET | `https://ycswtvovrdkbfchjjaio.supabase.co/rest/v1/v_pain_score_trend` |
| Get summary | GET | `https://ycswtvovrdkbfchjjaio.supabase.co/rest/v1/v_program_summary` |
| Get user profiles | GET | `https://ycswtvovrdkbfchjjaio.supabase.co/rest/v1/v_user_profiles` |
| Get lifecycle funnel | GET | `https://ycswtvovrdkbfchjjaio.supabase.co/rest/v1/v_lifecycle_funnel` |
| Get daily progress | GET | `https://ycswtvovrdkbfchjjaio.supabase.co/rest/v1/daily_progress` |
| Get purchases | GET | `https://ycswtvovrdkbfchjjaio.supabase.co/rest/v1/purchases` |

### n8n Webhooks
| Webhook | Method | URL |
|---------|--------|-----|
| Intake form submission | POST | `https://parag16.app.n8n.cloud/webhook/ly-intake` |
| Check-in response | POST | `https://parag16.app.n8n.cloud/webhook/lightyears-checkin` |

### Interakt API
```
POST https://api.interakt.ai/v1/public/message/
Headers:
  Authorization: Basic [INTERAKT_API_KEY]
  Content-Type: application/json
```

---

## 13. CONTEXT FOR AI ASSISTANTS

If you are an AI assistant picking up this project:

1. **The user (Parag) is non-technical.** Explain things in plain language. Avoid jargon unless you also explain it.
2. **This is a demo/MVP.** Don't over-engineer. Focus on making things work and look good for the boss demo.
3. **The n8n instance has many other workflows.** Only touch workflows prefixed with `LY -`. Leave everything else alone.
4. **n8n Cloud MCP** is available at `parag16.app.n8n.cloud`. Use `mcp__n8n-mcp-cloud__` tools (NOT `mcp__n8n-mcp__` which is a different self-hosted instance).
5. **Supabase MCP** in this dev environment is connected to a DIFFERENT project (SecondTheoryCapital's). Do NOT use it for LightYears. Provide SQL scripts for the user to run in the Supabase SQL editor instead.
6. **GitHub repo** is at `paavaniagrawal/lightyears-health`. Local source is at `/Users/paragagrawal/lightyears-health/`. Push to `main` for auto-deploy. Git push requires a PAT.
7. **ALL workflows are ACTIVE.** The end-to-end demo has been tested.
8. **Dashboard is a single-file SPA** with hash routing. All 8 views are in one `dashboard.html` file. No build step needed.
9. **Use `$vars.` not `$env.`** for all n8n environment variable references.
10. **Dashboard uses `db` not `supabase`** as the Supabase client variable name.
11. **5 WhatsApp templates** are registered — see the Interakt section for the full table with header types and headerValues. Critical: IMAGE headers need image URLs, TEXT headers need text values, sending the wrong type causes silent delivery failure.
12. **Team members for escalation assignment:** Abha, Dr. Devashree (hardcoded in dashboard.html).
13. **Single product:** "Knee Recovery Bundle" at Rs 3,500 (in `purchases` table).
14. **10 n8n workflows** (6 original + 4 new scheduled message workflows). All ACTIVE. IDs listed in Section 4.
15. **Biweekly check-in filter** is temporarily set to include week 1 for testing. Revert before production.
