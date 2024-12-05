drop table habit_entry;
drop table habit;
drop table category;
CREATE TABLE category (
    id TEXT PRIMARY KEY,
    created_at INTEGER NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    color INTEGER,
    icon_name TEXT,
    extra_attributes TEXT
);
CREATE TABLE habit (
    id TEXT PRIMARY KEY,
    created_at INTEGER NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    category_id TEXT,
    type TEXT NOT NULL CHECK (type IN ('checkbox', 'numeric', 'duration')),
    frequency_type TEXT NOT NULL CHECK (
        frequency_type IN ('daily', 'weekly', 'monthly', 'yearly')
    ),
    target_value INTEGER,
    target_days TEXT,
    icon TEXT,
    period TEXT NOT NULL CHECK (
        period IN ('morning', 'afternoon', 'evening', 'anytime')
    ),
    selected_days TEXT,
    start_date TEXT NOT NULL,
    end_date TEXT,
    archived_at TEXT,
    is_archived INTEGER NOT NULL DEFAULT 0,
    target_completion_type TEXT NOT NULL CHECK (
        target_completion_type IN ('atLeast', 'atMost', 'exactly')
    ),
    unit TEXT,
    extra_attributes TEXT,
    FOREIGN KEY (category_id) REFERENCES category (id) ON DELETE
    SET NULL ON UPDATE CASCADE
);
CREATE TABLE habit_entry (
    id TEXT PRIMARY KEY,
    habit_id TEXT NOT NULL,
    date TEXT NOT NULL,
    status TEXT NOT NULL CHECK (
        status IN ('success', 'failed', 'notStarted', 'onGoing')
    ),
    value INTEGER,
    note TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER,
    extra_attributes TEXT,
    FOREIGN KEY (habit_id) REFERENCES habit (id) ON DELETE CASCADE
);