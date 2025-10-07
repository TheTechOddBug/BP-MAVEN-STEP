# 🧩 BP-MAVEN-STEP

**BP-MAVEN-STEP** is a versatile BuildPiper marketplace step designed to **build, test, deploy, and analyze Java projects** using **Maven** — with **multi-JDK**, **multi-Maven**, **Node.js/NPM support**, **dynamic variable injection**, and **SonarQube integration**.

---

## ⚙️ Setup

### 1. Clone the Repository

```bash
git clone git@github.com:OT-BUILDPIPER-MARKETPLACE/BP-MAVEN-STEP.git
cd BP-MAVEN-STEP
```

### 2. Initialize Submodules

```bash
git submodule init
git submodule update
```

---

## 🧪 Local Testing

```bash
# Default Maven build
docker run -it --rm \
  -v $PWD:/src \
  -e WORKSPACE=/src \
  -e CODEBASE_DIR=/ \
  registry.buildpiper.in/maven-execute:latest

# Compile only
docker run -it --rm \
  -v $PWD:/src \
  -e WORKSPACE=/src \
  -e CODEBASE_DIR=/ \
  -e INSTRUCTION=compile \
  registry.buildpiper.in/maven-execute:latest

# Custom JDK + Maven versions
docker run -it --rm \
  -v $PWD:/src \
  -e WORKSPACE=/src \
  -e CODEBASE_DIR=/ \
  -e JAVA_VERSION=11 \
  -e MAVEN_VERSION=3.8.1 \
  registry.buildpiper.in/maven-execute:latest
```

---

## 🌍 Environment Variables

![Environment Variables Example](./maven-multi-jdk.png)

| Variable                    | Description                                                     | Default         |
| --------------------------- | --------------------------------------------------------------- | --------------- |
| `WORKSPACE`                 | Workspace directory containing code                             | `/bp/workspace` |
| `CODEBASE_DIR`              | Sub-directory within workspace                                  | `/`             |
| `JAVA_VERSION`              | JDK version: `8`, `11`, `17`, `21`, `22`, `23`, `24`            | `8`             |
| `MAVEN_VERSION`             | Maven version: `3.5.4`, `3.6.3`, `3.8.1`, `3.9.9`               | `3.6.3`         |
| `INSTRUCTION`               | Maven command or goal (e.g., `clean install`)                   | `package`       |
| `INSTRUCTION_TYPE`          | `BUILD`, `DEPLOY`, `TEST`, `CUSTOM`, `SONAR_SCAN`               | `BUILD`         |
| `SONAR_TESTING_TYPE`        | `Integration` → adds `-it`, `Unit` → adds `-ut`, default → none | (Optional)      |
| `VALIDATION_FAILURE_ACTION` | `WARNING` or `FAILURE`                                          | `WARNING`       |
| `ENABLE_CUSTOM_HTML_SCAN`   | Parse custom HTML test reports                                  | `false`         |
| `TEST_FAILURE_THRESHOLD`    | Failure threshold (%)                                           | `50`            |
| `TEST_RESULT_DIR`           | Directory for test result files                                 | `/`             |
| `SOURCE_VARIABLE_REPO`      | Git repo for dynamic variables (`mavenrepos.json`)              | (Optional)      |
| `MAVEN_OPTIONS`             | Additional Maven flags                                          | (Optional)      |

---

## ⚡ Runtime Behavior

### 1. **Automatic Java & Maven Switching**

* Dynamically sets JDK and Maven.
* Auto-validates combinations and defaults to `JDK 8 + Maven 3.6.3`.

### 2. **Dynamic Variable Fetching**

* If `SOURCE_VARIABLE_REPO` is set:

  * Clones repo at branch = `$APPLICATION_NAME`.
  * Extracts vars like `TO`, `CC`, `BCC`, `DNS_URL`, `TELEGRAM_CHAT_ID`.
  * Auto-applies them to environment.

### 3. **SonarQube Integration**

* Enabled via `INSTRUCTION_TYPE=SONAR_SCAN`.
* Supports suffix-based project naming via `SONAR_TESTING_TYPE`.
* Example:

  * `Integration` → `project-it`
  * `Unit` → `project-ut`
* Sonar tokens are **masked in logs** for security.

