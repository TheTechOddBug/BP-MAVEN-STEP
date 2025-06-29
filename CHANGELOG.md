# **Change Log for Docker Image: `registry.buildpiper.in/maven-execute`**  

**Tag:** `2.5.2.2`  
**Release Date:** *2025-02-20*  
**Maintainer:** *[Mukul Joshi](mukul.joshi@opstree.com), [GitHub](https://github.com/mukulmj)*  

## **Enhancements:**

- Enhanced Maven execution logic by introducing INSTRUCTION_TYPE handling.
  - Supports BUILD, DEPLOY, TEST, and CUSTOM instructions.
  - Logs execution details for each instruction type.
  - Added error handling for unsupported instruction types, defaulting to BUILD with an error message.
- Introduced conditional handling for Maven silent mode.
- Added a new environment variable `ENABLE_MAVEN_SILENT_MODE`.
- When `ENABLE_MAVEN_SILENT_MODE` is set to `true`, the script appends `-B -Dorg.slf4j.simpleLogger.log.org.apache.maven.cli.transfer.Slf4jMavenTransferListener=warn` to the `mvn` command.
- Improved logging to display executed Maven commands with or without the silent mode options.
Included error handling for unsupported Java and Maven versions.
- Implemented `fetch_service_details` function call based on `SOURCE_VARIABLE_REPO` and `INSTRUCTION` conditions.

**References:**
[How to remove downloading messages from Maven log output](https://blogs.itemis.com/en/in-a-nutshell-removing-artifact-messages-from-maven-log-output)
[Base Image Tag 2.0.3](https://hub.docker.com/layers/mukulmj/custom-ubuntu-java-maven/2.0.3/images/sha256-0d3cb75d96d9c9aefd009af8a5ed802ee686ca739d6dcd03015b25c84fdcca6b)
[Maven has now a an option to suppress the transfer progress when downloading/uploading in interactive mode.](https://maven.apache.org/docs/3.6.1/release-notes.html#:~:text=with%20MNG%2D6618-,User%20visible%20Changes,scm%20part%20in%20the%20pom%20for%20multi%20module%20builds%20like%20this%3A,-%3Cproject%20child.project)

---

Here’s the updated change log for version `2.5.2.3` incorporating your additions:  

---

**Tag:** `2.5.2.3`  
**Release Date:** *2025-03-01*  
**Maintainer:** *[Mukul Joshi](mukul.joshi@opstree.com), [GitHub](https://github.com/mukulmj)*  

## **Enhancements & New Additions:**  

### **1. Added Node.js & Package Manager Support**

- Integrated NVM (v0.40.1) to manage Node.js installations.
- Installed Node.js v14 and set it as the default version.  
- Installed globally compatible versions of `npm` (v6) and `pnpm` (v7).  
- Verified successful installation by logging Node.js, npm, and pnpm versions.  
- **Reference:** [Node.js Download](https://nodejs.org/en/download)  

### **2. Introduced `set_npmrc.sh` Script for npm Configuration**  

- **New script:** `set_npmrc.sh` to manage `.npmrc` configurations dynamically.  
- Checks for an existing `.npmrc` in the target `CODEBASE_LOCATION`.  
- If found, sets it as the default and backs up any existing global `.npmrc`.  
- Ensures seamless npm registry configuration management.  

### **3. Other Improvements**  

- Retained all enhancements from version `2.5.2.2`, including:  
  - Enhanced Maven execution with `INSTRUCTION_TYPE` handling.  
  - Conditional handling of Maven silent mode using `ENABLE_MAVEN_SILENT_MODE`.  
  - Improved error handling for unsupported Java and Maven versions.  
  - `fetch_service_details` function now executes based on `SOURCE_VARIABLE_REPO` and `INSTRUCTION` conditions.  

---

**Tag:** `2.5.2.4`
**Release Date:** *2025-06-30*
**Maintainer:** *[Mukul Joshi](mukul.joshi@opstree.com), [GitHub](https://github.com/mukulmj)*

## **Enhancements & New Additions:**

### **1. Base Image Update**

* **Updated base image:**

  * `FROM registry.buildpiper.in/base-image/java-maven:2.0.5`
* Modernized Java and Maven environment compatibility.

### **2. New Entrypoint Script for Version Switching**

* **Added `switch_versions.sh` as the main `ENTRYPOINT`:**

  * Initializes Java and Maven version setup automatically during container start.
  * When `fetch_service_details` is used, `switch_versions.sh` executes again to ensure environment consistency.
* **Entrypoint Configuration:**

  ```dockerfile
  ENTRYPOINT ["/usr/local/bin/switch_versions.sh", "./build.sh"]
  ```
### **3. Improved Repository Cloning & Proxy Handling**

* **Enhanced `getDynamicVars.sh`:**

  * Implements multiple retry attempts when cloning repositories.
  * Introduced dynamic proxy support:

    * Uses proxy if cloning fails initially.
    * Automatically removes proxy for specific commands that must bypass it.

### **4. Dynamic Maven Instruction Selection**

* Added logic to **switch Maven `INSTRUCTION` dynamically** based on `INSTRUCTION_TYPE` if `INSTRUCTION` is not explicitly set:

  ```bash
  if [ -z "$INSTRUCTION" ]; then
      case "$INSTRUCTION_TYPE" in
          "BUILD")  export INSTRUCTION=$MAVEN_BUILD_INSTRUCTION ;;
          "DEPLOY") export INSTRUCTION=$MAVEN_DEPLOY_INSTRUCTION ;;
          "TEST")   export INSTRUCTION=$MAVEN_TEST_INSTRUCTION ;;
          "CUSTOM") export INSTRUCTION=$MAVEN_CUSTOM_INSTRUCTION ;;
          *)
              logErrorMessage "Unsupported $INSTRUCTION_TYPE: Executing default mvn $INSTRUCTION"
              ;;
      esac
  fi
  ```
* Ensures consistent build/deploy/test workflows across pipelines.

### **5. Test Result Management Enhancements**

* **New Environment Variables:**

  * `ENABLE_CUSTOM_HTML_SCAN`
    Enables parsing of custom HTML reports to extract failed test cases.
  * `TEST_FAILURE_THRESHOLD`
    Configurable test failure threshold percentage (e.g., `50` for 50%).
  * `TEST_RESULT_DIR`
    Path to the directory containing test result files.

### **6. Retained Enhancements from `2.5.2.3`**

* Node.js & Package Manager support with `nvm`, `npm`, and `pnpm`.
* `set_npmrc.sh` script for dynamic `.npmrc` management.
* Enhanced Maven execution, error handling, and dynamic instruction selection logic.
