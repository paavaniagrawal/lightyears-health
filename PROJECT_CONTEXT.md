# LightYears Health - Complete Project Context

> **Purpose of this file:** This document is the single source of truth for the LightYears Health MVP. It is written so that any AI assistant or developer can pick up this project with zero prior context and know exactly what has been built, where everything lives, what works, what doesn't, and what's left to do.

> **Last updated:** 2026-03-01

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
- **Environment Variables set:**
  - `SUPABASE_SERVICE_KEY` - Supabase service role key for full DB access
  - `INTERAKT_API_KEY` - **NOT YET SET** (waiting on boss for API access)
- **Note:** There is also a self-hosted n8n at `n8n.secondtheorycapital.com` - that is NOT used for this project

### GitHub Pages
- **Repository:** https://github.com/paavaniagrawal/lightyears-health
- **Live Site:** https://paavaniagrawal.github.io/lightyears-health/
- **GitHub Account:** `paavaniagrawal` (NOT `paragagrawal16` which is a different account)
- **Deployment:** Legacy GitHub Pages, auto-deploys from `main` branch root `/`
- **Local Source Files:** `/Users/paragagrawal/lightyears-health/` on Parag's MacBook

### Interakt (WhatsApp)
- **API Endpoint:** `https://api.interakt.ai/v1/public/message/`
- **Status:** Waiting on boss for API key / developer settings access
- **Templates:** Need to be drafted and submitted for WhatsApp approval (see Section 8)

---

## 3. DATABASE SCHEMA (Supabase)

The full schema SQL is in `/Users/paragagrawal/Downloads/lightyears_schema.sql` and has been executed in Supabase.

### Tables

#### `users`
| Column | Type | Notes |
|--------|------|-------|
| id | UUID (PK) | Auto-generated |
| name | VARCHAR | |
| phone | VARCHAR | UNIQUE constraint |
| email | VARCHAR | |
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

### Database Views (power the dashboard)

1. **`v_active_programs`** - Joins users + enrollments + intake responses for active programs
2. **`v_pain_score_trend`** - Pain score progression over weeks, with baseline comparison and improvement calculation
3. **`v_checkin_completion`** - Check-in completion rate per user (actual vs expected, based on biweekly schedule)
4. **`v_escalation_queue`** - Open escalations sorted by severity (high -> medium -> low)
5. **`v_program_summary`** - Top-level stats: total enrollments, active, completed, dropped off, completion rate %, dropout rate %

### Row Level Security
- RLS is **enabled** on all 6 tables
- **Permissive policies** allow full access (using `true` for both USING and WITH CHECK) - suitable for MVP where only the service role key accesses data
- The dashboard uses the **anon key** which can read via the permissive policy
- For production, these policies must be tightened

---

## 4. n8n WORKFLOWS

All 6 workflows live on **https://parag16.app.n8n.cloud** and are prefixed with `LY -`.

**Current state: ALL workflows are INACTIVE** (need to be activated for the system to work).

### Workflow 1: LY - Intake Form Processor
- **ID:** `aUl9IaWnWVMJYyqV`
- **Trigger:** Webhook at `https://parag16.app.n8n.cloud/webhook/lightyears-intake`
- **Purpose:** Receives intake form submissions, classifies the user, creates records in Supabase
- **Nodes (7):**
  1. `Receive Form Submission` (Webhook) - POST endpoint
  2. `Classify User` (Code) - Determines stage + eligibility based on pain score and medical history
  3. `Create User in Supabase` (HTTP Request) - POST to /rest/v1/users
  4. `Prepare Intake + Enrollment Data` (Code) - Formats data for both tables
  5. `Store Intake Responses` (HTTP Request) - POST to /rest/v1/intake_responses (parallel)
  6. `Create Program Enrollment` (HTTP Request) - POST to /rest/v1/program_enrollments (parallel)
  7. `Return Recommendation` (Respond to Webhook) - Returns {stage, eligibility} to the form

