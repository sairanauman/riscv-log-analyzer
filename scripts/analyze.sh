#!/bin/bash

# Exit immediately if a command fails
# Treat unset variables as errors
# Detect errors inside pipelines
set -euo pipefail


# ============================================================
# RISC-V Simulation Log Analyzer
# ============================================================


# -------------------------
# Default settings
# -------------------------

FORMAT="text"
OUTPUT=""
VERBOSE=false
LOG_FILE=""


# -------------------------
# Show help message
# -------------------------

show_help() {
    echo "Usage: $0 <log_file> [options]"
    echo
    echo "Options:"
    echo "  --format <text|csv>   Output format (default: text)"
    echo "  --output <path>       Save output to a file"
    echo "  --verbose             Show detailed processing information"
    echo "  --help                Show this help message"
}


# -------------------------
# Print error message
# -------------------------

error() {
    echo "Error: $*" >&2
    exit 1
}


# -------------------------
# Calculate statistics
# -------------------------

calculate_statistics() {

    TOTAL=$(grep -c "TEST \(PASS\|FAIL\|SKIP\):" "$LOG_FILE" || true)

    PASSED=$(grep -c "TEST PASS:" "$LOG_FILE" || true)

    FAILED=$(grep -c "TEST FAIL:" "$LOG_FILE" || true)

    SKIPPED=$(grep -c "TEST SKIP:" "$LOG_FILE" || true)


    # Calculate pass rate
    if [ "$TOTAL" -gt 0 ]; then
        PASS_RATE=$(awk -v p="$PASSED" -v t="$TOTAL" \
            'BEGIN { printf "%.1f", (p/t)*100 }')
    else
        PASS_RATE="0.0"
    fi


    # Find failed test names
    FAILED_TESTS=$(grep "TEST FAIL:" "$LOG_FILE" | \
        sed -E 's/.*TEST FAIL: ([^ ]+).*/\1/' || true)


    # Extract execution times
    TIMES=$(grep -oE '\([0-9]+(\.[0-9]+)?s\)' "$LOG_FILE" | \
        sed 's/[()]//g; s/s//' || true)


    if [ -n "$TIMES" ]; then

        MIN_TIME=$(echo "$TIMES" | awk '
            NR==1 { min=$1 }
            $1 < min { min=$1 }
            END { printf "%.2f", min }
        ')

        MAX_TIME=$(echo "$TIMES" | awk '
            NR==1 { max=$1 }
            $1 > max { max=$1 }
            END { printf "%.2f", max }
        ')

        AVG_TIME=$(echo "$TIMES" | awk '
            { sum += $1; count++ }
            END {
                if (count > 0)
                    printf "%.2f", sum/count
                else
                    print "0.00"
            }
        ')

    else

        MIN_TIME="N/A"
        MAX_TIME="N/A"
        AVG_TIME="N/A"

    fi
}


# -------------------------
# Generate text report
# -------------------------

generate_text_report() {

    echo "=== RISC-V Simulation Log Analysis ==="
    echo "Log file: $LOG_FILE"
    echo "Analysis date: $(date '+%Y-%m-%d %H:%M:%S')"

    echo
    echo "--- Results Summary ---"

    echo "Total tests: $TOTAL"
    echo "Passed: $PASSED ($PASS_RATE%)"

    if [ "$TOTAL" -gt 0 ]; then

        FAIL_RATE=$(awk -v f="$FAILED" -v t="$TOTAL" \
            'BEGIN { printf "%.1f", (f/t)*100 }')

        SKIP_RATE=$(awk -v s="$SKIPPED" -v t="$TOTAL" \
            'BEGIN { printf "%.1f", (s/t)*100 }')

    else

        FAIL_RATE="0.0"
        SKIP_RATE="0.0"

    fi

    echo "Failed: $FAILED ($FAIL_RATE%)"
    echo "Skipped: $SKIPPED ($SKIP_RATE%)"


    echo
    echo "--- Failed Tests ---"

    if [ "$FAILED" -eq 0 ]; then

        echo "None"

    else

        COUNT=1

        while IFS= read -r TEST; do

            echo "$COUNT. $TEST"

            COUNT=$((COUNT + 1))

        done <<< "$FAILED_TESTS"

    fi


    echo
    echo "--- Timing Statistics ---"

    echo "Min time: ${MIN_TIME}s"
    echo "Max time: ${MAX_TIME}s"
    echo "Avg time: ${AVG_TIME}s"


    echo

    if [ "$FAILED" -eq 0 ]; then

        echo "--- Verdict: PASS ---"
        echo "Exit code: 0"

    else

        echo "--- Verdict: FAIL ---"
        echo "Exit code: 1"

    fi
}


# -------------------------
# Generate CSV report
# -------------------------

generate_csv_report() {

    echo "metric,value"
    echo "total_tests,$TOTAL"
    echo "passed,$PASSED"
    echo "failed,$FAILED"
    echo "skipped,$SKIPPED"
    echo "pass_rate,$PASS_RATE"
    echo "min_time,$MIN_TIME"
    echo "max_time,$MAX_TIME"
    echo "avg_time,$AVG_TIME"

}


# ============================================================# Parse command-line arguments
# ============================================================
if [ "$#" -eq 0 ]; then
    show_help
    exit 1
fi

# Allow --help without requiring a log file
if [ "$1" = "--help" ]; then
    show_help
    exit 0
fi

# First argument must be the log file
if [[ "$1" != --* ]]; then

    LOG_FILE="$1"
    shift

else

    error "Log file is required"

fi


# Process remaining arguments

while [ "$#" -gt 0 ]; do

    case "$1" in

        --format)

            if [ "$#" -lt 2 ]; then
                error "--format requires a value"
            fi

            FORMAT="$2"
            shift 2
            ;;


        --output)

            if [ "$#" -lt 2 ]; then
                error "--output requires a path"
            fi

            OUTPUT="$2"
            shift 2
            ;;


        --verbose)

            VERBOSE=true
            shift
            ;;


        --help)

            show_help
            exit 0
            ;;


        *)

            error "Unknown option: $1"

    esac

done


# ============================================================
# Validate input
# ============================================================

if [ ! -f "$LOG_FILE" ]; then
    error "Log file does not exist: $LOG_FILE"
fi


if [ ! -r "$LOG_FILE" ]; then
    error "Log file is not readable: $LOG_FILE"
fi


case "$FORMAT" in

    text|csv)
        ;;

    *)
        error "Invalid format: $FORMAT. Use text or csv"

esac


# Verbose information

if [ "$VERBOSE" = true ]; then
    echo "Analyzing log file: $LOG_FILE" >&2
    echo "Output format: $FORMAT" >&2
fi


# ============================================================
# Analyze the log
# ============================================================

calculate_statistics


# ============================================================
# Generate output
# ============================================================

if [ "$FORMAT" = "text" ]; then

    if [ -n "$OUTPUT" ]; then
        generate_text_report > "$OUTPUT"
    else
        generate_text_report
    fi

else

    if [ -n "$OUTPUT" ]; then
        generate_csv_report > "$OUTPUT"
    else
        generate_csv_report
    fi

fi


# ============================================================
# Return correct exit code
# ============================================================

if [ "$FAILED" -eq 0 ]; then
    exit 0
else
    exit 1
fi
