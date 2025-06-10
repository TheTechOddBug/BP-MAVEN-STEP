#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source getDynamicVars.sh
source set_npmrc.sh

TASK_STATUS=0

# Set the codebase location
CODEBASE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
logInfoMessage "I'll build the code available at [$CODEBASE_LOCATION]"
sleep  $SLEEP_DURATION

# Set the npmrc file default location
set_npmrc

# Change to the codebase directory
cd "${CODEBASE_LOCATION}" || { logErrorMessage "Failed to change directory to $CODEBASE_LOCATION"; exit 1; }

# Main logic to check conditions and call fetch_service_details
if [ -n "$SOURCE_VARIABLE_REPO" ]; then
    # Check if INSTRUCTION is provided
    if [ -n "$INSTRUCTION" ]; then
        echo "INSTRUCTION is provided. Skipping fetching details from SOURCE_VARIABLE_REPO."
    else
        echo "Fetching details from $SOURCE_VARIABLE_REPO as INSTRUCTION is not provided."
        fetch_service_details
    fi

    # Switch Java version based on JAVA_VERSION
    case "$JAVA_VERSION" in
        "8")  export JAVA_HOME=$JAVA_HOME_8 ;;
        "11") export JAVA_HOME=$JAVA_HOME_11 ;;
        "17") export JAVA_HOME=$JAVA_HOME_17 ;;
        "21") export JAVA_HOME=$JAVA_HOME_21 ;;
        *)
            logErrorMessage "Unsupported JAVA_VERSION: $JAVA_VERSION"
            exit 1
            ;;
    esac

    # Switch Maven version based on MAVEN_VERSION
    case "$MAVEN_VERSION" in
        "3.6.3") export MAVEN_HOME=$MAVEN_HOME_363 ;;
        "3.8.1") export MAVEN_HOME=$MAVEN_HOME_381 ;;
        "3.5.4") export MAVEN_HOME=$MAVEN_HOME_354 ;;
        "3.9.9") export MAVEN_HOME=$MAVEN_HOME_399 ;;
        *)
            logErrorMessage "Unsupported MAVEN_VERSION: $MAVEN_VERSION"
            exit 1
            ;;
    esac
    # Update PATH to include Java and Maven binaries
    export PATH="$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH"

    # Log the selected versions
    echo "Using JDK version: $JAVA_VERSION ($JAVA_HOME)"
    echo "Using Maven version: $MAVEN_VERSION ($MAVEN_HOME)"
else
    logErrorMessage "SOURCE_VARIABLE_REPO is not defined. Skipping fetching details from SOURCE_VARIABLE_REPO."
    # exit 1
fi

# Switch maven INSTRUCTION based on INSTRUCTION_TYPE
if [ -z "$INSTRUCTION" ]; then
    case "$INSTRUCTION_TYPE" in
        "BUILD")  export INSTRUCTION=$MAVEN_BUILD_INSTRUCTION ;;
        "DEPLOY") export INSTRUCTION=$MAVEN_DEPLOY_INSTRUCTION ;;
        "TEST")   export INSTRUCTION=$MAVEN_TEST_INSTRUCTION ;;
        "CUSTOM") export INSTRUCTION=$MAVEN_CUSTOM_INSTRUCTION ;;
        *) logErrorMessage "Unsupported $INSTRUCTION_TYPE: Executing default mvn $INSTRUCTION"
            ;;
    esac
fi


# Switch maven INSTRUCTION based on INSTRUCTION_TYPE
# case "$INSTRUCTION_TYPE" in
#     "BUILD")  export INSTRUCTION=$INSTRUCTION ;;
#     "DEPLOY") export INSTRUCTION=$MAVEN_DEPLOY_INSTRUCTION ;;
#     "TEST")   export INSTRUCTION=$MAVEN_TEST_INSTRUCTION ;;
#     "CUSTOM") export INSTRUCTION=$MAVEN_CUSTOM_INSTRUCTION ;;
#     *)
#         export INSTRUCTION=$INSTRUCTION
#         logErrorMessage "Unsupported INSTRUCTION_TYPE: Executing default mvn $INSTRUCTION"
#         exit 1
#         ;;
# esac

