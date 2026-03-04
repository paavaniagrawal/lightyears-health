# LightYears Health - Complete Project Context

> **Purpose of this file:** This document is the single source of truth for the LightYears Health MVP. It is written so that any AI assistant or developer can pick up this project with zero prior context and know exactly what has been built, where everything lives, what works, what doesn't, and what's left to do.

> **Last updated:** 2026-03-04

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
  - `SUPABASE_SERVICE_KEY` - Supabase service role key for full DB access ✅
  - `INTERAKT_API_KEY` - Interakt API key (base64 encoded for Basic auth) ✅ **NOW SET**
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
- **Active Template:** `wa_superusers_250925` — this template has an **image header component**
  - When calling this template, you MUST include `"headerValues": ["<image_url>"]` in the payload
  - Omitting `headerValues` or passing an empty array causes Interakt to return 400: "Media Url is missing for header's image"
  - Current placeholder image URL used: `https://www.buildquickbots.com/whatsapp/media/sample/jpg/sample01.jpg`
- **Demo phone number in WF2 & WF6:** `+919167006051`

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
- **As of 2026-03-04:** Explicit anon read policies have been added to all 6 tables so the dashboard (which uses the anon key) can read data:
  ```sql
  CREATE POLICY "anon_read" ON users FOR SELECT TO anon USING (true);
  CREATE POLICY "anon_read" ON program_enrollments FOR SELECT TO anon USING (true);
  CREATE POLICY "anon_read" ON health_metrics FOR SELECT TO anon USING (true);
  CREATE POLICY "anon_read" ON message_log FOR SELECT TO anon USING (true);
  CREATE POLICY "anon_read" ON escalations FOR SELECT TO anon USING (true);
  CREATE POLICY "anon_read" ON intake_responses FOR SELECT TO anon USING (true);
  ```
- n8n workflows use the `SUPABASE_SERVICE_KEY` which bypasses RLS entirely
- For production, tighten these policies

---

## 4. n8n WORKFLOWS

All 6 workflows live on **https://parag16.app.n8n.cloud** and are prefixed with `LY -`.

**Current state (as of 2026-03-04): ALL 6 workflows are ACTIVE** ✅

**Critical: ALL `$env.` references have been replaced with `$vars.`** across all 16 nodes in all 6 workflows. n8n Cloud does not allow `$env` — use `$vars.VARIABLE_NAME` for any n8n environment variable.

### Workflow 1: LY - Intake Form Processor
- **ID:** `aUl9IaWnWVMJYyqV`
- **Status:** ACTIVE ✅
- **Trigger:** Webhook at `https://parag16.app.n8n.cloud/webhook/ly-intake`
  - ⚠️ **Path changed from `lightyears-intake` to `ly-intake`** — the old path was stuck in a broken registration state. The intake-form.html has been updated to match.
- **Purpose:** Receives intake form submissions, classifies the user, creates records in Supabase
- **Nodes (6):** *(Note: was 7 nodes — "Return Recommendation" Respond to Webhook node was removed)*
  1. `Receive Form Submission` (Webhook) - POST endpoint, `responseMode: onReceived` (responds immediately with 200, no respondToWebhook node needed)
  2. `Classify User` (Code) - Determines stage + eligibility based on pain score and medical history
  3. `Create User in Supabase` (HTTP Request) - POST to /rest/v1/users
  4. `Prepare Intake + Enrollment Data` (Code) - Formats data for both tables
  5. `Store Intake Responses` (HTTP Request) - POST to /rest/v1/intake_responses (parallel)
  6. `Create Program Enrollment` (HTTP Request) - POST to /rest/v1/program_enrollments (parallel)