### 4. **Smart Instruction Switching**

If `INSTRUCTION` is not manually set:

```bash
case "$INSTRUCTION_TYPE" in
  BUILD)   INSTRUCTION=$MAVEN_BUILD_INSTRUCTION ;;
  DEPLOY)  INSTRUCTION=$MAVEN_DEPLOY_INSTRUCTION ;;
  TEST)    INSTRUCTION=$MAVEN_TEST_INSTRUCTION ;;
  CUSTOM)  INSTRUCTION=$MAVEN_CUSTOM_INSTRUCTION ;;
  SONAR_SCAN) INSTRUCTION=$MAVEN_SONAR_SCAN_INSTRUCTION ;;
esac
```

---

## 🧠 Fallback Mechanism

* If `SOURCE_VARIABLE_REPO` is **missing**, the script logs a warning and continues.
* If **invalid versions** are supplied, the script reverts to safe defaults.
* All Maven commands are logged **without exposing credentials**.

---

## 📚 References

**JDK Releases:**

* [JDK 8](https://github.com/adoptium/temurin8-binaries/releases)
* [JDK 11](https://github.com/adoptium/temurin11-binaries/releases)
* [JDK 17](https://github.com/adoptium/temurin17-binaries/releases)
* [JDK 21](https://github.com/adoptium/temurin21-binaries/releases)
* [JDK 22+](https://jdk.java.net/)

**Maven Releases:**

* [3.5.4](https://archive.apache.org/dist/maven/maven-3/3.5.4/binaries)
* [3.6.3](https://archive.apache.org/dist/maven/maven-3/3.6.3/binaries)
* [3.8.1](https://archive.apache.org/dist/maven/maven-3/3.8.1/binaries)
* [3.9.9](https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries)

**Additional:**

* [Remove Maven Download Logs](https://blogs.itemis.com/en/in-a-nutshell-removing-artifact-messages-from-maven-log-output)

---

## 🏷️ Release History

| Version     | Date         | Maintainer                                    | Summary                                                                                                                                                                   |
| ----------- | ------------ | --------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **2.5.2.8** | *2025-10-08* | [Mukul Joshi](mailto:mukul.joshi@opstree.com) | ➕ Added `SONAR_TESTING_TYPE` for dynamic Sonar suffix (-it / -ut) <br> 🧠 Enhanced instruction handling for `SONAR_SCAN` <br> 🔒 Masked token from logs for Sonar command |
| **2.5.2.7** | *2025-10-01* | [Mukul Joshi](mailto:mukul.joshi@opstree.com) | 🆕 Added Java version support for 22, 23, 24 <br> ✅ Full backward compatibility                                                                                           |
| **2.5.2.6** | *2025-09-15* | [Mukul Joshi](mailto:mukul.joshi@opstree.com) | 🧩 Introduced dynamic variable fetching from `SOURCE_VARIABLE_REPO` <br> 📬 Integrated with `mavenrepos.json` parsing                                                     |
| **2.5.2.5** | *2025-09-05* | [Mukul Joshi](mailto:mukul.joshi@opstree.com) | ⚡ Introduced multi-Maven (3.5.4–3.9.9) and multi-JDK (8–21) support <br> 🧱 Added image variant `multi-jdk-21-3.9`                                                        |
| **2.5.2.4** | *2025-08-18* | [Mukul Joshi](mailto:mukul.joshi@opstree.com) | 🧹 Improved Maven instruction handling <br> 🔄 Refactored variable extraction logic                                                                                       |
| **2.5.2.3** | *2025-08-05* | [Mukul Joshi](mailto:mukul.joshi@opstree.com) | 🪶 Added support for `MAVEN_OPTIONS` and `VALIDATION_FAILURE_ACTION`                                                                                                      |
| **2.5.2.2** | *2025-07-28* | [Mukul Joshi](mailto:mukul.joshi@opstree.com) | 🧰 Initial version supporting `multi-jdk-air` and `npm-support` builds                                                                                                    |

---

## 🧾 Maintainer

**Author:** Mukul Joshi
**Email:** [mukul.joshi@opstree.com](mailto:mukul.joshi@opstree.com)
**GitHub:** [@mukulmj](https://github.com/mukulmj)

