	@echo "Testing analyzer help..."
	@./scripts/analyze.sh --help > /dev/null
	@echo "Analyzer help test passed."# ============================================================
# RISC-V Log Analyzer Makefile
# ============================================================

# Directories
SCRIPT_DIR = scripts
TEST_DIR = test_data
OUTPUT_DIR = output


# Default target
.PHONY: all test report clean help setup


# ------------------------------------------------------------
# all
# Run analyzer on all test log files
# ------------------------------------------------------------

all:
	@echo "========================================"
	@echo " Running RISC-V Log Analyzer"
	@echo "========================================"
	@echo

	@for log in $(TEST_DIR)/*.log; do \
		echo "Analyzing $$log..."; \
		./$(SCRIPT_DIR)/analyze.sh "$$log" || true; \
		echo; \
	done


# ------------------------------------------------------------
# test
# Test each sample log
# ------------------------------------------------------------

test:
	@echo "Running tests..."
	@echo

	@echo "Testing sample_pass.log..."
	@./$(SCRIPT_DIR)/analyze.sh $(TEST_DIR)/sample_pass.log > /tmp/pass_test.txt; \
	if grep -q "Verdict: PASS" /tmp/pass_test.txt; then \
		echo "PASS: sample_pass.log"; \
	else \
		echo "FAIL: sample_pass.log"; \
		exit 1; \
	fi

	@echo

	@echo "Testing sample_fail.log..."
	@./$(SCRIPT_DIR)/analyze.sh $(TEST_DIR)/sample_fail.log > /tmp/fail_test.txt || true; \
	if grep -q "Verdict: FAIL" /tmp/fail_test.txt; then \
		echo "PASS: sample_fail.log correctly detected failure"; \
	else \
		echo "FAIL: sample_fail.log"; \
		exit 1; \
	fi

	@echo
	@echo "All tests passed!"


# ------------------------------------------------------------
# report
# Generate summary report
# ------------------------------------------------------------

report:
	@./$(SCRIPT_DIR)/generate_report.sh


# ------------------------------------------------------------
# clean
# Remove generated output
# ------------------------------------------------------------

clean:
	@echo "Cleaning generated output..."
	@rm -rf $(OUTPUT_DIR)/*
	@echo "Clean complete."


# ------------------------------------------------------------
# setup
# Check required tools
# ------------------------------------------------------------

setup:
	@./$(SCRIPT_DIR)/setup_env.sh


# ------------------------------------------------------------
# help
# Show available targets
# ------------------------------------------------------------

help:
	@echo "RISC-V Log Analyzer"
	@echo
	@echo "Available targets:"
	@echo "  make all     - Run analyzer on all test logs"
	@echo "  make test    - Run tests on sample logs"
	@echo "  make report  - Generate summary report"
	@echo "  make clean   - Remove generated output"
	@echo "  make setup   - Check required tools"
	@echo "  make help    - Show this help message"