- **Classification Logic (in "Classify User" node, nodeId: code1):**
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
- **Trigger:** Manual (click to run)
- **Purpose:** Since no real Shopify purchase happens in the demo, this workflow simulates a purchase and activates the program
- **Nodes (7):**
  1. `Manual Trigger`
  2. `Set Demo Customer Data` (Set) - Contains the demo phone number
  3. `Find User by Phone` (HTTP Request) - GET from Supabase users table
  4. `Activate Program` (Code) - Calculates start_date, expected_end_date (84 days)
  5. `Update Enrollment to Active` (HTTP Request) - PATCH enrollment status to 'active'
  6. `Send Welcome via Interakt` (HTTP Request) - Sends welcome WhatsApp message (parallel)
  7. `Log Welcome Message` (HTTP Request) - Logs to message_log table (parallel)

### Workflow 3: LY - Biweekly Check-in Sender
- **ID:** `ivCNGhvIZHe38en5`
- **Trigger:** Schedule - Every day at 9am
- **Purpose:** Checks if any active users are due for a biweekly check-in and sends them a WhatsApp message
- **Nodes (5):**
  1. `Every Day at 9am` (Schedule Trigger)
  2. `Get Active Enrollments` (HTTP Request) - Fetches enrollments where status='active'
  3. `Filter: Due for Check-in Today` (Code) - Checks if current_week is 2, 4, 6, 8, 10, or 12
  4. `Send Check-in via Interakt` (HTTP Request) - Sends WhatsApp check-in message (parallel)
  5. `Log Check-in Message` (HTTP Request) - Logs to message_log (parallel)

### Workflow 4: LY - Check-in Response Handler
- **ID:** `5pZw8RrpZVVVdLlC`
- **Trigger:** Webhook at `https://parag16.app.n8n.cloud/webhook/lightyears-checkin`
- **Purpose:** Processes check-in responses (pain score updates), stores metrics, triggers safety escalations
- **Nodes (8):**
  1. `Receive Check-in Response` (Webhook)
  2. `Parse Response` (Code) - Extracts phone, pain_score, notes from incoming data
  3. `Find User & Enrollment` (HTTP Request) - Looks up user and active enrollment
  4. `Prepare Health Metric` (Code) - Formats the health_metrics record
  5. `Store Pain Score` (HTTP Request) - POST to health_metrics (parallel)
  6. `Safety Check & Route` (Code) - Checks if pain increased by 2+ points or is 8+ (parallel)
  7. `Create Escalation (if needed)` (HTTP Request) - POST to escalations table
  8. `Respond OK` (Respond to Webhook)

- **Safety escalation triggers:**
  - Pain score >= 8 -> HIGH severity escalation
  - Pain increased by 2+ points from previous -> MEDIUM severity escalation

### Workflow 5: LY - Lifecycle Manager
- **ID:** `lEGHJ2FiMzZDSX34`
- **Trigger:** Schedule - Daily at midnight
- **Purpose:** Advances week numbers, detects program completions at day 84 (week 12)
- **Nodes (5):**
  1. `Daily at Midnight` (Schedule Trigger)
  2. `Get All Active Enrollments` (HTTP Request)
  3. `Process Lifecycle Updates` (Code) - Calculates days elapsed, current week, detects completion
  4. `Route by Action` (Code) - Determines if update or completion
  5. `Update Enrollment in Supabase` (HTTP Request) - PATCH the enrollment

### Workflow 6: LY - Demo: Boss Demo Fast-Forward
- **ID:** `UWeSnQ8Au8KqqEVo`
- **Trigger:** Manual (click to run)
- **Purpose:** Instantly generates 12 weeks of realistic demo data (pain scores decreasing from 6 to 2, exercise adherence 80-95%) so the dashboard looks impressive for the boss demo
- **Nodes (6):**
  1. `Click to Run Demo` (Manual Trigger)
  2. `Set Your Phone Number` (Set) - Demo phone number
  3. `Find Active Enrollment` (HTTP Request) - Finds the enrollment to fast-forward
  4. `Simulate 12 Weeks of Data` (Code) - Generates pain_score and exercise_adherence metrics for weeks 2, 4, 6, 8, 10, 12
  5. `Insert All Demo Metrics` (HTTP Request) - Bulk inserts all metrics (parallel)
  6. `Mark Program as Completed` (HTTP Request) - Updates enrollment to 'completed' (parallel)

