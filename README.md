# BP-MAVEN-STEP

I'll use Maven to build the Java project.

## Setup

* Clone the code available at [BP-MAVEN-STEP](https://github.com/OT-BUILDPIPER-MARKETPLACE/BP-MAVEN-STEP)
  ```bash
  git clone git@github.com:OT-BUILDPIPER-MARKETPLACE/BP-MAVEN-STEP.git
  ```
* Build the Docker image

  ```bash
  git submodule init
  git submodule update
  docker build -t registry.buildpiper.in/maven-execute:multi-jdk-test .
  ```

* Do local testing via the image only

  ```bash
  # Build code with default settings 
  docker run -it --rm -v $PWD:/src -e WORKSPACE=/src -e CODEBASE_DIR=/ registry.buildpiper.in/maven-execute:multi-jdk-test

  # Only compile the code
  docker run -it --rm -v $PWD:/src -e WORKSPACE=/src -e CODEBASE_DIR=/ -e INSTRUCTION=compile registry.buildpiper.in/maven-execute:multi-jdk-test

  # Build code with specific JDK and Maven versions
  docker run -it --rm -v $PWD:/src -e WORKSPACE=/src -e CODEBASE_DIR=/ -e JAVA_VERSION=11 -e MAVEN_VERSION=3.8.1 registry.buildpiper.in/maven-execute:multi-jdk-test
  ```

## Environment Variables Example

![Environment Variables Example](./maven-multi-jdk.png)

```bash
WORKSPACE=/bp/workspace
INSTRUCTION=clean install
MAVEN_VERSION=3.6.3,3.8.1,3.5.4
JAVA_VERSION=8,11,17
VALIDATION_FAILURE_ACTION=WARNING,FAILURE
```

## Runtime Environment Details

- **JAVA_VERSION**: 
  - Set `JAVA_VERSION` to `8`, `11`, or `17` to select the JDK version.
  - **Default**: `8` (JDK 8).
  - **Example**: `JAVA_VERSION=11` for JDK 11.

- **MAVEN_VERSION**: 
  - Set `MAVEN_VERSION` to `3.6.3`, `3.8.1`, or `3.5.4` to select the Maven version.
  - **Default**: `3.6.3` (Maven 3.6.3).
  - **Example**: `MAVEN_VERSION=3.8.1` for Maven 3.8.1.

- **WORKSPACE**: 
  - Define the workspace directory where the codebase is located.
  - **Example**: `WORKSPACE=/src`.

- **CODEBASE_DIR**: 
  - Specify the sub-directory within the workspace where the codebase is located.
  - **Example**: `CODEBASE_DIR=/`.

- **INSTRUCTION**: 
  - Define the Maven command or instruction to be executed.
  - **Default**: `package`.
  - **Example**: `INSTRUCTION=clean install`.

- **VALIDATION_FAILURE_ACTION**: 
  - Control the behavior on validation failure.
  - Options include `WARNING` (continue with warnings) or `FAILURE` (stop on failure).
  - **Example**: `VALIDATION_FAILURE_ACTION=FAILURE`.

## Notes:

- If no values are provided for `JAVA_VERSION` or `MAVEN_VERSION`, the script will default to JDK 8 and Maven 3.6.3.
- If incorrect values are supplied, the script will display usage instructions, defaulting to the predefined versions.
- The environment variables allow for flexible and customized build configurations, ensuring compatibility across different JDK and Maven versions.
