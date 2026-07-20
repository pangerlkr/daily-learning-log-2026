#!/bin/bash

# Backdate Commits Script with Custom Date Range
# This script creates commits for every day from a custom start date to end date
# to fill in the GitHub contribution graph

# WARNING: This is for educational/personal purposes only
# Artificially inflating GitHub contributions is not recommended

# Usage: ./backdate_commits.sh [START_DATE] [END_DATE]
# Date format: YYYY-MM-DD
# Example: ./backdate_commits.sh 2025-01-01 2025-12-31

# Color codes for better CLI experience
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Function to print colored output
print_success() { echo -e "${GREEN}✓ $1${NC}"; }
print_error() { echo -e "${RED}✗ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠ $1${NC}"; }
print_info() { echo -e "${CYAN}ℹ $1${NC}"; }
print_header() { echo -e "${BOLD}${BLUE}$1${NC}"; }

# Function to validate date format
validate_date() {
    local date=$1
    if [[ ! $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        return 1
    fi
    # Additional validation using date command
    if [[ "$OSTYPE" == "darwin"* ]]; then
        date -j -f "%Y-%m-%d" "$date" "+%Y-%m-%d" &>/dev/null
    else
        date -d "$date" "+%Y-%m-%d" &>/dev/null
    fi
    return $?
}

# Function to show usage
show_usage() {
    print_header "\n📚 GitHub Contribution Backfill Script"
    echo ""
    print_info "Usage: ./backdate_commits.sh [START_DATE] [END_DATE]"
    echo ""
    echo "  ${BOLD}Arguments:${NC}"
    echo "    START_DATE  Start date in YYYY-MM-DD format"
    echo "    END_DATE    End date in YYYY-MM-DD format"
    echo ""
    echo "  ${BOLD}Examples:${NC}"
    echo "    ./backdate_commits.sh 2025-01-01 2025-12-31"
    echo "    ./backdate_commits.sh 2024-06-01 2026-07-20"
    echo ""
    print_info "Run without arguments to use default range (2025-06-01 to 2026-07-20)"
    echo ""
}

# Parse command-line arguments
if [ $# -eq 0 ]; then
    # No arguments provided, use default range
    START_DATE="2025-06-01"
    END_DATE="2026-07-20"
    print_warning "No date range specified. Using default dates."
elif [ $# -eq 2 ]; then
    START_DATE="$1"
    END_DATE="$2"
    
    # Validate dates
    if ! validate_date "$START_DATE"; then
        print_error "Invalid START_DATE format: $START_DATE"
        print_info "Expected format: YYYY-MM-DD (e.g., 2025-01-01)"
        show_usage
        exit 1
    fi
    
    if ! validate_date "$END_DATE"; then
        print_error "Invalid END_DATE format: $END_DATE"
        print_info "Expected format: YYYY-MM-DD (e.g., 2025-12-31)"
        show_usage
        exit 1
    fi
else
    print_error "Invalid number of arguments"
    show_usage
    exit 1
fi

# Display banner
echo ""
print_header "═══════════════════════════════════════════════════════"
print_header "     GitHub Contribution Backfill Script"
print_header "═══════════════════════════════════════════════════════"
echo ""

# Display configuration
echo "${BOLD}Configuration:${NC}"
echo "  Start Date: ${CYAN}$START_DATE${NC}"
echo "  End Date:   ${CYAN}$END_DATE${NC}"
echo ""

print_info "This will create commits for every day in the specified range."
print_info "Each day will have 1-460 random commits with randomized timestamps."
echo ""

print_warning "IMPORTANT: This is for educational/personal purposes only."
print_warning "Artificially inflating GitHub contributions is not recommended."
echo ""

# Confirmation prompt
read -p "${BOLD}Do you want to continue? (yes/no): ${NC}" confirm
if [ "$confirm" != "yes" ]; then
    print_warning "Operation cancelled by user."
    exit 0
fi

echo ""
print_header "Starting backfill process..."
echo ""

# Create logs directory if it doesn't exist
mkdir -p daily-logs
print_success "Created daily-logs directory"

# Convert dates to seconds since epoch
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS
    START_SECONDS=$(date -j -f "%Y-%m-%d" "$START_DATE" "+%s")
    END_SECONDS=$(date -j -f "%Y-%m-%d" "$END_DATE" "+%s")
else
    # Linux
    START_SECONDS=$(date -d "$START_DATE" "+%s")
    END_SECONDS=$(date -d "$END_DATE" "+%s")
fi

# Calculate total days
TOTAL_DAYS=$(( (END_SECONDS - START_SECONDS) / 86400 + 1 ))

if [ $TOTAL_DAYS -le 0 ]; then
    print_error "END_DATE must be after START_DATE"
    exit 1
fi

print_info "Total days to backfill: ${BOLD}$TOTAL_DAYS${NC}"
echo ""

# Counter for progress
COUNTER=0
CURRENT_SECONDS=$START_SECONDS
TOTAL_COMMITS=0

# Loop through each day
while [ $CURRENT_SECONDS -le $END_SECONDS ]; do
    # Get current date
    if [[ "$OSTYPE" == "darwin"* ]]; then
        CURRENT_DATE=$(date -j -f "%s" "$CURRENT_SECONDS" "+%Y-%m-%d")
    else
        CURRENT_DATE=$(date -d "@$CURRENT_SECONDS" "+%Y-%m-%d")
    fi
    
    # Random number of commits per day (1-460)
    NUM_COMMITS=$((RANDOM % 460 + 1))
    TOTAL_COMMITS=$((TOTAL_COMMITS + NUM_COMMITS))
    
    # Create log file for this day
    LOG_FILE="daily-logs/$CURRENT_DATE.md"
    echo "# Daily Learning Log - $CURRENT_DATE" > "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "## Activity Summary" >> "$LOG_FILE"
    echo "- Number of commits: $NUM_COMMITS" >> "$LOG_FILE"
    echo "- Automated backfill entry" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
    echo "## Notes" >> "$LOG_FILE"
    echo "This entry was created as part of the GitHub contribution backfill process." >> "$LOG_FILE"
    
    # Create multiple commits for this day
    for ((COMMIT_NUM=1; COMMIT_NUM<=NUM_COMMITS; COMMIT_NUM++)); do
        # Randomize the hour and minute for each commit
        HOUR=$((RANDOM % 24))
        MINUTE=$((RANDOM % 60))
        SECOND=$((RANDOM % 60))
        TIME_STR=$(printf "%02d:%02d:%02d" $HOUR $MINUTE $SECOND)
        
        # Add and commit with the backdated timestamp
        git add "$LOG_FILE" 2>/dev/null
        
        # Set both author and committer dates to the backdated timestamp
        GIT_AUTHOR_DATE="$CURRENT_DATE $TIME_STR" \
        GIT_COMMITTER_DATE="$CURRENT_DATE $TIME_STR" \
        git commit -m "Daily learning log for $CURRENT_DATE - Entry $COMMIT_NUM/$NUM_COMMITS" >/dev/null 2>&1
    done
    
    # Progress indicator
    COUNTER=$((COUNTER + 1))
    if [ $((COUNTER % 10)) -eq 0 ]; then
        PERCENT=$((COUNTER * 100 / TOTAL_DAYS))
        echo -ne "${CYAN}Progress: $COUNTER/$TOTAL_DAYS days ($PERCENT%) │ Date: $CURRENT_DATE │ Commits: $NUM_COMMITS${NC}\r"
    fi
    
    # Move to next day
    CURRENT_SECONDS=$((CURRENT_SECONDS + 86400))
done

echo ""
echo ""
print_header "═══════════════════════════════════════════════════════"
print_success "Backfill complete!"
print_header "═══════════════════════════════════════════════════════"
echo ""

echo "${BOLD}Summary:${NC}"
echo "  Days processed:    ${GREEN}$TOTAL_DAYS${NC}"
echo "  Total commits:     ${GREEN}$TOTAL_COMMITS${NC}"
echo "  Average per day:   ${CYAN}$((TOTAL_COMMITS / TOTAL_DAYS))${NC}"
echo ""

print_warning "Remember: Genuine contributions are always better than backdated ones!"
echo ""

print_header "Next steps:"
echo "  ${CYAN}1.${NC} Review the changes: ${YELLOW}git log --oneline --graph${NC}"
echo "  ${CYAN}2.${NC} Check status:       ${YELLOW}git status${NC}"
echo "  ${CYAN}3.${NC} Push to GitHub:     ${YELLOW}git push origin main${NC}"
echo "  ${CYAN}4.${NC} View your contribution graph on GitHub"
echo ""
