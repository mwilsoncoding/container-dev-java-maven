# Set language-specific versioning
ARG MAVEN_VSN=3.8.6
ARG MAVEN_JDK_VSN=18
ARG JRE_VSN=18.0.2.1_1

# Set args for image overrides
ARG BUILDER_REGISTRY=docker.io
ARG BUILDER_REGISTRY_PATH=library
ARG BUILDER_BASE_IMAGE=maven
ARG BUILDER_BASE_IMAGE_TAG=${MAVEN_VSN}-eclipse-temurin-${MAVEN_JDK_VSN}-alpine
ARG RUNNER_REGISTRY=$BUILDER_REGISTRY
ARG RUNNER_REGISTRY_PATH=$BUILDER_REGISTRY_PATH
ARG RUNNER_BASE_IMAGE=eclipse-temurin
ARG RUNNER_BASE_IMAGE_TAG=${JRE_VSN}-jre-alpine

# Set a base directory ARG for running the build of your app
ARG APP_DIR=/opt/app

# # Set an ARG for switching app build envs
ARG APP_ENV=prod
ARG MAVEN_PROFILES=${APP_ENV}

# # Set any other args shared between build stages
ARG JAR=containerdevjava.0.1.0.jar
ARG JVM_APP=com.containerdevjava.App

# Build stage
FROM ${BUILDER_REGISTRY}/${BUILDER_REGISTRY_PATH}/${BUILDER_BASE_IMAGE}:${BUILDER_BASE_IMAGE_TAG} AS builder

# # Import necessary ARGs defined at top level
ARG APP_DIR
ARG MAVEN_PROFILES

# Persist necessary ARGs as ENVs for use in CI
ENV MAVEN_PROFILES $MAVEN_PROFILES
ENV MAVEN_CONFIG ${APP_DIR}/.m2

# Copy all src. Leverage .dockerignore to exclude unnecessary files.
# This will copy any host directories used for local dependency
# caching if they exist in the root of the repository.
COPY . $APP_DIR

# Install OS build/test dependencies
RUN apk add --no-cache yamllint

WORKDIR $APP_DIR

# Install local package manager caches if missing (see above note re: COPY . $APP_DIR)
# Get dependencies for the currently configured environment
# Build, overwriting any extant build artifacts copied in from the host filesystem
RUN mvn package -q \
    -f pom.xml \
    -Dmaven.repo.local=$MAVEN_CONFIG \
    -P $MAVEN_PROFILES \
    $(if ! echo "$MAVEN_PROFILES" | grep -q ',\??\?\<test\>,\?'; then \
        echo '-Dmaven.test.skip=true'; \
      else \
        echo '-DskipTests=true'; \
      fi)

# Runner stage
FROM ${RUNNER_REGISTRY}/${RUNNER_REGISTRY_PATH}/${RUNNER_BASE_IMAGE}:${RUNNER_BASE_IMAGE_TAG}

# Import necessary ARGs defined at top level
ARG APP_DIR
# ARG OTP_APP
# ARG MIX_ENV
# 
# # Copy from the built directory into the runner stage at the same directory
# ARG BUILD_DIR=$APP_DIR/_build
# WORKDIR $BUILD_DIR
# COPY --from=builder $BUILD_DIR .
# 
# # Preserve the build environment in an ENV if necessary
# ENV MIX_ENV $MIX_ENV
# 
# # Set a running directory
# ARG RUN_DIR=$BUILD_DIR/$MIX_ENV/rel/$OTP_APP/bin
# WORKDIR $RUN_DIR
WORKDIR $APP_DIR
# 
# # Use CMD to allow overrides when invoked via `docker container run`
# CMD ["java","-cp"]
