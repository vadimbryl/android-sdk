FROM openjdk:8-jdk-slim

RUN apt-get update \
    && apt-get install --no-install-recommends -y curl \
    && rm -rf /var/lib/apt/lists/*

ENV ANDROID_HOME=/usr/local/android-sdk

RUN mkdir ${ANDROID_HOME} .android \
    && cd ${ANDROID_HOME} \
    && curl -o sdk.zip "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
    && unzip sdk.zip \
    && rm sdk.zip \
    && yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses

RUN ${ANDROID_HOME}/tools/bin/sdkmanager --update \
    && ${ANDROID_HOME}/tools/bin/sdkmanager \
        "build-tools;28.0.2" \
        "build-tools;28.0.3" \
        "platform-tools" \
        "platforms;android-28"