## Check if ENABLE_MAVEN_SILENT_MODE is set
MAVEN_OPTIONS=""
if [[ "${ENABLE_MAVEN_SILENT_MODE,,}" == "true" ]]; then
    MAVEN_OPTIONS="--no-transfer-progress"
    # MAVEN_OPTIONS="-B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn"
fi

# Ensure INSTRUCTION is set before executing Maven
if [ -z "$INSTRUCTION" ]; then
    logErrorMessage "INSTRUCTION is not set. Exiting..."
    exit 1
    TASK_STATUS=$?
fi

# Execute the Maven command
logInfoMessage "Executing mvn $INSTRUCTION $MAVEN_OPTIONS"
mvn $INSTRUCTION $MAVEN_OPTIONS

# # Custom failure threshold logic for tests
# if [[ "$INSTRUCTION_TYPE" == "TEST" ]]; then
#     REPORTS=$(find target/surefire-reports/ -name "TEST-*.xml" 2>/dev/null)
#     TOTAL=0
#     FAIL=0
#     for REPORT in $REPORTS; do
#         T=$(grep -oP '(?<=tests=")[0-9]+' "$REPORT" | awk '{s+=$1} END {print s}')
#         F=$(grep -oP '(?<=failures=")[0-9]+' "$REPORT" | awk '{s+=$1} END {print s}')
#         E=$(grep -oP '(?<=errors=")[0-9]+' "$REPORT" | awk '{s+=$1} END {print s}')
#         TOTAL=$((TOTAL + T))
#         FAIL=$((FAIL + F + E))
#     done
#     if [[ "$TOTAL" -eq 0 ]]; then
#         logErrorMessage "No tests found or unable to parse test report."
#         exit 1
#     fi
#     FAIL_PERCENT=$(( 100 * FAIL / TOTAL ))
#     THRESHOLD=20 # Set your threshold percentage here
#     echo "Test failure rate: $FAIL_PERCENT% (Threshold: $THRESHOLD%)"
#     if (( FAIL_PERCENT > THRESHOLD )); then
#         logErrorMessage "Test failure rate ($FAIL_PERCENT%) exceeded threshold ($THRESHOLD%). Failing build."
#         exit 1  
#     fi
# fi

# if [[ "$INSTRUCTION_TYPE" == "TEST" ]]; then
#     echo "CODEBASE_LOCATION is: $CODEBASE_LOCATION"
#     ls -l "$CODEBASE_LOCATION/Results"

#     REPORT_HTML=$(find "$CODEBASE_LOCATION/Results" -type f -name "*.html" -printf "%T@ %p\n" | sort -nr | head -1 | awk '{print $2}')
#     THRESHOLD="${TEST_FAILURE_THRESHOLD:-50}"

#     if [[ -z "$REPORT_HTML" || ! -f "$REPORT_HTML" ]]; then
#         logErrorMessage "Could not find any HTML report file under $CODEBASE_LOCATION/Results"
#         exit 1
#     fi

#     echo "Using report file: $REPORT_HTML"

#     # Extract values from HTML using grep + sed
#     TOTAL=$(xmllint --html --xpath "string(//tr[td[contains(., 'Total Tests executed')]]/td[2])" "$REPORT_HTML" 2>/dev/null)
#     # echo "Total Tests executed : $TOTAL"
#     PASS=$(xmllint --html --xpath "string(//tr[td[contains(., 'Total Pass Test count')]]/td[2])" "$REPORT_HTML" 2>/dev/null)
#     # echo "Total Pass Test count: $PASS"
#     FAIL=$(xmllint --html --xpath "string(//tr[td[contains(., 'Total Fail Test count')]]/td[2])" "$REPORT_HTML" 2>/dev/null)
#     # echo "Total Fail Test count: $FAIL"

#     # if [[ -z "$TOTAL" || -z "$PASS" || -z "$FAIL" || "$TOTAL" -eq 0 ]]; then
#     #     logErrorMessage "Could not parse test counts from $REPORT_HTML"
#     #     exit 1
#     # fi

#     # Calculate fail percentage
#     FAIL_PERCENT=$(( 100 * FAIL / TOTAL ))