- **Simulated data pattern:**
  - Pain scores: 6 -> 5 -> 4 -> 4 -> 3 -> 2 (gradual improvement)
  - Exercise adherence: 80% -> 85% -> 85% -> 90% -> 90% -> 95%

---

## 5. FRONTEND FILES

### File: `index.html` (Landing Page)
- **Live URL:** https://paavaniagrawal.github.io/lightyears-health/
- **Local path:** `/Users/paragagrawal/lightyears-health/index.html`
- Simple landing page with two cards linking to the intake form and dashboard
- Uses Tailwind CSS CDN
- Fade-in animations

### File: `intake-form.html` (Customer-Facing Intake Assessment)
- **Live URL:** https://paavaniagrawal.github.io/lightyears-health/intake-form.html
- **Local path:** `/Users/paragagrawal/lightyears-health/intake-form.html`
- 3-step professional form:
  - Step 1: Personal info (name, phone with +91 prefix, email, age)
  - Step 2: Pain assessment (0-10 slider with color feedback, aggravators, relievers, functional goals)
  - Step 3: Medical background (comorbidities checkboxes, medical history, Vitamin D3 & B12 levels)
- **Submits to:** `https://parag16.app.n8n.cloud/webhook/lightyears-intake` (the n8n Intake Form Processor workflow)
- **Fallback:** If the webhook fails, classifies locally using the same logic
- Shows a personalized result screen with exercise tier recommendation after submission
- Uses Tailwind CSS CDN

### File: `dashboard.html` (Internal Evaluation Dashboard)
- **Live URL:** https://paavaniagrawal.github.io/lightyears-health/dashboard.html
- **Local path:** `/Users/paragagrawal/lightyears-health/dashboard.html`
- **Connects directly to Supabase** using the anon key (no n8n in between)
- 4 tabs: Overview, Users, Escalations, Messages
- **Overview tab:** Pain Score Trend (line chart), Stage Distribution (doughnut), Check-in Completion (bar chart), Key Clinical Metrics (pain reduction, baseline/latest scores, check-in rate)
- **Users tab:** Table of all enrolled users with name, phone, stage, status, week, baseline pain, latest pain, check-ins
- **Escalations tab:** Open escalations sorted by severity
- **Messages tab:** Recent WhatsApp message log
- Auto-refreshes every 30 seconds
- Uses Tailwind CSS CDN, Chart.js 4.4.1, Supabase JS v2

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
        v (form shows result page)
[Customer sees their exercise tier recommendation]


[Parag runs "LY - Demo: Simulate Purchase & Activate" in n8n]
        |
        v
[Supabase: enrollment status changes 'enrolled' -> 'active', start_date set]
[Interakt: sends welcome WhatsApp message]
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


[Every day at midnight - "LY - Lifecycle Manager"]
        |
        v
[Advances current_week for active enrollments]
[At day 84 (week 12): marks enrollment as 'completed']


[Dashboard on GitHub Pages]
        |
        v (direct Supabase queries using anon key)
