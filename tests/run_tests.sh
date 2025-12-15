#!/bin/bash
#
# EEveon Test Suite
# Tests all components locally
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Base directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

echo "╔══════════════════════════════════════════════════════════════════╗"
echo "║              EEveon CI/CD - Test Suite                          ║"
echo "╚══════════════════════════════════════════════════════════════════╝"
echo ""

# Test helper functions
test_start() {
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${BLUE}[TEST $TESTS_RUN]${NC} $1"
}

test_pass() {
    TESTS_PASSED=$((TESTS_PASSED + 1))
    echo -e "${GREEN}  ✓ PASS${NC} $1"
}

test_fail() {
    TESTS_FAILED=$((TESTS_FAILED + 1))
    echo -e "${RED}  ✗ FAIL${NC} $1"
}

test_info() {
    echo -e "${YELLOW}  ℹ INFO${NC} $1"
}

# Create test environment
setup_test_env() {
    test_start "Setting up test environment"
    
    TEST_DIR="/tmp/eeveon-test-$$"
    mkdir -p "$TEST_DIR"/{config,deployments,logs,test-repo,test-deploy}
    
    # Create test config
    cat > "$TEST_DIR/config/pipeline.json" << 'EOF'
{
  "test-project": {
    "repo_url": "file:///tmp/eeveon-test-repo",
    "branch": "main",
    "deploy_path": "/tmp/eeveon-test-deploy",
    "deployment_dir": "/tmp/eeveon-test-deployments/test-project",
    "poll_interval": 120,
    "enabled": true,
    "last_commit": null,
    "created_at": "2025-12-16T00:00:00"
  }
}
EOF
    
    # Create test notifications config
    cat > "$TEST_DIR/config/notifications.json" << 'EOF'
{
  "slack": {
    "enabled": false,
    "webhook_url": ""
  },
  "discord": {
    "enabled": false,
    "webhook_url": ""
  },
  "telegram": {
    "enabled": false,
    "bot_token": "",
    "chat_id": ""
  },
  "email": {
    "enabled": false,
    "to": "",
    "from": ""
  },
  "webhook": {
    "enabled": false,
    "url": ""
  }
}
EOF
    
    # Create test health checks config
    cat > "$TEST_DIR/config/health_checks.json" << 'EOF'
{
  "test-project": {
    "enabled": true,
    "http_url": "",
    "http_method": "GET",
    "http_expected_code": 200,
    "http_timeout": 5,
    "script_path": "",
    "max_retries": 2,
    "retry_delay": 1,
    "rollback_on_failure": false
  }
}
EOF
    
    test_pass "Test environment created at $TEST_DIR"
}