#     echo "Total Tests executed : $TOTAL"
#     echo "Total Pass Test count: $PASS"
#     echo "Total Fail Test count: $FAIL"
#     echo "Test failure rate    : $FAIL_PERCENT% (Threshold: $THRESHOLD%)"

#     if (( FAIL_PERCENT > THRESHOLD )); then
#         logErrorMessage "Test failure rate ($FAIL_PERCENT%) exceeded threshold ($THRESHOLD%). Failing build."
#         exit 1
#     else
#         echo "✅ Test failure rate is within threshold."
#     fi
# fi

# Default XML scan (always runs for TEST)
if [[ "$INSTRUCTION_TYPE" == "TEST" ]]; then
    REPORTS=$(find target/surefire-reports/ -name "TEST-*.xml" 2>/dev/null)
    TOTAL=0
    FAIL=0
    for REPORT in $REPORTS; do
        T=$(grep -oP '(?<=tests=")[0-9]+' "$REPORT" | awk '{s+=$1} END {print s}')
        F=$(grep -oP '(?<=failures=")[0-9]+' "$REPORT" | awk '{s+=$1} END {print s}')
        E=$(grep -oP '(?<=errors=")[0-9]+' "$REPORT" | awk '{s+=$1} END {print s}')
        TOTAL=$((TOTAL + T))
        FAIL=$((FAIL + F + E))
    done
    if [[ "$TOTAL" -eq 0 ]]; then
        logErrorMessage "No tests found or unable to parse test report."
        exit 1
    fi
    FAIL_PERCENT=$(( 100 * FAIL / TOTAL ))
    THRESHOLD=50 # Set your threshold percentage here
    echo "Test failure rate: $FAIL_PERCENT% (Threshold: $THRESHOLD%)"
    if (( FAIL_PERCENT > THRESHOLD )); then
        logErrorMessage "Test failure rate ($FAIL_PERCENT%) exceeded threshold ($THRESHOLD%). Failing build."
        # exit 1  
    fi
fi

# Custom HTML scan (only runs if ENABLE_CUSTOM_HTML_SCAN is true)
if [[ "$INSTRUCTION_TYPE" == "TEST" && "${ENABLE_CUSTOM_HTML_SCAN,,}" == "true" ]]; then
    echo "CODEBASE_LOCATION is: $CODEBASE_LOCATION"
    ls -l "$CODEBASE_LOCATION/Results"

    REPORT_HTML=$(find "$CODEBASE_LOCATION/Results" -type f -name "*.html" -printf "%T@ %p\n" | sort -nr | head -1 | awk '{print $2}')
    THRESHOLD="${TEST_FAILURE_THRESHOLD:-50}"

    if [[ -z "$REPORT_HTML" || ! -f "$REPORT_HTML" ]]; then
        logErrorMessage "Could not find any HTML report file under $CODEBASE_LOCATION/Results"
        exit 1
    fi

    echo "Using report file: $REPORT_HTML"

    TOTAL=$(xmllint --html --xpath "string(//tr[td[contains(., 'Total Tests executed')]]/td[2])" "$REPORT_HTML" 2>/dev/null)
    PASS=$(xmllint --html --xpath "string(//tr[td[contains(., 'Total Pass Test count')]]/td[2])" "$REPORT_HTML" 2>/dev/null)
    FAIL=$(xmllint --html --xpath "string(//tr[td[contains(., 'Total Fail Test count')]]/td[2])" "$REPORT_HTML" 2>/dev/null)

    FAIL_PERCENT=$(( 100 * FAIL / TOTAL ))

    echo "Total Tests executed : $TOTAL"
    echo "Total Pass Test count: $PASS"
    echo "Total Fail Test count: $FAIL"
    echo "Test failure rate    : $FAIL_PERCENT% (Threshold: $THRESHOLD%)"

    if (( FAIL_PERCENT > THRESHOLD )); then
        logErrorMessage "Test failure rate ($FAIL_PERCENT%) exceeded threshold ($THRESHOLD%). Failing build."
        # exit 1
    else
        echo "✅ Test failure rate is within threshold."
    fi
fi

# Capture the task status
TASK_STATUS=$?

# Save the task status
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}