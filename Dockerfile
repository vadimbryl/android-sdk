FROM gradle:4.10-jdk8-slim

USER root

# Install system packages
RUN dpkg --add-architecture i386 && apt-get update \
    && apt-get install --no-install-recommends -y \
        libgl1-mesa-glx \
        libpulse0 \
        curl \
        git \
        make \
        python2.7 \
        ssh \
    && apt-get -yq autoremove && \
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
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

RUN touch /root/.android/repositories.cfg

# Install Android Build Tool and Libraries
RUN sdkmanager --update && sdkmanager \
        "build-tools;28.0.2" \
        "build-tools;28.0.3" \
        "platforms;android-28" \
        "platform-tools" \
        "emulator" \
        "tools" \
        "extras;android;m2repository" \
        "extras;google;m2repository" \
        "system-images;android-28;google_apis;x86" \
        "system-images;android-28;google_apis;x86_64" \
        "extras;intel;Hardware_Accelerated_Execution_Manager"

RUN echo no | avdmanager create avd -n "x86" --package "system-images;android-28;google_apis;x86" --tag google_apis
RUN echo no | avdmanager create avd -n "x86_64" -k "system-images;android-28;google_apis;x86_64" --tag google_apis

CMD ["/bin/bash"]
