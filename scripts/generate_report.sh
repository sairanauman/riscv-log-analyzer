#!/bin/bash

# Stop if a command fails
# Treat unset variables as errors
# Detect errors inside pipelines
set -euo pipefail


# ============================================================
# RISC-V Log Analyzer - Report Generator
# ============================================================


# Input and output locations

INPUT_DIR="test_data"
OUTPUT_DIR="output"
REPORT_FILE="$OUTPUT_DIR/summary_report.txt"


# ------------------------------------------------------------
# Create output directory if it does not exist
# ------------------------------------------------------------

mkdir -p "$OUTPUT_DIR"


# ------------------------------------------------------------
# Generate report
# ------------------------------------------------------------

generate_report() {

    echo "========================================"
    echo " RISC-V Simulation Summary Report"
    echo "========================================"
    echo

    echo "Generated: $(date '+%Y-%m-%d %H:%M:%S')"
    echo

    echo "Test log files:"
    echo "----------------------------------------"


    # Process every .log file in test_data
    for log_file in "$INPUT_DIR"/*.log; do

        # Check whether a log file actually exists
        if [ ! -f "$log_file" ]; then
            continue
        fi


        # Count test results
        total=$(grep -cE "TEST (PASS|FAIL|SKIP):" "$log_file" || true)

        passed=$(grep -c "TEST PASS:" "$log_file" || true)

        failed=$(grep -c "TEST FAIL:" "$log_file" || true)

        skipped=$(grep -c "TEST SKIP:" "$log_file" || true)


        # Calculate pass percentage
        if [ "$total" -gt 0 ]; then

            pass_rate=$(awk -v p="$passed" -v t="$total" \
                'BEGIN { printf "%.1f", (p/t)*100 }')

        else

            pass_rate="0.0"

        fi


        echo
        echo "File: $log_file"
        echo "Total tests: $total"
        echo "Passed: $passed"
        echo "Failed: $failed"
        echo "Skipped: $skipped"
        echo "Pass rate: $pass_rate%"


        # Show verdict
        if [ "$failed" -eq 0 ]; then

            echo "Verdict: PASS"

        else

            echo "Verdict: FAIL"

        fi

    done


    echo
    echo "========================================"
    echo " End of Report"
    echo "========================================"
}


# ------------------------------------------------------------
# Generate and save the report
# ------------------------------------------------------------

generate_report > "$REPORT_FILE"


echo "Report generated successfully:"
echo "$REPORT_FILE"
