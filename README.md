# RISC-V Simulation Log Analyzer - MEDS Module 1
## Description

RISC-V Log Analyzer is a shell-based tool for processing RISC-V simulation
log files. It extracts useful test results and generates summary reports.

The project demonstrates Linux command-line tools, Bash scripting, Git
version control, and Makefiles covered in MEDS Module 1.

The analyzer can determine:

- Total number of tests
- Number of PASS results
- Number of FAIL results
- Number of SKIP results
- Pass rate
- Names of failed tests
- Execution timing statistics

## Project Structure

```text
riscv-log-analyzer/
├── README.md
├── Makefile
├── .gitignore
├── scripts/
│   ├── analyze.sh
│   ├── setup_env.sh
│   └── generate_report.sh
├── test_data/
│   ├── sample_sim.log
│   ├── sample_pass.log
│   └── sample_fail.log
├── output/
└── docs/
    └── USAGE.md