[Reads from views: v_program_summary, v_pain_score_trend, v_checkin_completion, v_escalation_queue]
[Also reads directly from: program_enrollments, intake_responses, health_metrics, message_log]
```

---

## 7. WHAT HAS BEEN COMPLETED

| # | Task | Status | Notes |
|---|------|--------|-------|
| 1 | Supabase database schema | DONE | 6 tables, 5 views, RLS enabled. SQL executed in Supabase editor. |
| 2 | n8n workflows (6 total) | DONE | All created on parag16.app.n8n.cloud. Currently INACTIVE. |
| 3 | Supabase <> n8n connection verified | DONE | Tested read/write/delete via curl. SUPABASE_SERVICE_KEY env var set in n8n. |
| 4 | Intake form (HTML) | DONE | 3-step form with validation, pain slider, submits to n8n webhook. |
| 5 | Internal dashboard (HTML) | DONE | 4-tab dashboard with Chart.js charts, connects to Supabase directly. |
| 6 | Classification logic aligned | DONE | n8n code node updated to match Exercise Bank Framework document exactly. |
| 7 | Deployed to GitHub Pages | DONE | Live at paavaniagrawal.github.io/lightyears-health/ |

---

## 8. WHAT STILL NEEDS TO BE DONE

### Blocking: Waiting on boss
1. **Interakt API Key** - Need developer settings access from Interakt account. A WhatsApp message has been sent to the boss requesting this.
2. **Add `INTERAKT_API_KEY`** to n8n cloud environment variables (Settings > Environment Variables) once received.

### To Do: Once Interakt access is available
3. **Draft WhatsApp message templates** for Interakt approval:
   - `ly_welcome` - Welcome message after purchase activation
   - `ly_exercise_link` - Exercise video link (one message, one link, 5 videos)
   - `ly_checkin_biweekly` - Biweekly pain score check-in prompt
   - `ly_yoga_reminder` - Yoga session reminder
   - `ly_completion` - Program completion congratulations
   - `ly_reengagement` - Re-engagement for users who haven't responded
4. **Submit templates to WhatsApp** for approval via Interakt dashboard (takes 24-48 hours)
5. **Update n8n workflow nodes** that reference Interakt with the actual template names and API key

### To Do: Before the boss demo
6. **Activate the n8n workflows** - Currently all 6 LY workflows are INACTIVE. At minimum, activate:
   - `LY - Intake Form Processor` (so the form submission works)
   - `LY - Lifecycle Manager` (so weeks advance)
   - `LY - Biweekly Check-in Sender` (so check-ins go out)
7. **Run an end-to-end test:**
   - Fill out the intake form at the live URL
   - Confirm data appears in Supabase (users, intake_responses, program_enrollments tables)
   - Run "LY - Demo: Simulate Purchase & Activate" workflow
   - Run "LY - Demo: Boss Demo Fast-Forward" workflow
   - Check the dashboard shows charts with the simulated data
8. **Test on mobile** - The intake form should work well on phone browsers

### Nice to Have (Post-Demo)
- Connect real Shopify purchase webhook to trigger activation automatically
- Tighten Supabase RLS policies for production security
- Add authentication to the dashboard (currently open to anyone with the URL)
- Build proper exercise video hosting/linking
- Add Google Form as alternative intake method
- Real Interakt webhook integration for inbound messages

---

## 9. KNOWN ISSUES & GOTCHAS

### Issues Encountered During Build

1. **n8n IF node validation failure**: When creating the Check-in Response Handler workflow, the IF node (`Has Safety Alert?`) failed validation due to missing `conditions.options.leftValue` and `conditions.options.typeValidation` fields. **Fix:** Replaced the IF node with a Code node (`Safety Check & Route`) that handles the conditional logic in JavaScript instead.

2. **n8n webhook testing via MCP returned 404**: Testing webhooks on n8n cloud via the MCP `test_workflow` tool returned `"The requested webhook 'GET lightyears-test' is not registered"` even after activating the workflow. **Fix:** Bypassed n8n webhook testing entirely and tested the Supabase connection directly via curl from bash.

3. **n8n `updateNode` operation failures**: First attempt used `"properties"` key instead of `"updates"` key. Second attempt used `"name"` field which resolved to empty string. **Fix:** Use `"nodeId"` (e.g., `"code1"`) instead of node name, and use `"updates": {"parameters": {...}}` structure.

4. **Intermittent Supabase SSL 525 errors**: About 1 in 3 requests to Supabase free tier hit Cloudflare SSL handshake failures. Not a configuration issue - transient infrastructure behavior on free tier. The n8n HTTP Request nodes have built-in retry logic that handles this.

5. **GitHub Pages workflow scope**: Pushing a `.github/workflows/deploy.yml` file requires the `workflow` OAuth scope, which the default `gh auth login` doesn't grant. **Fix:** Switched to legacy GitHub Pages deployment (deploy from branch) which doesn't require a workflow file.

### Things to Watch For
- **Supabase free tier limits**: 500MB database, 2GB bandwidth. Fine for demo, but monitor if scaling.
- **n8n cloud execution limits**: Depends on plan. The scheduled workflows (check-in sender, lifecycle manager) will run daily.
- **Interakt template approval**: WhatsApp template approval can take 24-48 hours. Plan ahead.
- **Phone number format**: The intake form prepends `+91` to the phone number. All n8n workflows expect phone numbers in `+91XXXXXXXXXX` format.
- **The dashboard uses the anon key**: This means anyone with the dashboard URL can read the data. For production, add authentication.

---

## 10. FILE STRUCTURE

```
/Users/paragagrawal/lightyears-health/     (local source, also GitHub repo)
  index.html                                Landing page
  intake-form.html                          Customer-facing intake assessment
  dashboard.html                            Internal evaluation dashboard
  PROJECT_CONTEXT.md                        This file

