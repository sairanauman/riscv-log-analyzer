#!/bin/bash

# Stop the script if an error occurs
# Treat unset variables as errors
# Detect errors inside pipelines
set -euo pipefail


# ============================================================
# RISC-V Log Analyzer - Environment Setup
# ============================================================


# List of required commands


#!/bin/bash

echo "========================================"
echo " RISC-V Log Analyzer Environment Check"
echo "========================================"
echo

REQUIRED_TOOLS="bash grep awk sed sort uniq cut wc head tail find date"

MISSING=0

for tool in $REQUIRED_TOOLS
do
    if command -v "$tool" >/dev/null 2>&1
    then
        echo "[OK] $tool"
    else
        echo "[MISSING] $tool is not installed"
        MISSING=$((MISSING + 1))
    fi
done

echo
echo "========================================"

if [ "$MISSING" -eq 0 ]
then
    echo "Environment check passed."
    exit 0
else
    echo "Environment check failed."
    echo "$MISSING required tool(s) are missing."
    exit 1
fi

# ------------------------------------------------------------
# Check whether a command exists
# ------------------------------------------------------------

check_tool() {

    local tool="$1"

    if command -v "$tool" >/dev/null 2>&1; then

        echo "[OK] $tool found at $(command -v "$tool")"

    else

        echo "[MISSING] $tool is not installed"
        return 1

    fi
}


# ------------------------------------------------------------
# Check all required tools
# ------------------------------------------------------------

main() {

    echo "========================================"
    echo " RISC-V Log Analyzer Environment Check"
    echo "========================================"
    echo

    local missing=0

    for tool in "${REQUIRED_TOOLS[@]}"; do

        if ! check_tool "$tool"; then
            missing=$((missing + 1))
        fi

    done

    echo
    echo "========================================"

    if [ "$missing" -eq 0 ]; then

        echo "Environment check passed."
        echo "All required tools are available."
        return 0

    else

        echo "Environment check failed."
        echo "$missing required tool(s) are missing."
        return 1

    fi
}


# Run the main function
main
exit $?
