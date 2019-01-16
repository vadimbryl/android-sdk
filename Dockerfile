FROM gradle:4.10-jdk8-slim

USER root

# Install system packages
RUN apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        git \
        make \
        python2.7 \
        ssh \
    && rm -rf /var/lib/apt/lists/*
RUN curl -o get-pip.py https://bootstrap.pypa.io/get-pip.py \
    && python2.7 get-pip.py \
    && rm get-pip.py

# AWS command line tools
RUN pip install awscli

# Install Google Cloud SDK
RUN curl -o sdk.tar.gz "https://dl.google.com/dl/cloudsdk/channels/rapid/google-cloud-sdk.tar.gz" \
    && tar zxf sdk.tar.gz \
    && mv google-cloud-sdk /usr/local/ \
    && rm sdk.tar.gz \
    && /usr/local/google-cloud-sdk/install.sh
ENV PATH="/usr/local/google-cloud-sdk/bin:$PATH"

# Install Android SDK
ENV ANDROID_HOME="/usr/local/android-sdk"
ENV PATH ${PATH}:${ANDROID_HOME}/emulator:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools

RUN mkdir "$ANDROID_HOME" .android \
    && cd "$ANDROID_HOME" \
    && curl -o sdk.zip "https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip" \
    && unzip sdk.zip \
    && rm sdk.zip \
    && yes | sdkmanager --licenses

# Install Android Build Tool and Libraries
RUN sdkmanager --update && sdkmanager \
        "build-tools;28.0.2" \
        "build-tools;28.0.3" \
        "platforms;android-28" \
        "platform-tools" \
        "emulator" \
        "tools" \
        "system-images;android-28;google_apis;x86"

RUN echo no | avdmanager create avd -n "x86" --package "system-images;android-28;google_apis;x86" --tag google_apis

CMD ["/bin/bash"]