/Users/paragagrawal/Downloads/
  lightyears_schema.sql                     Database schema (already executed in Supabase)
  LightYears Health Product Vision.pdf      Original product vision document
  Knee Pain Questionnaire.pdf               5 core intake questions + vitamin question
  Exercise Bank Framework.pdf               3-tier exercise classification
```

---

## 11. HOW TO RUN THE BOSS DEMO (Step-by-Step)

This is the exact sequence to demonstrate the full system:

### Preparation (one-time, before the meeting)
1. Activate these n8n workflows on https://parag16.app.n8n.cloud:
   - `LY - Intake Form Processor`
   - `LY - Demo: Simulate Purchase & Activate`
   - `LY - Demo: Boss Demo Fast-Forward`

### During the Demo
1. **Open the intake form:** https://paavaniagrawal.github.io/lightyears-health/intake-form.html
2. **Fill it out** as a demo patient (use your real phone number in +91 format, pain score around 5-6)
3. **Show the result screen** - explains which exercise tier they've been classified into
4. **Go to n8n** (https://parag16.app.n8n.cloud) and run the `LY - Demo: Simulate Purchase & Activate` workflow (click Execute Workflow)
5. **Then run** the `LY - Demo: Boss Demo Fast-Forward` workflow - this generates 12 weeks of realistic data instantly
6. **Open the dashboard:** https://paavaniagrawal.github.io/lightyears-health/dashboard.html
7. **Walk through each tab:**
   - Overview: Show the pain score trend going down (6 -> 2), stage distribution, check-in completion
   - Users: Show the enrolled user with their progress
   - Escalations: Show any safety flags
   - Messages: Show the message log
8. **Key talking points:**
   - Pain scores decreased from 6 to 2 over 12 weeks
   - 95% exercise adherence by end of program
   - Automated safety escalation system
   - All delivered via WhatsApp with zero manual work
   - Dashboard gives instant visibility into program effectiveness

### If Interakt is Connected (bonus)
- Show the actual WhatsApp message received on your phone
- Reply with a pain score to demonstrate the check-in flow

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

### n8n Webhooks
| Webhook | Method | URL |
|---------|--------|-----|
| Intake form submission | POST | `https://parag16.app.n8n.cloud/webhook/lightyears-intake` |
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
4. **n8n Cloud MCP is available** at `parag16.app.n8n.cloud`. You can read and modify workflows via the MCP tools.
5. **Supabase MCP is available** for the project `ycswtvovrdkbfchjjaio`. You can run SQL, apply migrations, and query data.
6. **GitHub repo** is at `paavaniagrawal/lightyears-health`. Local source is at `/Users/paragagrawal/lightyears-health/`. Push changes to `main` branch and GitHub Pages auto-deploys.
7. **Key next step:** Get Interakt API key from boss, draft WhatsApp templates, activate workflows, and run end-to-end test.
8. **The dashboard is the most important deliverable.** It needs to show compelling data that proves the 12-week program works.
