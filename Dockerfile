FROM mukulmj/custom-ubuntu-java-maven:2.0.3

# Install NVM, Node.js 14, and pnpm (compatible version)
RUN curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash && \
    export NVM_DIR="$HOME/.nvm" && \
    [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh" && \
    nvm install 14 && \
    nvm use 14 && \
    npm install -g npm@6 && \
    npm install -g pnpm@7 && \
    node -v && \
    npm -v && \
    pnpm -v

# Old Details
ENV SLEEP_DURATION 5s

COPY build.sh .
COPY getDynamicVars.sh .
COPY set_npmrc.sh .
ADD BP-BASE-SHELL-STEPS /opt/buildpiper/shell-functions/
RUN chmod +x build.sh set_npmrc.sh getDynamicVars.sh

ENV ENABLE_MAVEN_SILENT_MODE false
ENV SOURCE_JSON_FILE mavenrepos.json

ENV VALIDATION_FAILURE_ACTION WARNING    
ENV ACTIVITY_SUB_TASK_CODE MVN_EXECUTE
ENTRYPOINT [ "./build.sh" ]

# Default command
CMD ["bash"]
