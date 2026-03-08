-- ============================================
-- LightYears Health CRM - Database Migrations
-- Run this ENTIRE script in Supabase SQL Editor
-- https://supabase.com/dashboard/project/ycswtvovrdkbfchjjaio/sql
-- ============================================

-- ============================================
-- MIGRATION 1: Add new columns to existing tables
-- ============================================
ALTER TABLE users ADD COLUMN IF NOT EXISTS city VARCHAR;
ALTER TABLE users ADD COLUMN IF NOT EXISTS gender VARCHAR;

ALTER TABLE intake_responses ADD COLUMN IF NOT EXISTS pain_duration VARCHAR;
ALTER TABLE intake_responses ADD COLUMN IF NOT EXISTS functional_level VARCHAR;

-- ============================================
-- MIGRATION 2: Create daily_progress table
-- ============================================
CREATE TABLE IF NOT EXISTS daily_progress (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  enrollment_id UUID REFERENCES program_enrollments(id) ON DELETE CASCADE,
  day_number INTEGER NOT NULL CHECK (day_number >= 1 AND day_number <= 84),
  activity_type VARCHAR NOT NULL DEFAULT 'exercise',
  status VARCHAR NOT NULL DEFAULT 'completed',
  completed_at TIMESTAMPTZ,
  notes TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE daily_progress ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Service role full access" ON daily_progress FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "anon_read" ON daily_progress FOR SELECT TO anon USING (true);

-- ============================================
-- MIGRATION 3: Create purchases table
-- ============================================
CREATE TABLE IF NOT EXISTS purchases (
  id UUID DEFAULT uuid_generate_v4() PRIMARY KEY,
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  order_id VARCHAR,
  product_name VARCHAR NOT NULL,
  product_category VARCHAR DEFAULT 'bundle',
  quantity INTEGER DEFAULT 1,
  unit_price NUMERIC NOT NULL,
  total_price NUMERIC NOT NULL,
  currency VARCHAR DEFAULT 'INR',
  status VARCHAR DEFAULT 'completed',
  purchased_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE purchases ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Service role full access" ON purchases FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "anon_read" ON purchases FOR SELECT TO anon USING (true);

-- ============================================
-- MIGRATION 4: Drop and recreate views
-- ============================================

-- Drop existing views
DROP VIEW IF EXISTS v_program_summary;
DROP VIEW IF EXISTS v_pain_score_trend;
DROP VIEW IF EXISTS v_checkin_completion;
DROP VIEW IF EXISTS v_escalation_queue;
DROP VIEW IF EXISTS v_active_programs;

-- View: v_program_summary (enhanced with revenue)
CREATE VIEW v_program_summary AS
SELECT
  COUNT(*) as total_enrollments,
  COUNT(*) FILTER (WHERE pe.status = 'active') as active_users,
  COUNT(*) FILTER (WHERE pe.status = 'completed') as completed_users,
  COUNT(*) FILTER (WHERE pe.status = 'dropped_off') as dropped_off_users,
  COUNT(*) FILTER (WHERE pe.status = 'enrolled') as pending_activation,
  ROUND(
    COUNT(*) FILTER (WHERE pe.status = 'dropped_off')::numeric /
    NULLIF(COUNT(*), 0)::numeric * 100, 1
  ) as dropout_rate_pct,
  ROUND(
    COUNT(*) FILTER (WHERE pe.status = 'completed')::numeric /
    NULLIF(COUNT(*), 0)::numeric * 100, 1
  ) as completion_rate_pct,
  (SELECT COALESCE(SUM(total_price), 0) FROM purchases WHERE status = 'completed') as total_revenue,
  (SELECT COUNT(DISTINCT user_id) FROM purchases WHERE status = 'completed') as paying_customers
FROM program_enrollments pe;

-- View: v_pain_score_trend
CREATE VIEW v_pain_score_trend AS
SELECT
  u.id as user_id,
  u.name,
  u.phone,
  hm.week_number,
  hm.value as pain_score,
  hm.recorded_at,
  pe.stage,
  pe.status,
  ir.pain_score as baseline_pain_score,
  ir.pain_score - hm.value as improvement
FROM health_metrics hm
JOIN users u ON u.id = hm.user_id
JOIN program_enrollments pe ON pe.id = hm.enrollment_id
LEFT JOIN intake_responses ir ON ir.user_id = hm.user_id
WHERE hm.metric_type = 'pain_score'
ORDER BY u.id, hm.week_number;

-- View: v_checkin_completion
CREATE VIEW v_checkin_completion AS
SELECT
  pe.id as enrollment_id,
  u.id as user_id,
  u.name,
  u.phone,
  pe.current_week,
  pe.stage,
  pe.status,
  COUNT(hm.id) as total_checkins,
  CASE
    WHEN pe.current_week >= 2 THEN FLOOR(pe.current_week / 2.0)
    ELSE 0
  END as expected_checkins,
  CASE
    WHEN FLOOR(pe.current_week / 2.0) > 0
    THEN ROUND(COUNT(hm.id)::numeric / FLOOR(pe.current_week / 2.0)::numeric * 100, 1)
    ELSE 0
  END as completion_rate_pct
FROM program_enrollments pe
JOIN users u ON u.id = pe.user_id
LEFT JOIN health_metrics hm ON hm.enrollment_id = pe.id AND hm.metric_type = 'pain_score'
GROUP BY pe.id, u.id, u.name, u.phone, pe.current_week, pe.stage, pe.status;

-- View: v_escalation_queue
CREATE VIEW v_escalation_queue AS
SELECT
  e.id as escalation_id,
  u.id as user_id,
  u.name,
  u.phone,
  e.trigger_reason,
  e.severity,
  e.status,
  e.assigned_to,
  e.resolution_notes,
  e.created_at,
  e.resolved_at,
  pe.stage,
  pe.current_week
FROM escalations e
JOIN users u ON u.id = e.user_id
LEFT JOIN program_enrollments pe ON pe.id = e.enrollment_id
WHERE e.status != 'resolved'
ORDER BY
  CASE e.severity
    WHEN 'high' THEN 1
    WHEN 'medium' THEN 2
    WHEN 'low' THEN 3
  END,
  e.created_at;

-- View: v_active_programs
CREATE VIEW v_active_programs AS
SELECT
  u.id as user_id,
  u.name,
  u.phone,
  pe.id as enrollment_id,
  pe.stage,
  pe.status,
  pe.current_week,
  pe.start_date,
  pe.expected_end_date,
  ir.pain_score as initial_pain_score,
  pe.created_at as enrolled_at
FROM program_enrollments pe
JOIN users u ON u.id = pe.user_id
LEFT JOIN intake_responses ir ON ir.user_id = pe.user_id
WHERE pe.status NOT IN ('completed', 'dropped_off');

-- New View: v_user_profiles (unified user view for profile page)
CREATE VIEW v_user_profiles AS
SELECT
  u.id as user_id,
  u.name,
  u.phone,
  u.email,
  u.city,
  u.gender,
  u.source,
  u.created_at,
  ir.age,
  ir.pain_score as intake_pain_score,
  ir.pain_location,
  ir.functional_limitations,
  ir.comorbidities,
  ir.blood_marker_d3,
  ir.blood_marker_b12,
  ir.functional_goals,
  ir.medical_history,
  ir.pain_duration,
  ir.functional_level,
  ir.submitted_at as intake_submitted_at,
  pe.id as enrollment_id,
  pe.program_type,
  pe.stage,
  pe.eligibility,
  pe.status as enrollment_status,
  pe.current_week,
  pe.start_date,
  pe.expected_end_date,
  pe.completed_at,
  pe.dropped_off_at
FROM users u
LEFT JOIN intake_responses ir ON ir.user_id = u.id
LEFT JOIN program_enrollments pe ON pe.user_id = u.id;

-- New View: v_lifecycle_funnel
CREATE VIEW v_lifecycle_funnel AS
SELECT 'leads' as stage, 1 as stage_order, COUNT(*) as count FROM users
UNION ALL
SELECT 'survey_completed', 2, COUNT(*) FROM intake_responses
UNION ALL
SELECT 'purchased', 3, COUNT(DISTINCT user_id) FROM purchases WHERE status = 'completed'
UNION ALL
SELECT 'program_active', 4, COUNT(*) FROM program_enrollments WHERE status IN ('active', 'completed')
UNION ALL
SELECT 'completed', 5, COUNT(*) FROM program_enrollments WHERE status = 'completed';

-- ============================================
-- MIGRATION 5: Anon write policies for admin actions
-- ============================================
CREATE POLICY "anon_update_escalations" ON escalations FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_update_enrollments" ON program_enrollments FOR UPDATE TO anon USING (true) WITH CHECK (true);
CREATE POLICY "anon_insert_message_log" ON message_log FOR INSERT TO anon WITH CHECK (true);

-- ============================================
-- MIGRATION 6: Dummy data for new fields & tables
-- Run this AFTER the demo data exists (after running WF6 Boss Demo Fast-Forward)
-- ============================================

-- 6a: Update existing users with city/gender
UPDATE users SET
  city = sub.city,
  gender = sub.gender
FROM (
  SELECT id,
    CASE (ROW_NUMBER() OVER (ORDER BY created_at)) % 5
      WHEN 0 THEN 'Mumbai'
      WHEN 1 THEN 'Delhi'
      WHEN 2 THEN 'Bangalore'
      WHEN 3 THEN 'Pune'
      WHEN 4 THEN 'Hyderabad'
    END as city,
    CASE (ROW_NUMBER() OVER (ORDER BY created_at)) % 3
      WHEN 0 THEN 'Male'
      WHEN 1 THEN 'Female'
      WHEN 2 THEN 'Male'
    END as gender
  FROM users
  WHERE city IS NULL
) sub
WHERE users.id = sub.id;

-- 6b: Update existing intake_responses with pain_duration/functional_level
UPDATE intake_responses SET
  pain_duration = CASE
    WHEN pain_score <= 3 THEN '1_to_3_months'
    WHEN pain_score <= 6 THEN '3_to_6_months'
    ELSE '6_to_12_months'
  END,
  functional_level = CASE
    WHEN pain_score <= 3 THEN 'mild_limitation'
    WHEN pain_score <= 6 THEN 'moderate_limitation'
    ELSE 'severe_limitation'
  END
WHERE pain_duration IS NULL;

-- 6c: Insert purchase for each active/completed user
INSERT INTO purchases (user_id, order_id, product_name, product_category, quantity, unit_price, total_price, status, purchased_at)
SELECT
  u.id,
  '#LY-' || LPAD((ROW_NUMBER() OVER (ORDER BY u.created_at))::text, 4, '0'),
  'Knee Recovery Bundle',
  'bundle',
  1,
  3500,
  3500,
  'completed',
  u.created_at + interval '1 day'
FROM users u
WHERE EXISTS (
  SELECT 1 FROM program_enrollments pe
  WHERE pe.user_id = u.id AND pe.status IN ('active', 'completed')
)
AND NOT EXISTS (
  SELECT 1 FROM purchases p WHERE p.user_id = u.id
);

-- 6d: Insert daily_progress data for each active/completed enrollment
-- This generates 84 days of realistic exercise data (~85% completion rate)
INSERT INTO daily_progress (user_id, enrollment_id, day_number, activity_type, status, completed_at)
SELECT
  pe.user_id,
  pe.id,
  day_num,
  CASE
    WHEN day_num % 7 = 0 THEN 'rest'
    WHEN day_num % 7 = 3 THEN 'yoga'
    ELSE 'exercise'
  END,
  CASE
    WHEN day_num % 7 = 0 THEN 'completed'  -- rest days always completed
    WHEN random() < 0.85 THEN 'completed'
    WHEN random() < 0.5 THEN 'partial'
    ELSE 'missed'
  END,
  CASE
    WHEN random() < 0.85 THEN pe.start_date + (day_num || ' days')::interval
    ELSE NULL
  END
FROM program_enrollments pe
CROSS JOIN generate_series(1, 84) as day_num
WHERE pe.status IN ('active', 'completed')
  AND pe.start_date IS NOT NULL
  AND NOT EXISTS (
    SELECT 1 FROM daily_progress dp
    WHERE dp.enrollment_id = pe.id AND dp.day_number = day_num
  );
