FROM eclipse-temurin:17.0.7_7-jdk-jammy
CMD ["gradle"]

ENV GRADLE_HOME /opt/gradle

RUN set -o errexit -o nounset \
    && echo "Adding gradle user and group" \
    && groupadd --system --gid 1000 gradle \
    && useradd --system --gid gradle --uid 1000 --shell /bin/bash --create-home gradle \
    && mkdir /home/gradle/.gradle \
    && chown --recursive gradle:gradle /home/gradle \
    \
    && echo "Symlinking root Gradle cache to gradle Gradle cache" \
    && ln --symbolic /home/gradle/.gradle /root/.gradle

VOLUME /home/gradle/.gradle

WORKDIR /home/gradle

RUN set -o errexit -o nounset \
    && apt-get update \
    && apt-get install --yes --no-install-recommends \
        unzip \
        wget \
        \
        bzr \
        git \
        git-lfs \
        mercurial \
        openssh-client \
        subversion \
    && rm --recursive --force /var/lib/apt/lists/* \
    \
    && echo "Testing VCSes" \
    && which bzr \
    && which git \
    && which git-lfs \
    && which hg \
    && which svn

ENV GRADLE_VERSION 8.2.1
ARG GRADLE_DOWNLOAD_SHA256=03ec176d388f2aa99defcadc3ac6adf8dd2bce5145a129659537c0874dea5ad1
RUN set -o errexit -o nounset \
    && echo "Downloading Gradle" \
    && wget --no-verbose --output-document=gradle.zip "https://services.gradle.org/distributions/gradle-${GRADLE_VERSION}-bin.zip" \
    \
    && echo "Checking download hash" \
    && echo "${GRADLE_DOWNLOAD_SHA256} *gradle.zip" | sha256sum --check - \
    \
    && echo "Installing Gradle" \
    && unzip gradle.zip \
    && rm gradle.zip \
    && mv "gradle-${GRADLE_VERSION}" "${GRADLE_HOME}/" \
    && ln --symbolic "${GRADLE_HOME}/bin/gradle" /usr/bin/gradle \
    \
    && echo "Testing Gradle installation" \
    && gradle --version

# Install Android SDK
ENV ANDROID_SDK_ROOT /opt/android-sdk
RUN mkdir -p ${ANDROID_SDK_ROOT}
WORKDIR ${ANDROID_SDK_ROOT}
RUN wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip
RUN unzip /opt/android-sdk/commandlinetools-linux-9477386_latest.zip
RUN rm /opt/android-sdk/commandlinetools-linux-9477386_latest.zip
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/bin
WORKDIR  ${ANDROID_SDK_ROOT}/cmdline-tools/bin
RUN yes | ./sdkmanager --sdk_root=${ANDROID_SDK_ROOT}/cmdline-tools/bin --licenses
ENV ANDROID_HOME ${ANDROID_SDK_ROOT}/cmdline-tools/bin
ENV ANDROID_SDK_ROOT ${ANDROID_SDK_ROOT}/cmdline-tools/bin


# installing sonar-scanner
RUN mkdir -p /opt/sonar
WORKDIR /opt/sonar
RUN wget -cO - https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.8.0.2856-linux.zip?_gl=1*1t78qkd*_gcl_au*MTM3MzM4NTU3NS4xNjg5NTk2MjY1*_ga*MTg0MDk5OTI0LjE2ODk1OTYyNjY.*_ga_9JZ0GZ5TC6*MTY4OTc0NjQ1OS40LjEuMTY4OTc1NTU5NS41Ny4wLjA. > sonnar-scanar.zip
RUN unzip sonnar-scanar.zip
RUN rm sonnar-scanar.zip
ENV SONAR_SCANNER /opt/sonar/sonar-scanner-4.8.0.2856-linux/bin

WORKDIR /home/gradle
