#!/bin/bash

# Check if JAVA_VERSION and MAVEN_VERSION environment variables are set
if [ -z "$JAVA_VERSION" ]; then
  echo "JAVA_VERSION is not set. Defaulting to JDK 8."
  export JAVA_HOME=$JAVA_HOME_8
else
  export JAVA_HOME=$(eval echo \$JAVA_HOME_$JAVA_VERSION)
fi

if [ -z "$MAVEN_VERSION" ]; then
  echo "MAVEN_VERSION is not set. Defaulting to Maven 3.6.3."
  export MAVEN_HOME=$MAVEN_HOME_363
else
  export MAVEN_HOME=$(eval echo \$MAVEN_HOME_$MAVEN_VERSION)
fi

# Update PATH
export PATH=$JAVA_HOME/bin:$MAVEN_HOME/bin:$PATH

# Execute the passed command
exec "$@"