- **Key webhook node settings (critical for registration to work):**
  - `typeVersion: 2.1`
  - `responseMode: "onReceived"` (inside parameters)
  - `path: "ly-intake"` (inside parameters)
  - `webhookId: "e90b67b9-3b60-4c6d-b3fc-07c68b364663"` (top-level node field — required!)
  - `onError: "continueRegularOutput"` (top-level node field — required!)

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
- **Status:** ACTIVE ✅
- **Trigger:** Manual (click to run)
- **Purpose:** Since no real Shopify purchase happens in the demo, this workflow simulates a purchase and activates the program
- **Demo phone number set in "Set Demo Customer Data" node:** `+919167006051`
- **Nodes (7):**
  1. `Manual Trigger`
  2. `Set Demo Customer Data` (Set) - Contains the demo phone number
  3. `Find User by Phone` (HTTP Request) - GET from Supabase users table
  4. `Activate Program` (Code) - Calculates start_date, expected_end_date (84 days)
  5. `Update Enrollment to Active` (HTTP Request) - PATCH enrollment status to 'active' by `user_id` only (no status filter — important for re-runnability)
  6. `Send Welcome via Interakt` (HTTP Request) - Sends welcome WhatsApp using template `wa_superusers_250925` (parallel)
  7. `Log Welcome Message` (HTTP Request) - Logs to message_log table (parallel)

- **Critical Interakt payload in "Send Welcome via Interakt":**
  - Template: `wa_superusers_250925` (has image header — requires `headerValues`)
  - Must include `"headerValues": ["https://www.buildquickbots.com/whatsapp/media/sample/jpg/sample01.jpg"]`
  - Uses `$vars.INTERAKT_API_KEY` for auth

- **Re-runnability note:** The `Update Enrollment to Active` PATCH URL filters by `user_id` only (not `&status=eq.enrolled`). This allows the workflow to be run multiple times without failing when enrollment is already active.

### Workflow 3: LY - Biweekly Check-in Sender
- **ID:** `ivCNGhvIZHe38en5`
- **Status:** ACTIVE ✅
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
- **Status:** ACTIVE ✅
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
- **Status:** ACTIVE ✅
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
- **Status:** ACTIVE ✅
- **Trigger:** Manual (click to run)
- **Purpose:** Instantly generates 12 weeks of realistic demo data (pain scores decreasing from 6 to 2, exercise adherence 80-95%) so the dashboard looks impressive for the boss demo
- **Demo phone number set in "Set Your Phone Number" node:** `+919167006051`
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
- **Submits to:** `https://parag16.app.n8n.cloud/webhook/ly-intake` *(updated from `lightyears-intake` on 2026-03-04)*
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
- **IMPORTANT code note:** The Supabase client is named `db` (not `supabase`) to avoid naming conflict with the UMD global `window.supabase`:
  ```javascript
  const db = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
  // All queries use db.from(...) — NOT supabase.from(...)
  ```

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
| 2 | n8n workflows (6 total) | DONE | All created and ACTIVE on parag16.app.n8n.cloud. |
| 3 | Supabase <> n8n connection verified | DONE | Tested read/write/delete via curl. SUPABASE_SERVICE_KEY env var set in n8n. |
| 4 | Intake form (HTML) | DONE | 3-step form with validation, pain slider, submits to n8n webhook. |
| 5 | Internal dashboard (HTML) | DONE | 4-tab dashboard with Chart.js charts, connects to Supabase directly. **Fully working.** |
| 6 | Classification logic aligned | DONE | n8n code node updated to match Exercise Bank Framework document exactly. |
| 7 | Deployed to GitHub Pages | DONE | Live at paavaniagrawal.github.io/lightyears-health/ |
| 8 | Fix $env -> $vars in all workflows | DONE | 16 nodes across 6 workflows updated. n8n Cloud requires $vars not $env. |
| 9 | Set INTERAKT_API_KEY in n8n | DONE | Set in n8n Cloud Settings > Variables. |
| 10 | Fix WF1 webhook registration | DONE | Changed path to ly-intake, added webhookId, removed respondToWebhook node, set responseMode:onReceived. |
| 11 | Fix WF2 Interakt image header | DONE | Added headerValues with placeholder image URL to wa_superusers_250925 call. |
| 12 | Fix WF2 re-runnability | DONE | Removed &status=eq.enrolled filter from Update Enrollment PATCH URL. |
| 13 | Add Supabase anon RLS policies | DONE | All 6 tables now have explicit anon SELECT policies so dashboard can read data. |
| 14 | Fix dashboard JS naming conflict | DONE | Renamed const supabase -> const db to avoid conflict with window.supabase UMD global. |
| 15 | Activate all 6 workflows | DONE | All workflows ACTIVE as of 2026-03-04. |
| 16 | End-to-end demo test | DONE ✅ | Full flow tested: intake form -> Supabase -> WF2 -> WhatsApp received -> WF6 -> dashboard shows data. |

