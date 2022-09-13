# Set language-specific versioning
ARG MAVEN_VSN=3.8.6
ARG MAVEN_JDK_VSN=18
ARG JRE_VSN=18.0.2.1_1

# Select a base image for developing your language
# Alpine images are preferred
ARG BUILDER_REGISTRY=docker.io
ARG BUILDER_REGISTRY_PATH=library
ARG BUILDER_BASE_IMAGE=maven
ARG BUILDER_BASE_IMAGE_TAG=${MAVEN_VSN}-eclipse-temurin-${MAVEN_JDK_VSN}-alpine

FROM ${BUILDER_REGISTRY}/${BUILDER_REGISTRY_PATH}/${BUILDER_BASE_IMAGE}:${BUILDER_BASE_IMAGE_TAG}

RUN apk add --no-cache bash git sudo

# Add any additional desired development tooling. Eg:

RUN apk add --no-cache py3-pip yamllint
RUN pip install yamlfix

# Set environment variables for any paths that language-specific
# tooling may need for interacting with the host filesystem
# $WORKSPACE is set in devcontainer.json
ENV WORKSPACE /workspace
ENV MAVEN_CONFIG $WORKSPACE/.m2
ARG APP_ENV=dev
ARG MAVEN_PROFILES=default-java,${APP_ENV}

# Set an ENV to persist the app build env as development mode
# ENV PROFILES

# This Dockerfile adds a non-root user with sudo access. Use the "remoteUser"
# property in devcontainer.json to use it. On Linux, the container user's GID/UIDs
# will be updated to match your local UID/GID (when using the dockerFile property).
# See https://aka.ms/vscode-remote/containers/non-root-user for details.
ARG USERNAME=dev
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN addgroup -g $USER_GID $USERNAME \
    && adduser -s /bin/bash -u $USER_UID -G $USERNAME -h /home/$USERNAME -D $USERNAME \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME

USER $USERNAME
ENV HOME /home/$USERNAME
