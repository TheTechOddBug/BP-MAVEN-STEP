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

# Capture the task status
TASK_STATUS=$?

# Save the task status
saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}