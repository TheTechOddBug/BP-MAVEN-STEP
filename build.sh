#!/bin/bash
source /opt/buildpiper/shell-functions/functions.sh
source /opt/buildpiper/shell-functions/log-functions.sh
source getDynamicVars.sh

CODEBASE_LOCATION="${WORKSPACE}"/"${CODEBASE_DIR}"
logInfoMessage "I'll build the code available at [$CODEBASE_LOCATION]"
sleep  $SLEEP_DURATION

# Change to the codebase directory
cd "${CODEBASE_LOCATION}" || { logErrorMessage "Failed to change directory to $CODEBASE_LOCATION"; exit 1; }

# Main logic to check conditions and call fetch_service_details
if [ -n "$SOURCE_VARIABLE_REPO" ]; then
    # Check if JAVA_VERSION, MAVEN_VERSION, and INSTRUCTION are provided
    # if [ -n "$INSTRUCTION" ] && [ -n "$JAVA_VERSION" ] && [ -n "$MAVEN_VERSION" ]; then
    if [ -n "$INSTRUCTION" ]; then
        echo "INSTRUCTION is provided. Skipping fetching details from SOURCE_VARIABLE_REPO."
    else
        echo "Fetching details from $SOURCE_VARIABLE_REPO as INSTRUCTION is not provided."
        fetch_service_details
    fi
        # Switch Java version
    if [ "$JAVA_VERSION" == "8" ]; then
      export JAVA_HOME=$JAVA_HOME_8
    elif [ "$JAVA_VERSION" == "11" ]; then
      export JAVA_HOME=$JAVA_HOME_11
    elif [ "$JAVA_VERSION" == "17" ]; then
      export JAVA_HOME=$JAVA_HOME_17
      elif [ "$JAVA_VERSION" == "21" ]; then
      export JAVA_HOME=$JAVA_HOME_21
    fi

    # Switch Maven version
    if [ "$MAVEN_VERSION" == "3.6.3" ]; then
      export MAVEN_HOME=$MAVEN_HOME_363
    elif [ "$MAVEN_VERSION" == "3.8.1" ]; then
      export MAVEN_HOME=$MAVEN_HOME_381
    elif [ "$MAVEN_VERSION" == "3.5.4" ]; then
      export MAVEN_HOME=$MAVEN_HOME_354
    fi

    # Update PATH
    export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

    # Log the selected versions
    echo "Using JDK version: $JAVA_VERSION ($JAVA_HOME)"
    echo "Using Maven version: $MAVEN_VERSION ($MAVEN_HOME)"
else
    logErrorMessage "SOURCE_VARIABLE_REPO is not defined. Skipping fetching details from $SOURCE_VARIABLE_REPO."
fi

logInfoMessage "Executing mvn $INSTRUCTION"
mvn $INSTRUCTION

TASK_STATUS=$?

saveTaskStatus ${TASK_STATUS} ${ACTIVITY_SUB_TASK_CODE}

