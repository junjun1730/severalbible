#!/bin/bash

# ============================================
# Test Account Creation Script
# Creates premium test accounts for development
# ============================================

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo ""
echo -e "${BLUE}🚀 Creating test accounts with premium subscriptions...${NC}"
echo ""

# Check if supabase CLI is installed
if ! command -v supabase &> /dev/null; then
    echo -e "${RED}❌ Error: Supabase CLI is not installed${NC}"
    echo "Please install it first: https://supabase.com/docs/guides/cli"
    exit 1
fi

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SQL_FILE="$PROJECT_ROOT/supabase/snippets/create_test_accounts.sql"

# Check if SQL file exists
if [ ! -f "$SQL_FILE" ]; then
    echo -e "${RED}❌ Error: SQL file not found at $SQL_FILE${NC}"
    exit 1
fi

# Check if Docker is running (required for local Supabase)
if ! docker info > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Docker is not running. Cannot use local Supabase database.${NC}"
    echo ""
    echo -e "${BLUE}To create test accounts, please:${NC}"
    echo "1. Open your Supabase Dashboard: https://supabase.com/dashboard"
    echo "2. Navigate to SQL Editor"
    echo "3. Copy and paste the contents of: $SQL_FILE"
    echo "4. Click 'Run' to execute the script"
    echo ""
    echo -e "${YELLOW}Or start Docker and run this script again.${NC}"
    echo ""
    exit 1
fi

# Execute the SQL script
cd "$PROJECT_ROOT"
echo -e "${YELLOW}Executing SQL script...${NC}"

# Use psql to execute the SQL file
supabase db reset --db-url "$(supabase status -o env | grep DATABASE_URL | cut -d '=' -f2-)" < "$SQL_FILE" 2>/dev/null

# If that fails, try alternative method
if [ $? -ne 0 ]; then
    echo -e "${RED}Failed to execute via psql. Trying alternative method...${NC}"
    cat "$SQL_FILE" | supabase db execute 2>/dev/null
fi

# Check if execution was successful
if [ ${PIPESTATUS[0]} -eq 0 ] || [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Test accounts created successfully!${NC}"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📧 Login Credentials:${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}Account 1 (General Premium Testing):${NC}"
    echo "  Email:    premium.test@onemessage.app"
    echo "  Password: Premium123!"
    echo "  UUID:     aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa"
    echo ""
    echo -e "${YELLOW}Account 2 (Prayer Note Testing):${NC}"
    echo "  Email:    prayer.test@onemessage.app"
    echo "  Password: Prayer123!"
    echo "  UUID:     bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
    echo ""
    echo -e "${YELLOW}Account 3 (Scripture Delivery Testing):${NC}"
    echo "  Email:    scripture.test@onemessage.app"
    echo "  Password: Scripture123!"
    echo "  UUID:     cccccccc-cccc-cccc-cccc-cccccccccccc"
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}All accounts have:${NC}"
    echo "  • Tier: premium"
    echo "  • Subscription: monthly_premium (active)"
    echo "  • Expires: 30 days from now"
    echo "  • Email: confirmed"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${YELLOW}💡 Tip: Use the debug email login UI in the app (debug mode only)${NC}"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Failed to create test accounts${NC}"
    echo "Check the error message above for details"
    exit 1
fi
