#!/bin/bash

# Remove Backdated Commits Script
# This script helps remove the backdated commits created by backdate_commits.sh
# WARNING: This will rewrite Git history. Use with caution!

# Usage: ./remove_backdated_commits.sh [START_DATE] [END_DATE]
# Date format: YYYY-MM-DD
# Example: ./remove_backdated_commits.sh 2025-01-01 2025-12-31

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
print_success() { echo -e "${GREEN}▸ $1${NC}"; }
print_error() { echo -e "${RED}▸ $1${NC}"; }
print_warning() { echo -e "${YELLOW}▸ $1${NC}"; }
print_info() { echo -e "${CYAN}▸ $1${NC}"; }
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

# Show usage
show_usage() {
    echo ""
    print_info "${BOLD}Arguments:${NC}"
    echo "    START_DATE  Start date in YYYY-MM-DD format"
    echo "    END_DATE    End date in YYYY-MM-DD format"
    echo ""
    print_info "${BOLD}Examples:${NC}"
    echo "    ./remove_backdated_commits.sh 2025-01-01 2025-12-31"
    echo "    ./remove_backdated_commits.sh 2024-06-01 2026-07-20"
    echo ""
    print_info "Run without arguments to remove ALL backdated commits (daily-logs directory)"
}

# Parse command-line arguments
if [ $# -eq 0 ]; then
    # No arguments provided, will remove all commits related to daily-logs
    START_DATE=""
    END_DATE=""
    print_warning "No date range specified. This will attempt to remove ALL backdated commits."
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
print_header "═══════════════════════════════════════════════"
print_header "    Remove Backdated Commits Script"
print_header "═══════════════════════════════════════════════"
echo ""

# Display configuration
echo "${BOLD}Configuration:${NC}"
if [ -n "$START_DATE" ]; then
    echo "  Start Date: ${CYAN}$START_DATE${NC}"
    echo "  End Date:   ${CYAN}$END_DATE${NC}"
else
    echo "  Mode: ${CYAN}Remove ALL backdated commits${NC}"
fi
echo ""

print_warning "⚠️  IMPORTANT WARNINGS ⚠️"
print_warning "This operation will:"
print_warning "• Rewrite Git history"
print_warning "• Remove commits and associated daily-logs files"
print_warning "• Require force push to update remote repository"
print_warning "• Cannot be undone easily once pushed"
echo ""

# Confirmation prompt
read -p "${BOLD}Do you want to continue? (yes/no): ${NC}" confirm
if [ "$confirm" != "yes" ]; then
    print_warning "Operation cancelled by user."
    exit 0
fi

echo ""
print_header "Starting removal process..."
echo ""

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository!"
    exit 1
fi

# Create backup branch
BACKUP_BRANCH="backup-before-removal-$(date +%Y%m%d-%H%M%S)"
print_info "Creating backup branch: $BACKUP_BRANCH"
git branch "$BACKUP_BRANCH"
print_success "Backup created successfully"
echo ""

# Method: Remove commits by filtering them out
print_info "Removing backdated commits..."

if [ -n "$START_DATE" ]; then
    # Remove daily-logs files and commits (date range filtering happens at file level)
    print_info "Filtering commits between $START_DATE and $END_DATE..."
    
    # Use git filter-branch to remove the daily-logs directory
    git filter-branch --force --index-filter \
        'git rm -rf --cached --ignore-unmatch daily-logs/' \
        --prune-empty --tag-name-filter cat -- --all
    
else
    # Remove all daily-logs related commits
    print_info "Removing all daily-logs commits..."
    
    git filter-branch --force --index-filter \
        'git rm -rf --cached --ignore-unmatch daily-logs/' \
        --prune-empty --tag-name-filter cat -- --all
fi

print_success "Commits removed from history"
echo ""

# Clean up
print_info "Cleaning up..."
git for-each-ref --format='delete %(refname)' refs/original | git update-ref --stdin
git reflog expire --expire=now --all
git gc --prune=now --aggressive

print_success "Cleanup complete!"
echo ""

print_header "═══════════════════════════════════════════════"
print_success "Removal process completed successfully!"
print_header "═══════════════════════════════════════════════"
echo ""

echo "${BOLD}Summary:${NC}"
echo "  Days processed:      ${GREEN}Complete${NC}"
echo "  Backup branch:       ${CYAN}$BACKUP_BRANCH${NC}"
echo ""

print_warning "⚠️  IMPORTANT: Next steps"
echo ""
print_header "Next steps:"
echo "  ${CYAN}1.${NC} Review the changes: ${YELLOW}git log --oneline --graph${NC}"
echo "  ${CYAN}2.${NC} Check status:       ${YELLOW}git status${NC}"
echo "  ${CYAN}3.${NC} Force push:         ${YELLOW}git push origin main --force${NC}"
echo "  ${CYAN}4.${NC} If needed, restore: ${YELLOW}git reset --hard $BACKUP_BRANCH${NC}"
echo ""

print_warning "Remember: Force pushing will overwrite remote history!"
echo ""