---

## 8. WHAT STILL NEEDS TO BE DONE

### For a Polished Demo
1. **Replace placeholder image in WF2** - The welcome WhatsApp message uses `wa_superusers_250925` template with a placeholder sample image. Before the boss demo, replace the `headerValues` image URL with an actual LightYears Health branded image.
2. **Test on mobile** - The intake form should work well on phone browsers.
3. **Clear demo data before the boss demo** - The Supabase database currently has test data from the end-to-end test run. Before the real demo, truncate or delete test records so the demo starts fresh.

### Nice to Have (Post-Demo)
- Connect real Shopify purchase webhook to trigger activation automatically
- Tighten Supabase RLS policies for production security
- Add authentication to the dashboard (currently open to anyone with the URL)
- Build proper exercise video hosting/linking
- Add Google Form as alternative intake method
- Real Interakt webhook integration for inbound messages (for check-in responses)
- Draft and register proper WhatsApp templates (ly_welcome, ly_checkin_biweekly, etc.) — currently using a generic template `wa_superusers_250925`

---

## 9. KNOWN ISSUES & GOTCHAS

### Critical Things to Know

1. **n8n Cloud: `$vars` not `$env`**: All environment variables in n8n Cloud expressions must use `$vars.VARIABLE_NAME`. Using `$env.VARIABLE_NAME` causes a "blocked for security reasons" error. This was fixed across all 16 nodes in the 6 workflows on 2026-03-04.

2. **n8n webhook registration quirks (IMPORTANT):**
   - A webhook node needs a `webhookId` UUID field at the top level of the node object (not inside parameters). Without it, the webhook may show as registered but return 404 at runtime.
   - `onError: "continueRegularOutput"` must also be a top-level node property, NOT inside `parameters.options`.
   - If a webhook path gets stuck in a broken state (returns 404 despite workflow being active), changing the path AND adding a `webhookId` fixes it.
   - WF1's path was changed from `lightyears-intake` to `ly-intake` for this reason.

3. **n8n `responseMode: responseNode` + two parallel branches = HTTP 500**: If a webhook uses `responseMode: "responseNode"` (requires a Respond to Webhook node) AND has two parallel output branches, n8n throws "Unused Respond to Webhook node found". Fix: switch to `responseMode: "onReceived"` and remove the Respond to Webhook node entirely.

4. **Interakt template `wa_superusers_250925` has image header**: The API call must include `"headerValues": ["<image_url>"]`. An empty array or missing field causes 400 error. Currently using a placeholder image URL.

5. **Supabase RLS with anon key**: Even with RLS enabled and "permissive" policies, the anon key cannot read data unless there is an explicit `FOR SELECT TO anon USING (true)` policy. Added these to all 6 tables on 2026-03-04. The dashboard only reads (SELECT) — writes go through n8n using the service key.

6. **dashboard.html uses `db` not `supabase`**: The Supabase UMD JS bundle sets `window.supabase` as a global. Declaring `const supabase = window.supabase.createClient(...)` causes `SyntaxError: Identifier 'supabase' has already been declared` which crashes the entire script silently. The fix is to use `const db = window.supabase.createClient(...)` and reference `db.from(...)` everywhere.

7. **WF2 Update Enrollment PATCH — no status filter**: The PATCH URL must NOT filter by `&status=eq.enrolled`. If you filter by enrolled status and the enrollment is already active (from a previous run), the PATCH matches 0 rows and the workflow stops before reaching Interakt. The URL should only filter by `user_id`.

### Issues Encountered During Build (Historical)

8. **n8n IF node validation failure**: When creating the Check-in Response Handler workflow, the IF node failed validation. Fix: replaced with a Code node (`Safety Check & Route`) that handles conditional logic in JavaScript.

9. **n8n `updateNode` MCP operation**: Must use `"nodeId"` (e.g., `"webhook1"`) not node name, and `"updates": {...}` wrapper object.

10. **Intermittent Supabase SSL 525 errors**: About 1 in 3 requests to Supabase free tier hit Cloudflare SSL handshake failures. Transient — n8n retries handle this.

11. **GitHub Pages workflow scope**: Pushing a `.github/workflows/deploy.yml` file requires the `workflow` OAuth scope. Switched to legacy GitHub Pages deployment (deploy from branch root) which doesn't need a workflow file.

