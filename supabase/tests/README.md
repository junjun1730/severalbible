# Supabase pgTAP Tests

This directory contains SQL tests for Supabase RPC functions using pgTAP.

## Prerequisites

1. **Supabase CLI** installed
2. **pgTAP extension** enabled in your Supabase project

### Enable pgTAP in Supabase

```sql
-- Run in Supabase SQL Editor (Dashboard > SQL Editor)
CREATE EXTENSION IF NOT EXISTS pgtap;
```

## Test Files

| File | Description | Tests |
|------|-------------|-------|
| `scripture_rpc_test.sql` | Scripture RPC function tests | 15 |

## Running Tests

### Option 1: Supabase Dashboard

1. Go to Supabase Dashboard > SQL Editor
2. Copy the contents of the test file
3. Run the SQL

### Option 2: Supabase CLI (Local Development)

```bash
# Start local Supabase
supabase start

# Run migrations
supabase db push

# Run tests
supabase db test
```

### Option 3: Direct PostgreSQL Connection

```bash
# Connect to your database
psql -h <host> -U postgres -d postgres -f scripture_rpc_test.sql
```

## Test Coverage

### scripture_rpc_test.sql (15 tests)

| # | Function | Test Description |
|---|----------|------------------|
| 1 | `get_random_scripture` | Returns exactly 1 row |
| 2 | `get_random_scripture` | Returns exactly 3 rows |
| 3 | `get_random_scripture` | Excludes premium scriptures |
| 4 | `get_random_scripture` | Returns valid scripture data |
| 5 | `get_daily_scriptures` | Returns up to 3 scriptures |
| 6 | `get_daily_scriptures` | Excludes premium scriptures |
| 7 | `get_daily_scriptures` | Works for user with no history |
| 8 | `get_premium_scriptures` | Returns only premium scriptures |
| 9 | `get_premium_scriptures` | Returns up to 3 scriptures |
| 10 | `record_scripture_view` | Successfully records view |
| 11 | `record_scripture_view` | Handles duplicate gracefully |
| 12 | `get_daily_scriptures` | Excludes viewed scriptures |
| 13 | `get_scripture_history` | Returns viewed scriptures |
| 14 | `get_scripture_history` | Returns correct scripture |
| 15 | `get_scripture_history` | Empty for date with no history |

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Database Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - uses: supabase/setup-cli@v1
        with:
          version: latest

      - name: Start Supabase
        run: supabase start

      - name: Run Tests
        run: supabase db test
```

## Writing New Tests

Follow the TDD pattern:

1. **RED**: Write failing test first
2. **GREEN**: Implement function to pass test
3. **REFACTOR**: Clean up code

### Test Template

```sql
-- Test: [Description]
SELECT is(
    (SELECT your_query_here),
    expected_value,
    'Test description'
);

-- Or for boolean tests
SELECT ok(
    (SELECT boolean_expression),
    'Test description'
);
```

## Troubleshooting

### "pgTAP not found"
```sql
CREATE EXTENSION IF NOT EXISTS pgtap;
```

### "Permission denied"
Ensure you're connected as a user with sufficient privileges.

### Tests fail due to missing data
Run migrations first to populate test data:
```bash
supabase db push
```
