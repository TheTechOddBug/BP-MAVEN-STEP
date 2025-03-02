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
