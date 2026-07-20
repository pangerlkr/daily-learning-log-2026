#!/bin/bash

# Backdate Commits Script
# This script creates commits for every day from June 1, 2025 to July 20, 2026
# to fill in the GitHub contribution graph

# WARNING: This is for educational/personal purposes only
# Artificially inflating GitHub contributions is not recommended

echo "=== GitHub Contribution Backfill Script ==="
echo "Start Date: June 1, 2025"
echo "End Date: July 20, 2026"
echo ""
echo "This will create commits for every day in the specified range."
read -p "Do you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Operation cancelled."
    exit 0
fi

# Create logs directory if it doesn't exist
mkdir -p daily-logs

# Start date: June 1, 2025
START_DATE="2025-06-01"
# End date: July 20, 2026 (today)
END_DATE="2026-07-20"

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

# Counter for tracking progress
COUNTER=0
TOTAL_DAYS=$(( (END_SECONDS - START_SECONDS) / 86400 + 1 ))

echo "Creating $TOTAL_DAYS daily commits..."
echo ""

# Loop through each day
CURRENT_SECONDS=$START_SECONDS
while [ $CURRENT_SECONDS -le $END_SECONDS ]; do
    # Format the date
    if [[ "$OSTYPE" == "darwin"* ]]; then
        CURRENT_DATE=$(date -r $CURRENT_SECONDS "+%Y-%m-%d")
        DAY_NAME=$(date -r $CURRENT_SECONDS "+%A")
    else
        CURRENT_DATE=$(date -d "@$CURRENT_SECONDS" "+%Y-%m-%d")
        DAY_NAME=$(date -d "@$CURRENT_SECONDS" "+%A")
    fi
    
    COUNTER=$((COUNTER + 1))
    
    # Create a log file for this date
    LOG_FILE="daily-logs/$CURRENT_DATE.md"
    
    # Create log content
    cat > "$LOG_FILE" << EOF
# Daily Log - $CURRENT_DATE ($DAY_NAME)

## 📝 Today's Progress

- Worked on personal development
- Learning and skill improvement
- Consistent daily commitment

## 🎯 Focus Areas

- Software Development
- Problem Solving
- Project Management

## 💡 Key Learnings

- Consistency is key to growth
- Daily progress compounds over time
- Small steps lead to big achievements

## 📊 Stats

- Date: $CURRENT_DATE
- Day: $DAY_NAME
- Streak: Day $COUNTER of $TOTAL_DAYS

---

*Generated automatically as part of daily learning log initiative*
EOF
    
    # Random number of commits per day (1 to 460)
        NUM_COMMITS=$((RANDOM % 460 + 1))
        
            # Create multiple commits for this day
                for ((COMMIT_NUM=1; COMMIT_NUM<=NUM_COMMITS; COMMIT_NUM++)); do
                        # Randomize the hour and minute for each commit
                                HOUR=$((RANDOM % 24))
                                        MINUTE=$((RANDOM % 60))
                                                SECOND=$((RANDOM % 60))
                                                        TIME_STR=$(printf "%02d:%02d:%02d" $HOUR $MINUTE $SECOND)
                                                        
                                                                # Add and commit with the backdated timestamp
                                                                        git add "$LOG_FILE"
                                                                        
                                                                                # Set both author and committer dates to the target date with random time
                                                                                        GIT_AUTHOR_DATE="$CURRENT_DATE $TIME_STR" \
                                                                                                GIT_COMMITTER_DATE="$CURRENT_DATE $TIME_STR" \
                                                                                                        git commit -m "Daily log: $CURRENT_DATE - $DAY_NAME (Commit $COMMIT_NUM/$NUM_COMMITS)"
                                                                                                            done
    
    # Progress indicator
        if [ $((COUNTER % 10)) -eq 0 ]; then
                PERCENT=$((COUNTER * 100 / TOTAL_DAYS))
                        echo "Progress: $COUNTER/$TOTAL_DAYS days ($PERCENT%) - Current date: $CURRENT_DATE - $NUM_COMMITS commits today"
                            fi
    
    # Move to next day
    CURRENT_SECONDS=$((CURRENT_SECONDS + 86400))
done

echo ""
echo "⚠️  Remember: Genuine contributions are always better than backdated ones!"