# Test 1: Check dependencies
test_dependencies() {
    test_start "Checking required dependencies"
    
    local missing=()
    
    for cmd in git jq rsync python3 curl; do
        if command -v $cmd &> /dev/null; then
            test_pass "$cmd is installed"
        else
            test_fail "$cmd is NOT installed"
            missing+=($cmd)
        fi
    done
    
    if [ ${#missing[@]} -gt 0 ]; then
        test_info "Missing dependencies: ${missing[*]}"
        test_info "Install with: sudo apt install ${missing[*]}"
    fi
}

# Test 2: Check file structure
test_file_structure() {
    test_start "Checking file structure"
    
    local files=(
        "bin/eeveon"
        "scripts/monitor.sh"
        "scripts/deploy.sh"
        "scripts/notify.sh"
        "scripts/rollback.sh"
        "scripts/health_check.sh"
        "install.sh"
        "README.md"
        "LICENSE"
        "setup.py"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$BASE_DIR/$file" ]; then
            test_pass "$file exists"
        else
            test_fail "$file is missing"
        fi
    done
}

# Test 3: Check script permissions
test_permissions() {
    test_start "Checking script permissions"
    
    local scripts=(
        "bin/eeveon"
        "scripts/monitor.sh"
        "scripts/deploy.sh"
        "scripts/notify.sh"
        "scripts/rollback.sh"
        "scripts/health_check.sh"
        "install.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [ -x "$BASE_DIR/$script" ]; then
            test_pass "$script is executable"
        else
            test_fail "$script is NOT executable"
            test_info "Fix with: chmod +x $BASE_DIR/$script"
        fi
    done
}

# Test 4: Test CLI help
test_cli_help() {
    test_start "Testing CLI help command"
    
    if python3 "$BASE_DIR/bin/eeveon" --help &> /dev/null; then
        test_pass "CLI help works"
    else
        test_fail "CLI help failed"
    fi
}

# Test 5: Test notification script
test_notifications() {
    test_start "Testing notification system"
    
    # Test with disabled notifications (should not fail)
    if bash "$BASE_DIR/scripts/notify.sh" "test-project" "success" "Test message" "abc123" "Test commit" 2>/dev/null; then
        test_pass "Notification script runs without errors"
    else
        test_fail "Notification script failed"
    fi
}

# Test 6: Test rollback script structure
test_rollback_structure() {
    test_start "Testing rollback script structure"
    
    # Check if script has required functions
    if grep -q "list_versions" "$BASE_DIR/scripts/rollback.sh"; then
        test_pass "Rollback script has list_versions function"
    else
        test_fail "Rollback script missing list_versions function"
    fi
    
    if grep -q "perform_rollback" "$BASE_DIR/scripts/rollback.sh"; then
        test_pass "Rollback script has perform_rollback function"
    else
        test_fail "Rollback script missing perform_rollback function"
    fi
}

# Test 7: Test health check script structure
test_health_check_structure() {
    test_start "Testing health check script structure"
    
    if grep -q "http_health_check" "$BASE_DIR/scripts/health_check.sh"; then
        test_pass "Health check script has http_health_check function"
    else
        test_fail "Health check script missing http_health_check function"
    fi
    
    if grep -q "retry_health_check" "$BASE_DIR/scripts/health_check.sh"; then
        test_pass "Health check script has retry mechanism"
    else
        test_fail "Health check script missing retry mechanism"
    fi
}

# Test 8: Test JSON configuration validity
test_json_configs() {
    test_start "Testing JSON configuration files"
    
    if jq empty "$TEST_DIR/config/pipeline.json" 2>/dev/null; then
        test_pass "pipeline.json is valid JSON"
    else
        test_fail "pipeline.json is invalid JSON"
    fi
    
    if jq empty "$TEST_DIR/config/notifications.json" 2>/dev/null; then
        test_pass "notifications.json is valid JSON"
    else
        test_fail "notifications.json is invalid JSON"
    fi
    
    if jq empty "$TEST_DIR/config/health_checks.json" 2>/dev/null; then
        test_pass "health_checks.json is valid JSON"
    else
        test_fail "health_checks.json is invalid JSON"
    fi
}

# Test 9: Test deployment script syntax
test_deploy_script_syntax() {
    test_start "Testing deployment script syntax"
    
    if bash -n "$BASE_DIR/scripts/deploy.sh" 2>/dev/null; then
        test_pass "deploy.sh has valid syntax"
    else
        test_fail "deploy.sh has syntax errors"
    fi
}

# Test 10: Test monitor script syntax
test_monitor_script_syntax() {
    test_start "Testing monitor script syntax"
    
    if bash -n "$BASE_DIR/scripts/monitor.sh" 2>/dev/null; then
        test_pass "monitor.sh has valid syntax"
    else
        test_fail "monitor.sh has syntax errors"
    fi
}

# Test 11: Test Python CLI syntax
test_python_cli_syntax() {
    test_start "Testing Python CLI syntax"
    
    if python3 -m py_compile "$BASE_DIR/bin/eeveon" 2>/dev/null; then
        test_pass "eeveon CLI has valid Python syntax"
    else
        test_fail "eeveon CLI has Python syntax errors"
    fi
}

# Test 12: Test documentation exists
test_documentation() {
    test_start "Testing documentation"
    
    local docs=(
        "README.md"
        "CHANGELOG.md"
        "CONTRIBUTING.md"
        "LICENSE"
        "ROADMAP.md"
        "FUTURE_ROADMAP.md"
    )
    
    for doc in "${docs[@]}"; do
        if [ -f "$BASE_DIR/$doc" ]; then
            test_pass "$doc exists"
        else
            test_fail "$doc is missing"
        fi
    done
}

# Cleanup
cleanup_test_env() {
    test_start "Cleaning up test environment"
    
    if [ -d "$TEST_DIR" ]; then
        rm -rf "$TEST_DIR"
        test_pass "Test environment cleaned up"
    fi
}

# Run all tests
main() {
    echo "Starting tests..."
    echo ""
    
    setup_test_env
    test_dependencies
    test_file_structure
    test_permissions
    test_cli_help
    test_notifications
    test_rollback_structure
    test_health_check_structure
    test_json_configs
    test_deploy_script_syntax
    test_monitor_script_syntax
    test_python_cli_syntax
    test_documentation
    cleanup_test_env
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║                      Test Results                                ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "Tests Run:    ${BLUE}$TESTS_RUN${NC}"
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
    echo ""
    
    if [ $TESTS_FAILED -eq 0 ]; then
        echo -e "${GREEN}✓ All tests passed!${NC}"
        echo ""
        return 0
    else
        echo -e "${RED}✗ Some tests failed!${NC}"
        echo ""
        return 1
    fi
}

# Run tests
main