12. **Git push requires PAT**: Cannot push to GitHub with account password. Must use a Personal Access Token (PAT) from GitHub Settings > Developer Settings > Personal Access Tokens. Run: `git config --global credential.helper osxkeychain` and use the PAT as password when prompted.

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
  PROJECT_CONTEXT.md                        Copy of this file (may be slightly behind repo version)
```

---

## 11. HOW TO RUN THE BOSS DEMO (Step-by-Step)

This is the exact sequence to demonstrate the full system:

### Before the Demo: Reset Demo Data
1. Go to Supabase SQL editor: https://supabase.com/dashboard/project/ycswtvovrdkbfchjjaio/sql
2. Run the following to clear all test data (so the demo starts fresh):
   ```sql
   DELETE FROM health_metrics;
   DELETE FROM message_log;
   DELETE FROM escalations;
   DELETE FROM program_enrollments;
   DELETE FROM intake_responses;
   DELETE FROM users;
   ```
3. Confirm all 6 workflows are ACTIVE at https://parag16.app.n8n.cloud (they should all be active already)

### During the Demo
1. **Open the intake form:** https://paavaniagrawal.github.io/lightyears-health/intake-form.html
2. **Fill it out** as a demo patient:
   - Use phone: `9167006051` (the form prepends +91 automatically)
   - Pain score: 5 or 6 (puts you in Recovery tier)
   - Fill other fields naturally
3. **Show the result screen** - explains which exercise tier they've been classified into
4. **Go to n8n** (https://parag16.app.n8n.cloud) and run the `LY - Demo: Simulate Purchase & Activate` workflow (click Execute Workflow)
   - This activates the enrollment and sends a WhatsApp message to +919167006051
   - Show the WhatsApp message arriving on your phone
5. **Then run** the `LY - Demo: Boss Demo Fast-Forward` workflow
   - This generates 12 weeks of realistic data instantly (pain scores 6->2, adherence 80-95%)
6. **Open the dashboard:** https://paavaniagrawal.github.io/lightyears-health/dashboard.html
7. **Walk through each tab:**
   - **Overview:** Show the pain score trend going down (6 -> 2), stage distribution, check-in completion rate
   - **Users:** Show the enrolled user with their progress (baseline vs latest pain, check-ins completed)
   - **Escalations:** Explain the automated safety system
   - **Messages:** Show the message log proving WhatsApp delivery
8. **Key talking points:**
   - Pain scores decreased from 6 to 2 over 12 weeks — that's a 67% reduction
   - 95% exercise adherence by end of program
   - Automated safety escalation — if pain worsens, we flag it immediately
   - All delivered via WhatsApp with zero manual work after setup
   - Dashboard gives instant visibility into whether the protocol is working

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
4. **n8n Cloud MCP is available** at `parag16.app.n8n.cloud`. You can read and modify workflows via the MCP tools.
5. **Supabase MCP is available** for the project `ycswtvovrdkbfchjjaio`. You can run SQL, apply migrations, and query data.
6. **GitHub repo** is at `paavaniagrawal/lightyears-health`. Local source is at `/Users/paragagrawal/lightyears-health/`. Push changes to `main` branch and GitHub Pages auto-deploys. Git push requires a PAT (not account password).
7. **ALL workflows are ACTIVE and working as of 2026-03-04.** The end-to-end demo has been successfully tested.
8. **The demo has been tested successfully:** Intake form -> n8n WF1 -> Supabase data created -> WF2 ran -> enrollment activated -> WhatsApp message received on phone -> WF6 ran -> 12 weeks of metrics inserted -> dashboard shows charts and data. Everything works end to end.
9. **The main remaining prep for the boss demo:** Clear the test data in Supabase (SQL above), then run a fresh demo. Optionally replace the placeholder image in the WF2 Interakt call with a branded LightYears image.
10. **Use `$vars.` not `$env.`** for all n8n environment variable references.
11. **Dashboard uses `db` not `supabase`** as the Supabase client variable name — this is intentional to avoid a naming conflict with the Supabase UMD global.
12. **Interakt template `wa_superusers_250925`** requires `headerValues` array with an image URL (image header template). Without it, the API returns 400.
