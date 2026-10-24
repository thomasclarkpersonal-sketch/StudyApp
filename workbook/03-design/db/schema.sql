-- A33 · Physical Data Design — SQLite 3 Schema (schema.sql)
-- System: Study App & Generation Pipeline
-- Engine: SQLite 3.45+ (via better-sqlite3 in Node.js 22 LTS)
-- Related ADRs: ADR-002 (Dual Persistence), ADR-003 (Constraint Backstops),
--               ADR-006 (Hosted Auth), ADR-007 (3NF & JSON Snapshot Columns)
PRAGMA application_id = 0x53544459; -- "STDY" magic header (A33 DB recognition) PRAGMA user_version = 1;
PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA synchronous = FULL;
-- R34: schema_migrations (Operational DDL migration ledger)
CREATE TABLE IF NOT EXISTS schema_migrations (
  version INTEGER PRIMARY KEY CHECK (version >= 1),
  name TEXT NOT NULL CHECK (length(trim(name)) > 0),
  checksum_sha256 TEXT NOT NULL CHECK (length(checksum_sha256) = 64),
  applied_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (applied_at GLOB '????-??-??T??:??:??*Z')
) STRICT;
-- R01: module (E01 Module)
CREATE TABLE IF NOT EXISTS module (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) BETWEEN 1 AND 64),
  code TEXT NOT NULL UNIQUE CHECK (length(trim(code)) BETWEEN 1 AND 32),
  name TEXT NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 200),
  colour TEXT DEFAULT '#2563EB' CHECK (colour IS NULL OR (length(colour) = 7 AND substr(colour, 1, 1) = '#')),
  timezone TEXT NOT NULL DEFAULT 'Asia/Hong_Kong' CHECK (length(trim(timezone)) BETWEEN 1 AND 64),
  priority_rank INTEGER NOT NULL DEFAULT 1 CHECK (priority_rank >= 1),
  is_cs INTEGER NOT NULL DEFAULT 0 CHECK (is_cs IN (0, 1)),
  exam_type TEXT NOT NULL DEFAULT 'unknown' CHECK (exam_type IN ('closed_book', 'open_book', 'take_home', 'no_final', 'unknown')),
  new_cards_per_day INTEGER NOT NULL DEFAULT 20 CHECK (new_cards_per_day >= 0 AND new_cards_per_day <= 500),
  max_reviews_per_day INTEGER NOT NULL DEFAULT 200 CHECK (max_reviews_per_day >= 1 AND max_reviews_per_day <= 2000),
  quiz_per_day INTEGER NOT NULL DEFAULT 10 CHECK (quiz_per_day >= 0 AND quiz_per_day <= 100),
  desired_retention REAL NOT NULL DEFAULT 0.90 CHECK (desired_retention >= 0.70 AND desired_retention <= 0.99),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (created_at GLOB '????-??-??T??:??:??*Z')
) STRICT;
-- R02: lecture (E02 Lecture — deterministic ID <MODULE>-<WEEK>, BR-020)
CREATE TABLE IF NOT EXISTS lecture (
  id TEXT PRIMARY KEY CHECK (id GLOB '*-W[0-9][0-9]*' AND length(id) <= 80),
  module_id TEXT NOT NULL,
  week TEXT NOT NULL CHECK (week GLOB 'W[0-9][0-9]*'),
  number INTEGER NOT NULL CHECK (number BETWEEN 1 AND 26),
  title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 200),
  source_file TEXT NOT NULL CHECK (length(trim(source_file)) BETWEEN 1 AND 300),
  processed_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (processed_at GLOB '????-??-??T??:??:??*Z'),
  UNIQUE (module_id, week),
  UNIQUE (id, module_id),
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R03: concept (E03 Concept — deterministic ID <MODULE>-<WEEK>-K<nn>, BR-020)
CREATE TABLE IF NOT EXISTS concept (
  id TEXT PRIMARY KEY CHECK (id GLOB '*-W[0-9][0-9]*-K[0-9][0-9]*' AND length(id) <= 80),
  module_id TEXT NOT NULL,
  lecture_id TEXT NOT NULL,
  name TEXT NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 200),
  summary TEXT NOT NULL CHECK (length(trim(summary)) BETWEEN 1 AND 500),
  importance TEXT NOT NULL CHECK (importance IN ('core', 'supporting', 'detail')),
  source TEXT NOT NULL CHECK (length(trim(source)) BETWEEN 1 AND 300),
  UNIQUE (id, module_id),
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (lecture_id, module_id) REFERENCES lecture(id, module_id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R04: concept_prerequisite (REL-05 unary M:N Concept prerequisites)
CREATE TABLE IF NOT EXISTS concept_prerequisite (
  concept_id TEXT NOT NULL,
  prerequisite_concept_id TEXT NOT NULL,
  PRIMARY KEY (concept_id, prerequisite_concept_id),
  CHECK (concept_id <> prerequisite_concept_id),
  FOREIGN KEY (concept_id) REFERENCES concept(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (prerequisite_concept_id) REFERENCES concept(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
-- R06: card (E04 Card — deterministic ID <MODULE>-<WEEK>-C<nnn>, BR-008, BR-020)
CREATE TABLE IF NOT EXISTS card (
  id TEXT PRIMARY KEY CHECK (id GLOB '*-W[0-9][0-9]*-C[0-9][0-9][0-9]*' AND length(id) <= 80),
  module_id TEXT NOT NULL,
  lecture_id TEXT NOT NULL,
  concept_id TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('basic', 'cloze', 'reverse')),
  front TEXT NOT NULL CHECK (length(trim(front)) >= 1 AND length(front) <= 2000),
  back TEXT NOT NULL CHECK (length(trim(back)) >= 1 AND length(back) <= 2000),
  extra TEXT NOT NULL DEFAULT '' CHECK (length(extra) <= 4000),
  source TEXT NOT NULL CHECK (length(trim(source)) BETWEEN 1 AND 300),
  suspended INTEGER NOT NULL DEFAULT 0 CHECK (suspended IN (0, 1)),
  flagged INTEGER NOT NULL DEFAULT 0 CHECK (flagged IN (0, 1)),
  edited_by_user INTEGER NOT NULL DEFAULT 0 CHECK (edited_by_user IN (0, 1)),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (updated_at GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (lecture_id, module_id) REFERENCES lecture(id, module_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (concept_id, module_id) REFERENCES concept(id, module_id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R05: concept_card (REL-06 M:N Concept <-> Card, BR-032)
CREATE TABLE IF NOT EXISTS concept_card (
  concept_id TEXT NOT NULL,
  card_id TEXT NOT NULL,
  display_order INTEGER NOT NULL DEFAULT 0 CHECK (display_order >= 0),
  PRIMARY KEY (concept_id, card_id),
  FOREIGN KEY (concept_id) REFERENCES concept(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (card_id) REFERENCES card(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
-- R07: card_tag (1NF decomposition of Card.tags)
CREATE TABLE IF NOT EXISTS card_tag (
  card_id TEXT NOT NULL,
  tag TEXT NOT NULL CHECK (length(trim(tag)) > 0),
  PRIMARY KEY (card_id, tag),
  FOREIGN KEY (card_id) REFERENCES card(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
-- R08: card_state (E05 CardState — 1:1 FSRS state per Card, BR-021, BR-026)
CREATE TABLE IF NOT EXISTS card_state (
  card_id TEXT PRIMARY KEY,
  state TEXT NOT NULL DEFAULT 'New' CHECK (state IN ('New', 'Learning', 'Review', 'Relearning')),
  stability REAL NOT NULL DEFAULT 0.0 CHECK (stability >= 0.0),
  difficulty REAL NOT NULL DEFAULT 0.0 CHECK (difficulty = 0.0 OR (difficulty >= 1.0 AND difficulty <= 10.0)),
  elapsed_days REAL NOT NULL DEFAULT 0.0 CHECK (elapsed_days >= 0.0),
  scheduled_days REAL NOT NULL DEFAULT 0.0 CHECK (scheduled_days >= 0.0),
  reps INTEGER NOT NULL DEFAULT 0 CHECK (reps >= 0),
  lapses INTEGER NOT NULL DEFAULT 0 CHECK (lapses >= 0),
  due TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (due GLOB '????-??-??T??:??:??*Z'),
  last_review TEXT CHECK (last_review IS NULL OR last_review GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (card_id) REFERENCES card(id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R09: card_review_log (E06 CardReviewLog — append-only FSRS log, BR-021, BR-027)
CREATE TABLE IF NOT EXISTS card_review_log (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  card_id TEXT NOT NULL,
  rating INTEGER NOT NULL CHECK (rating IN (1, 2, 3, 4)),
  state_before TEXT NOT NULL CHECK (state_before IN ('New', 'Learning', 'Review', 'Relearning')),
  stability_before REAL NOT NULL CHECK (stability_before >= 0.0),
  stability_after REAL NOT NULL CHECK (stability_after >= 0.0),
  retrievability_at_review REAL NOT NULL CHECK (retrievability_at_review >= 0.0 AND retrievability_at_review <= 1.0),
  is_first_lapse INTEGER NOT NULL DEFAULT 0 CHECK (is_first_lapse IN (0, 1)),
  duration_ms INTEGER NOT NULL CHECK (duration_ms >= 0),
  reviewed_at TEXT NOT NULL CHECK (reviewed_at GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (card_id) REFERENCES card(id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R10: concept_state (E07 ConceptState — 1:1 FSRS state per Concept, BR-026, BR-028)
CREATE TABLE IF NOT EXISTS concept_state (
  concept_id TEXT PRIMARY KEY,
  state TEXT NOT NULL DEFAULT 'New' CHECK (state IN ('New', 'Learning', 'Review', 'Relearning')),
  stability REAL NOT NULL DEFAULT 0.0 CHECK (stability >= 0.0),
  difficulty REAL NOT NULL DEFAULT 0.0 CHECK (difficulty = 0.0 OR (difficulty >= 1.0 AND difficulty <= 10.0)),
  reps INTEGER NOT NULL DEFAULT 0 CHECK (reps >= 0),
  lapses INTEGER NOT NULL DEFAULT 0 CHECK (lapses >= 0),
  due TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (due GLOB '????-??-??T??:??:??*Z'),
  last_quiz TEXT CHECK (last_quiz IS NULL OR last_quiz GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (concept_id) REFERENCES concept(id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R11: question (E08 Question — deterministic ID <MODULE>-<WEEK>-Q<nnn>, BR-017, BR-020)
CREATE TABLE IF NOT EXISTS question (
  id TEXT PRIMARY KEY CHECK (id GLOB '*-W[0-9][0-9]*-Q[0-9][0-9][0-9]*' AND length(id) <= 80),
  module_id TEXT NOT NULL,
  lecture_id TEXT NOT NULL,
  concept_id TEXT NOT NULL,
  variant_group TEXT NOT NULL CHECK (length(trim(variant_group)) BETWEEN 1 AND 80),
  type TEXT NOT NULL CHECK (type IN ('mcq', 'short_answer', 'calculation', 'explain', 'scenario', 'compare', 'essay_plan')),
  difficulty INTEGER NOT NULL CHECK (difficulty IN (1, 2, 3)),
  stem TEXT NOT NULL CHECK (length(trim(stem)) >= 1 AND length(stem) <= 4000),
  correct_option TEXT CHECK ( (type = 'mcq' AND correct_option IN ('A', 'B', 'C', 'D')) OR (type <> 'mcq' AND correct_option IS NULL) ),
  model_answer TEXT NOT NULL CHECK (length(trim(model_answer)) >= 1 AND length(model_answer) <= 4000),
  source TEXT NOT NULL CHECK (length(trim(source)) BETWEEN 1 AND 300),
  suspended INTEGER NOT NULL DEFAULT 0 CHECK (suspended IN (0, 1)),
  flagged INTEGER NOT NULL DEFAULT 0 CHECK (flagged IN (0, 1)),
  UNIQUE (id, concept_id),
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (lecture_id, module_id) REFERENCES lecture(id, module_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (concept_id, module_id) REFERENCES concept(id, module_id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R12: question_option (1NF decomposition of Question.options & distractor_explanations)
CREATE TABLE IF NOT EXISTS question_option (
  question_id TEXT NOT NULL,
  option_key TEXT NOT NULL CHECK (option_key IN ('A', 'B', 'C', 'D')),
  option_text TEXT NOT NULL CHECK (length(trim(option_text)) > 0),
  distractor_explanation TEXT NOT NULL DEFAULT '',
  PRIMARY KEY (question_id, option_key),
  FOREIGN KEY (question_id) REFERENCES question(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
-- R13: question_marking_point (1NF decomposition of Question.marking_points, BR-017)
CREATE TABLE IF NOT EXISTS question_marking_point (
  question_id TEXT NOT NULL,
  point_index INTEGER NOT NULL CHECK (point_index >= 0 AND point_index <= 9),
  point_text TEXT NOT NULL CHECK (length(trim(point_text)) > 0),
  PRIMARY KEY (question_id, point_index),
  FOREIGN KEY (question_id) REFERENCES question(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
-- R14: question_attempt (E09 QuestionAttempt — append-only log, BR-021, BR-031)
CREATE TABLE IF NOT EXISTS question_attempt (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  question_id TEXT NOT NULL,
  concept_id TEXT NOT NULL,
  mode TEXT NOT NULL DEFAULT 'daily_quiz' CHECK (mode IN ('daily_quiz', 'mock_exam')),
  mock_exam_id TEXT,
  user_answer TEXT NOT NULL CHECK (length(user_answer) <= 10000),
  rating INTEGER NOT NULL CHECK (rating IN (1, 2, 3, 4)),
  grader TEXT NOT NULL CHECK (grader IN ('auto', 'self', 'claude', 'pending_claude')),
  feedback TEXT NOT NULL DEFAULT '' CHECK (length(feedback) <= 2000),
  overridden INTEGER NOT NULL DEFAULT 0 CHECK (overridden IN (0, 1)),
  duration_ms INTEGER NOT NULL CHECK (duration_ms >= 0),
  attempted_at TEXT NOT NULL CHECK (attempted_at GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (question_id, concept_id) REFERENCES question(id, concept_id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (concept_id) REFERENCES concept(id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R15: question_attempt_point (1NF decomposition of QuestionAttempt.points_met)
CREATE TABLE IF NOT EXISTS question_attempt_point (
  attempt_id TEXT NOT NULL,
  point_index INTEGER NOT NULL CHECK (point_index >= 0 AND point_index <= 9),
  met INTEGER NOT NULL CHECK (met IN (0, 1)),
  PRIMARY KEY (attempt_id, point_index),
  FOREIGN KEY (attempt_id) REFERENCES question_attempt(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
-- R16: glossary_entry (E10 GlossaryEntry — deterministic ID <MODULE>-G<nnn>, BR-009, BR-020)
CREATE TABLE IF NOT EXISTS glossary_entry (
  id TEXT PRIMARY KEY CHECK (id GLOB '*-G[0-9][0-9][0-9]*' AND length(id) <= 80),
  module_id TEXT NOT NULL,
  term TEXT NOT NULL CHECK (length(trim(term)) BETWEEN 1 AND 300),
  abbreviation TEXT NOT NULL CHECK (length(trim(abbreviation)) BETWEEN 1 AND 64),
  kind TEXT NOT NULL CHECK (kind IN ('standard', 'module_specific')),
  canonical TEXT NOT NULL CHECK (length(trim(canonical)) BETWEEN 1 AND 400),
  definition TEXT NOT NULL CHECK (length(trim(definition)) >= 1 AND length(definition) <= 2000),
  where_defined TEXT NOT NULL CHECK (length(trim(where_defined)) BETWEEN 1 AND 300),
  first_lecture_id TEXT,
  confirmed INTEGER NOT NULL DEFAULT 0 CHECK (confirmed IN (0, 1)),
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (first_lecture_id) REFERENCES lecture(id) ON DELETE SET NULL ON UPDATE CASCADE
) STRICT;
-- R17: deadline (E11 Deadline — <MODULE>-D<nnn> or UUID, BR-004, BR-023, BR-033, BR-034)
CREATE TABLE IF NOT EXISTS deadline (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) BETWEEN 1 AND 80),
  module_id TEXT NOT NULL,
  title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 200),
  type TEXT NOT NULL CHECK (type IN ('exam', 'midterm', 'quiz', 'homework', 'project', 'coursework', 'other')),
  due_at TEXT CHECK (due_at IS NULL OR due_at GLOB '????-??-??T??:??:??*Z'),
  unannounced_reason TEXT CHECK (unannounced_reason IS NULL OR length(unannounced_reason) <= 500),
  timezone TEXT NOT NULL DEFAULT 'Asia/Hong_Kong' CHECK (length(trim(timezone)) BETWEEN 1 AND 64),
  weighting REAL CHECK (weighting IS NULL OR (weighting >= 0.0 AND weighting <= 100.0)),
  submission_url TEXT CHECK (submission_url IS NULL OR length(submission_url) <= 500),
  format_json TEXT CHECK (format_json IS NULL OR json_valid(format_json) = 1),
  status TEXT NOT NULL DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'unannounced', 'submitted', 'done', 'missed', 'overdue')),
  origin TEXT NOT NULL DEFAULT 'extracted' CHECK (origin IN ('extracted', 'manual')),
  confidence TEXT NOT NULL DEFAULT 'explicit' CHECK (confidence IN ('explicit', 'inferred')),
  confirmed INTEGER NOT NULL DEFAULT 0 CHECK (confirmed IN (0, 1)),
  manually_edited INTEGER NOT NULL DEFAULT 0 CHECK (manually_edited IN (0, 1)),
  source TEXT NOT NULL CHECK (length(trim(source)) BETWEEN 1 AND 300),
  notes TEXT NOT NULL DEFAULT '' CHECK (length(notes) <= 2000),
  CHECK ( (status = 'unannounced' AND due_at IS NULL) OR (status <> 'unannounced' AND due_at IS NOT NULL) ),
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R18: deadline_lecture (REL-16 M:N Deadline.covers_lectures)
CREATE TABLE IF NOT EXISTS deadline_lecture (
  deadline_id TEXT NOT NULL,
  lecture_id TEXT NOT NULL,
  PRIMARY KEY (deadline_id, lecture_id),
  FOREIGN KEY (deadline_id) REFERENCES deadline(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (lecture_id) REFERENCES lecture(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
-- R19: milestone (E12 Milestone — backward-counted coursework step, REQ-F-056)
CREATE TABLE IF NOT EXISTS milestone (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  deadline_id TEXT NOT NULL,
  title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 200),
  due_on TEXT NOT NULL CHECK (due_on GLOB '????-??-??'),
  est_minutes INTEGER NOT NULL CHECK (est_minutes > 0 AND est_minutes <= 600),
  done INTEGER NOT NULL DEFAULT 0 CHECK (done IN (0, 1)),
  order_index INTEGER NOT NULL DEFAULT 1 CHECK (order_index >= 1),
  FOREIGN KEY (deadline_id) REFERENCES deadline(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
-- R20: task (E13 Task — student-created study task, REQ-F-038, REQ-F-041)
CREATE TABLE IF NOT EXISTS task (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  module_id TEXT,
  title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 300),
  due_on TEXT CHECK (due_on IS NULL OR due_on GLOB '????-??-??'),
  est_minutes INTEGER NOT NULL CHECK (est_minutes > 0 AND est_minutes <= 600),
  priority TEXT NOT NULL DEFAULT 'optional' CHECK (priority IN ('required', 'optional')),
  recurrence TEXT DEFAULT 'none' CHECK (recurrence IS NULL OR recurrence IN ('none', 'daily', 'weekly')),
  done INTEGER NOT NULL DEFAULT 0 CHECK (done IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (created_at GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE SET NULL ON UPDATE CASCADE
) STRICT;
-- R21: reading (E14 Reading — <MODULE>-R<nnn> or UUID, REQ-F-005, REQ-F-041)
CREATE TABLE IF NOT EXISTS reading (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) BETWEEN 1 AND 80),
  module_id TEXT NOT NULL,
  lecture_id TEXT,
  title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 300),
  citation TEXT NOT NULL CHECK (length(trim(citation)) BETWEEN 1 AND 500),
  pages TEXT CHECK (pages IS NULL OR length(pages) BETWEEN 1 AND 100),
  kind TEXT NOT NULL CHECK (kind IN ('required', 'recommended', 'optional')),
  page_count INTEGER NOT NULL CHECK (page_count >= 1 AND page_count <= 1000),
  est_minutes REAL NOT NULL CHECK (est_minutes >= 1.0),
  due_on TEXT NOT NULL CHECK (due_on GLOB '????-??-??'),
  status TEXT NOT NULL DEFAULT 'unread' CHECK (status IN ('unread', 'todo', 'done', 'skimmed', 'skipped')),
  confidence TEXT NOT NULL DEFAULT 'explicit' CHECK (confidence IN ('explicit', 'inferred')),
  confirmed INTEGER NOT NULL DEFAULT 0 CHECK (confirmed IN (0, 1)),
  completed_at TEXT CHECK (completed_at IS NULL OR completed_at GLOB '????-??-??T??:??:??*Z'),
  source TEXT NOT NULL CHECK (length(trim(source)) BETWEEN 1 AND 300),
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (lecture_id) REFERENCES lecture(id) ON DELETE SET NULL ON UPDATE CASCADE
) STRICT;
-- R22: daily_plan (E15 DailyPlan — 1 row per local calendar date, BR-035..037)
CREATE TABLE IF NOT EXISTS daily_plan (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  plan_date TEXT NOT NULL UNIQUE CHECK (plan_date GLOB '????-??-??'),
  budget_min INTEGER NOT NULL DEFAULT 120 CHECK (budget_min >= 15 AND budget_min <= 720),
  generated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (generated_at GLOB '????-??-??T??:??:??*Z')
) STRICT;
-- R23: daily_plan_item (E16 DailyPlanItem — 9-step ordered checklist item, BR-035)
CREATE TABLE IF NOT EXISTS daily_plan_item (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  plan_id TEXT NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('carryover', 'card_review', 'quiz', 'new_cards', 'required_reading', 'milestone', 'assessment_prep', 'recommended_reading', 'task')),
  ref_id TEXT NOT NULL CHECK (length(trim(ref_id)) > 0),
  module_id TEXT,
  title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 300),
  est_minutes REAL NOT NULL CHECK (est_minutes >= 0.0),
  priority TEXT NOT NULL CHECK (priority IN ('required', 'optional')),
  order_index INTEGER NOT NULL CHECK (order_index >= 1),
  completed INTEGER NOT NULL DEFAULT 0 CHECK (completed IN (0, 1)),
  completed_at TEXT CHECK (completed_at IS NULL OR completed_at GLOB '????-??-??T??:??:??*Z'),
  carried_over INTEGER NOT NULL DEFAULT 0 CHECK (carried_over IN (0, 1)),
  deferred INTEGER NOT NULL DEFAULT 0 CHECK (deferred IN (0, 1)),
  FOREIGN KEY (plan_id) REFERENCES daily_plan(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE SET NULL ON UPDATE CASCADE
) STRICT;
-- R24: tutor_thread (E17 TutorThread — grounded conversation thread, REQ-F-045, REQ-F-052)
CREATE TABLE IF NOT EXISTS tutor_thread (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  module_id TEXT NOT NULL,
  title TEXT NOT NULL CHECK (length(trim(title)) BETWEEN 1 AND 200),
  mode TEXT NOT NULL DEFAULT 'explain' CHECK (mode IN ('explain', 'socratic', 'quiz_me')),
  linked_type TEXT DEFAULT 'none' CHECK (linked_type IS NULL OR linked_type IN ('card', 'question', 'attempt', 'concept', 'reading', 'deadline', 'none')),
  linked_id TEXT,
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (created_at GLOB '????-??-??T??:??:??*Z'),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (updated_at GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R25: tutor_message (E18 TutorMessage — money stored as integer cost_micro_usd, BR-039, BR-041)
CREATE TABLE IF NOT EXISTS tutor_message (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  thread_id TEXT NOT NULL,
  role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
  content TEXT NOT NULL CHECK (length(trim(content)) >= 1 AND length(content) <= 20000),
  model TEXT,
  input_tokens INTEGER NOT NULL DEFAULT 0 CHECK (input_tokens >= 0),
  output_tokens INTEGER NOT NULL DEFAULT 0 CHECK (output_tokens >= 0),
  cached_tokens INTEGER NOT NULL DEFAULT 0 CHECK (cached_tokens >= 0),
  cost_micro_usd INTEGER NOT NULL DEFAULT 0 CHECK (cost_micro_usd >= 0),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (created_at GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (thread_id) REFERENCES tutor_thread(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
-- R26: tutor_message_citation (1NF decomposition of TutorMessage.citations, BR-039)
CREATE TABLE IF NOT EXISTS tutor_message_citation (
  message_id TEXT NOT NULL,
  citation_index INTEGER NOT NULL CHECK (citation_index >= 0),
  source_ref TEXT NOT NULL CHECK (length(trim(source_ref)) > 0),
  PRIMARY KEY (message_id, citation_index),
  FOREIGN KEY (message_id) REFERENCES tutor_message(id) ON DELETE CASCADE ON UPDATE CASCADE
) STRICT;
-- R27: proposal (E19 Proposal — candidate card/question from tutor chat, REQ-F-049, ADR-007)
CREATE TABLE IF NOT EXISTS proposal (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  thread_id TEXT NOT NULL,
  module_id TEXT NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('card', 'question')),
  payload_json TEXT NOT NULL CHECK (json_valid(payload_json) = 1),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'accepted', 'edited', 'discarded')),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (created_at GLOB '????-??-??T??:??:??*Z'),
  reviewed_at TEXT CHECK (reviewed_at IS NULL OR reviewed_at GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (thread_id) REFERENCES tutor_thread(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R28: feedback_item (E20 FeedbackItem — reported, topup, proposed queue, BR-030, BR-038, ADR-007)
CREATE TABLE IF NOT EXISTS feedback_item (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  module_id TEXT NOT NULL,
  kind TEXT NOT NULL CHECK (kind IN ('reported', 'topup', 'proposed')),
  item_type TEXT NOT NULL CHECK (item_type IN ('card', 'question', 'concept', 'proposal')),
  item_id TEXT NOT NULL CHECK (length(trim(item_id)) > 0),
  reason TEXT CHECK ( (kind = 'reported' AND reason IN ('wrong', 'unclear')) OR (kind <> 'reported' AND (reason IS NULL OR reason IN ('wrong', 'unclear', 'low_variants', 'tutor_proposed'))) ),
  comment TEXT NOT NULL DEFAULT '' CHECK (length(comment) <= 2000),
  payload_json TEXT NOT NULL DEFAULT '{}' CHECK (json_valid(payload_json) = 1),
  exported INTEGER NOT NULL DEFAULT 0 CHECK (exported IN (0, 1)),
  created_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (created_at GLOB '????-??-??T??:??:??*Z'),
  exported_at TEXT CHECK (exported_at IS NULL OR exported_at GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R29: settings (E21 Settings — singleton configuration row, BR-025..028, BR-035, BR-041, ADR-007)
CREATE TABLE IF NOT EXISTS settings (
  id TEXT PRIMARY KEY DEFAULT 'default' CHECK (id = 'default'),
  daily_budget_min INTEGER NOT NULL DEFAULT 120 CHECK (daily_budget_min >= 15 AND daily_budget_min <= 720),
  new_cards_per_day INTEGER NOT NULL DEFAULT 20 CHECK (new_cards_per_day >= 0 AND new_cards_per_day <= 500),
  review_cards_per_day INTEGER NOT NULL DEFAULT 200 CHECK (review_cards_per_day >= 1 AND review_cards_per_day <= 2000),
  quiz_per_day INTEGER NOT NULL DEFAULT 10 CHECK (quiz_per_day >= 0 AND quiz_per_day <= 100),
  reading_lookahead_days INTEGER NOT NULL DEFAULT 3 CHECK (reading_lookahead_days >= 0 AND reading_lookahead_days <= 30),
  minutes_per_page REAL NOT NULL DEFAULT 2.5 CHECK (minutes_per_page >= 0.5 AND minutes_per_page <= 15.0),
  desired_retention REAL NOT NULL DEFAULT 0.90 CHECK (desired_retention >= 0.70 AND desired_retention <= 0.99),
  scheduler_mode TEXT NOT NULL DEFAULT 'fsrs' CHECK (scheduler_mode IN ('fsrs', 'sm2')),
  assessment_mode_days INTEGER NOT NULL DEFAULT 21 CHECK (assessment_mode_days >= 1 AND assessment_mode_days <= 90),
  grading_model TEXT NOT NULL DEFAULT 'claude-haiku-5-5' CHECK (length(trim(grading_model)) BETWEEN 1 AND 100 AND grading_model NOT GLOB '*[^A-Za-z0-9._-]*'),
  tutor_model TEXT NOT NULL DEFAULT 'claude-sonnet-5-5' CHECK (length(trim(tutor_model)) BETWEEN 1 AND 100 AND tutor_model NOT GLOB '*[^A-Za-z0-9._-]*'),
  monthly_spend_cap_micro_usd INTEGER CHECK (monthly_spend_cap_micro_usd IS NULL OR (monthly_spend_cap_micro_usd > 0 AND monthly_spend_cap_micro_usd <= 1000000000)),
  monthly_spend_cap_mode TEXT NOT NULL DEFAULT 'block' CHECK (monthly_spend_cap_mode IN ('block', 'warn')),
  timezone TEXT NOT NULL DEFAULT 'Asia/Hong_Kong' CHECK (length(trim(timezone)) BETWEEN 1 AND 64),
  notifications_enabled INTEGER NOT NULL DEFAULT 0 CHECK (notifications_enabled IN (0, 1)),
  fsrs_weights_json TEXT DEFAULT NULL CHECK (fsrs_weights_json IS NULL OR (json_valid(fsrs_weights_json) = 1 AND json_type(fsrs_weights_json) = 'array' AND json_array_length(fsrs_weights_json) IN (17, 19, 21))),
  token_rates_json TEXT NOT NULL DEFAULT '{"claude-haiku-4-5":{"input_micro_per_mtok":1000000,"output_micro_per_mtok":5000000,"cache_read_micro_per_mtok":100000},"claude-sonnet-4-6":{"input_micro_per_mtok":3000000,"output_micro_per_mtok":15000000,"cache_read_micro_per_mtok":300000},"claude-haiku-5-5":{"input_micro_per_mtok":100000,"output_micro_per_mtok":500000,"cache_read_micro_per_mtok":10000},"claude-sonnet-5-5":{"input_micro_per_mtok":2000000,"output_micro_per_mtok":10000000,"cache_read_micro_per_mtok":200000}}' CHECK (json_valid(token_rates_json) = 1),
  updated_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (updated_at GLOB '????-??-??T??:??:??*Z'),
  CHECK ( json_type(token_rates_json) = 'object' AND COALESCE(json_extract(token_rates_json, '$."' || grading_model || '".input_micro_per_mtok'), 0) > 0 AND COALESCE(json_extract(token_rates_json, '$."' || grading_model || '".output_micro_per_mtok'), 0) > 0 AND COALESCE(json_extract(token_rates_json, '$."' || grading_model || '".cache_read_micro_per_mtok'), 0) > 0 AND COALESCE(json_extract(token_rates_json, '$."' || tutor_model || '".input_micro_per_mtok'), 0) > 0 AND COALESCE(json_extract(token_rates_json, '$."' || tutor_model || '".output_micro_per_mtok'), 0) > 0 AND COALESCE(json_extract(token_rates_json, '$."' || tutor_model || '".cache_read_micro_per_mtok'), 0) > 0 )
) STRICT;
-- R30: import_batch (E22 ImportBatch — audit record per module import, BR-021, BR-024)
CREATE TABLE IF NOT EXISTS import_batch (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  module_id TEXT NOT NULL,
  file_kind TEXT NOT NULL DEFAULT 'package' CHECK (file_kind IN ('deck', 'questions', 'concepts', 'glossary', 'deadlines', 'readings', 'package')),
  new_count INTEGER NOT NULL DEFAULT 0 CHECK (new_count >= 0),
  updated_count INTEGER NOT NULL DEFAULT 0 CHECK (updated_count >= 0),
  unchanged_count INTEGER NOT NULL DEFAULT 0 CHECK (unchanged_count >= 0),
  suspended_count INTEGER NOT NULL DEFAULT 0 CHECK (suspended_count >= 0),
  backup_path TEXT NOT NULL CHECK (length(trim(backup_path)) > 0),
  backup_sha256 TEXT NOT NULL CHECK (length(backup_sha256) = 64),
  imported_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (imported_at GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (module_id) REFERENCES module(id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R31: import_batch_lecture (REL-27 M:N ImportBatch.lecture_ids)
CREATE TABLE IF NOT EXISTS import_batch_lecture (
  batch_id TEXT NOT NULL,
  lecture_id TEXT NOT NULL,
  PRIMARY KEY (batch_id, lecture_id),
  FOREIGN KEY (batch_id) REFERENCES import_batch(id) ON DELETE CASCADE ON UPDATE CASCADE,
  FOREIGN KEY (lecture_id) REFERENCES lecture(id) ON DELETE RESTRICT ON UPDATE CASCADE
) STRICT;
-- R32: grading_call_log (E28 GradingCallLog — integer cost_micro_usd, BR-041)
CREATE TABLE IF NOT EXISTS grading_call_log (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  question_id TEXT NOT NULL,
  attempt_id TEXT UNIQUE,
  model TEXT NOT NULL CHECK (length(trim(model)) > 0),
  input_tokens INTEGER NOT NULL CHECK (input_tokens >= 0),
  output_tokens INTEGER NOT NULL CHECK (output_tokens >= 0),
  cached_tokens INTEGER NOT NULL DEFAULT 0 CHECK (cached_tokens >= 0),
  cost_micro_usd INTEGER NOT NULL CHECK (cost_micro_usd >= 0),
  duration_ms INTEGER NOT NULL CHECK (duration_ms >= 0),
  status TEXT NOT NULL CHECK (status IN ('ok', 'timeout', 'error', 'capped')),
  called_at TEXT NOT NULL DEFAULT (strftime('%Y-%m-%dT%H:%M:%fZ', 'now')) CHECK (called_at GLOB '????-??-??T??:??:??*Z'),
  FOREIGN KEY (question_id) REFERENCES question(id) ON DELETE RESTRICT ON UPDATE CASCADE,
  FOREIGN KEY (attempt_id) REFERENCES question_attempt(id) ON DELETE SET NULL ON UPDATE CASCADE
) STRICT;
-- R33: auth_session (R3 Hosted Mode Owner Sessions, ADR-006, REQ-F-059, REQ-N-015, A37)
CREATE TABLE IF NOT EXISTS auth_session (
  id TEXT PRIMARY KEY CHECK (length(trim(id)) > 0),
  token_sha256 TEXT NOT NULL UNIQUE CHECK (length(token_sha256) = 64),
  user_agent TEXT NOT NULL DEFAULT '',
  issued_at TEXT NOT NULL CHECK (issued_at GLOB '????-??-??T??:??:??*Z'),
  expires_at TEXT NOT NULL CHECK (expires_at GLOB '????-??-??T??:??:??*Z'),
  revoked_at TEXT CHECK (revoked_at IS NULL OR revoked_at GLOB '????-??-??T??:??:??*Z')
) STRICT;
-- Derived 3NF Read Views (ADR-007, A32 §4; V01 projects current_elapsed_days for SQL inspection while M03 computes elapsed days and retrievability from its injected nowIso clock via ts-fsrs v5; V02 classifies mastery_level with SM-5 = mastered + strong per BR-044 and ASM-066(d))
CREATE VIEW IF NOT EXISTS v_card_state_with_retrievability AS SELECT cs.card_id, cs.state, cs.stability, cs.difficulty, cs.elapsed_days, cs.scheduled_days, cs.reps, cs.lapses, cs.due, cs.last_review, CASE WHEN cs.state = 'New' OR cs.last_review IS NULL THEN 0.0 ELSE max(0.0, julianday('now') - julianday(cs.last_review)) END AS current_elapsed_days FROM card_state cs;
CREATE VIEW IF NOT EXISTS v_concept_mastery AS SELECT c.id AS concept_id, c.module_id, c.lecture_id, c.importance, cs.state, cs.stability, cs.difficulty, cs.reps, cs.lapses, cs.due, cs.last_quiz, COUNT(qa.id) AS attempt_count, CASE WHEN cs.state = 'New' AND COUNT(qa.id) = 0 THEN 'unseen' WHEN cs.stability >= 14.0 AND COUNT(qa.id) >= 2 AND cs.lapses = 0 THEN 'mastered' WHEN cs.stability >= 14.0 AND COUNT(qa.id) >= 2 THEN 'strong' WHEN cs.stability < 3.0 OR cs.lapses >= 3 THEN 'weak' ELSE 'developing' END AS mastery_level FROM concept c JOIN concept_state cs ON cs.concept_id = c.id LEFT JOIN question_attempt qa ON qa.concept_id = c.id GROUP BY c.id;
CREATE VIEW IF NOT EXISTS v_daily_plan_summary AS SELECT dp.id, dp.plan_date AS date, dp.budget_min, COALESCE(SUM(CASE WHEN dpi.deferred = 0 THEN dpi.est_minutes ELSE 0.0 END), 0.0) AS total_est_minutes, COALESCE(SUM(CASE WHEN dpi.priority = 'required' THEN dpi.est_minutes ELSE 0.0 END), 0.0) AS required_minutes, CASE WHEN COALESCE(SUM(CASE WHEN dpi.priority = 'required' THEN dpi.est_minutes ELSE 0.0 END), 0.0) > dp.budget_min THEN 1 ELSE 0 END AS over_budget_warning, CASE WHEN COUNT(dpi.id) > 0 AND SUM(CASE WHEN dpi.priority = 'required' AND dpi.completed = 0 THEN 1 ELSE 0 END) = 0 THEN 1 ELSE 0 END AS completed, dp.generated_at FROM daily_plan dp LEFT JOIN daily_plan_item dpi ON dpi.plan_id = dp.id GROUP BY dp.id;
-- Justified Secondary Indexes (A33 §4 — every index tied to a named query)
-- IDX-01: Daily flashcard review queue query (GET /api/review/next, REQ-N-001, REQ-N-002)
CREATE INDEX IF NOT EXISTS idx_card_module_active ON card(module_id, suspended, flagged, lecture_id);
-- IDX-02: Due flashcard lookup sorted by due timestamp (GET /api/review/next, REQ-N-002)
CREATE INDEX IF NOT EXISTS idx_card_state_state_due ON card_state(state, due);
-- IDX-03: Trailing 30-day true retention (SM-2) and daily review velocity (GET /api/stats, REQ-F-058)
CREATE INDEX IF NOT EXISTS idx_card_review_log_reviewed_at ON card_review_log(reviewed_at, state_before, rating);
-- IDX-04: Per-card review history lookup & FSRS optimiser training (UC-07, UC-20)
CREATE INDEX IF NOT EXISTS idx_card_review_log_card_id ON card_review_log(card_id, reviewed_at);
-- IDX-05: Due concept quiz queue & assessment-mode lowest-stability sort (GET /api/quiz/next, BR-028, BR-043)
CREATE INDEX IF NOT EXISTS idx_concept_state_due_stability ON concept_state(due, stability);
-- IDX-06: Concept lookup by module and lecture for mastery map & assessment scope (GET /api/modules/:id, REQ-F-058)
CREATE INDEX IF NOT EXISTS idx_concept_module_lecture ON concept(module_id, lecture_id, importance);
-- IDX-07: Question variant selection per concept excluding suspended/flagged (DT-03, BR-029, REQ-N-002)
CREATE INDEX IF NOT EXISTS idx_question_concept_active ON question(concept_id, suspended, flagged, difficulty);
-- IDX-08: Least-recently-seen variant & per-concept attempt count (DT-03, SM-5, BR-029, BR-044)
CREATE INDEX IF NOT EXISTS idx_question_attempt_concept_question ON question_attempt(concept_id, question_id, attempted_at DESC);
-- IDX-09: Offline pending Claude marking flush queue (R3, REQ-F-061, REQ-N-009)
CREATE INDEX IF NOT EXISTS idx_question_attempt_grader ON question_attempt(grader, attempted_at) WHERE grader = 'pending_claude';
-- IDX-10: Upcoming deadlines countdown & assessment-mode detection (GET /api/deadlines, GET /api/today, BR-033, BR-043)
CREATE INDEX IF NOT EXISTS idx_deadline_status_due_at ON deadline(status, due_at, module_id);
-- IDX-11: Today checklist items ordered by 9-step order_index (GET /api/today, REQ-N-003, BR-035)
CREATE INDEX IF NOT EXISTS idx_daily_plan_item_plan_order ON daily_plan_item(plan_id, deferred, order_index);
-- IDX-12: Unexported feedback items for feedback.json export & SM-3 wrong-item rate (GET /api/export/feedback, BR-038)
CREATE INDEX IF NOT EXISTS idx_feedback_item_module_exported ON feedback_item(module_id, exported, kind, reason);
-- IDX-13: Tutor thread list & search per module (GET /api/tutor/threads, REQ-F-052)
CREATE INDEX IF NOT EXISTS idx_tutor_thread_module_updated ON tutor_thread(module_id, updated_at DESC);
-- IDX-14: Monthly Claude API spend aggregation on tutor messages (GET /api/stats, SM-6, BR-041)
CREATE INDEX IF NOT EXISTS idx_tutor_message_created_cost ON tutor_message(created_at, cost_micro_usd) WHERE role = 'assistant';
-- IDX-15: Monthly Claude API spend aggregation on written-answer marking calls (GET /api/stats, SM-6, BR-041)
CREATE INDEX IF NOT EXISTS idx_grading_call_log_called_cost ON grading_call_log(called_at, cost_micro_usd);
-- Seed singleton R29 settings row (id = 'default', TC-I-097)
INSERT OR IGNORE INTO settings (id) VALUES ('default');
