-- RAGME Database Schema
-- SQLite Registry Database

-- Trust levels reference
CREATE TABLE IF NOT EXISTS trust_levels (
    level INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT
);

INSERT OR IGNORE INTO trust_levels VALUES
    (0, 'SANDBOX', 'Isolated testing only'),
    (1, 'BASIC', 'Standard approved operations'),
    (2, 'ELEVATED', 'Sensitive operations'),
    (3, 'FULL', 'System-level access');

-- Category approvals (core of CCAC)
CREATE TABLE IF NOT EXISTS category_approvals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    category TEXT NOT NULL UNIQUE,
    trust_level INTEGER NOT NULL,
    reason TEXT,
    approved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    tools_using INTEGER DEFAULT 0,
    FOREIGN KEY (trust_level) REFERENCES trust_levels(level)
);

CREATE INDEX IF NOT EXISTS idx_category_approvals_category ON category_approvals(category);

-- Tool overrides (exceptions)
CREATE TABLE IF NOT EXISTS tool_overrides (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tool_id TEXT NOT NULL UNIQUE,
    decision TEXT NOT NULL CHECK (decision IN ('allow', 'deny', 'ask')),
    reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tool_id) REFERENCES tools(id)
);

-- Fine-grained policy rules
CREATE TABLE IF NOT EXISTS policy_rules (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    pattern TEXT NOT NULL,
    pattern_type TEXT DEFAULT 'glob' CHECK (pattern_type IN ('glob', 'regex')),
    decision TEXT NOT NULL CHECK (decision IN ('allow', 'deny', 'ask')),
    priority INTEGER DEFAULT 0,
    conditions TEXT,  -- JSON: context conditions
    enabled BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_policy_rules_priority ON policy_rules(priority DESC);

-- Tools table
CREATE TABLE IF NOT EXISTS tools (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    version TEXT NOT NULL,
    code TEXT NOT NULL,
    tests TEXT,
    documentation TEXT,
    mcp_definition TEXT,
    dependencies TEXT,  -- JSON array
    categories TEXT NOT NULL,  -- JSON array: ["network.http_read", "file.write"]
    trust_level INTEGER NOT NULL,  -- Calculated from categories
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'deprecated')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    usage_count INTEGER DEFAULT 0,
    FOREIGN KEY (trust_level) REFERENCES trust_levels(level)
);

CREATE INDEX IF NOT EXISTS idx_tools_categories ON tools(categories);
CREATE INDEX IF NOT EXISTS idx_tools_status ON tools(status);

-- Tool versions table
CREATE TABLE IF NOT EXISTS tool_versions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    tool_id TEXT NOT NULL,
    version TEXT NOT NULL,
    code TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (tool_id) REFERENCES tools(id)
);

CREATE INDEX IF NOT EXISTS idx_tool_versions_tool_id ON tool_versions(tool_id);

-- LoRA adapters table
CREATE TABLE IF NOT EXISTS adapters (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    version TEXT NOT NULL,
    path TEXT NOT NULL,
    training_config TEXT,  -- JSON
    validation_results TEXT,  -- JSON
    dataset_path TEXT,
    dataset_size INTEGER,
    pass_rate REAL,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'deprecated')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_adapters_status ON adapters(status);

-- Approvals table
CREATE TABLE IF NOT EXISTS approvals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    item_type TEXT NOT NULL,  -- tool, adapter, knowledge, action
    item_id TEXT NOT NULL,
    action TEXT NOT NULL,
    decision TEXT NOT NULL,  -- approved, denied
    scope TEXT,  -- tool_only, category
    context TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_approvals_item ON approvals(item_type, item_id);

-- Knowledge modules table
CREATE TABLE IF NOT EXISTS knowledge_modules (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    type TEXT NOT NULL,  -- knowledge_pack, workflow, rulebook, skill, preference
    content TEXT NOT NULL,
    scope TEXT DEFAULT 'global',  -- global, session, task, project:{name}
    metadata TEXT,  -- JSON
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_knowledge_type ON knowledge_modules(type);
CREATE INDEX IF NOT EXISTS idx_knowledge_scope ON knowledge_modules(scope);

-- Gap detection history
CREATE TABLE IF NOT EXISTS gaps (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    gap_id TEXT UNIQUE NOT NULL,
    type TEXT NOT NULL,  -- tool, knowledge, reasoning
    description TEXT NOT NULL,
    context TEXT,  -- JSON
    solution_id TEXT,
    resolved BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved_at TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_gaps_type ON gaps(type);
CREATE INDEX IF NOT EXISTS idx_gaps_resolved ON gaps(resolved);

-- Policy audit log
CREATE TABLE IF NOT EXISTS policy_audit (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    event_type TEXT NOT NULL,
    tool_id TEXT,
    category TEXT,
    decision TEXT,
    reason TEXT,
    context TEXT,  -- JSON
    source TEXT  -- category_approval, tool_override, fine_rule, default
);

CREATE INDEX IF NOT EXISTS idx_policy_audit_timestamp ON policy_audit(timestamp);
CREATE INDEX IF NOT EXISTS idx_policy_audit_tool ON policy_audit(tool_id);
CREATE INDEX IF NOT EXISTS idx_policy_audit_event_type ON policy_audit(event_type);

-- Session state
CREATE TABLE IF NOT EXISTS sessions (
    id TEXT PRIMARY KEY,
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ended_at TIMESTAMP,
    context TEXT,  -- JSON
    capabilities_installed INTEGER DEFAULT 0
);

-- Task checkpoints
CREATE TABLE IF NOT EXISTS task_checkpoints (
    id TEXT PRIMARY KEY,
    task_id TEXT NOT NULL,
    checkpoint_data TEXT NOT NULL,  -- JSON serialized task state
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_checkpoints_task ON task_checkpoints(task_id);
