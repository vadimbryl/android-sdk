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
        kvm \
        qemu-kvm

RUN apt-get -yq autoremove && \
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
ENV ANDROID_SDK_ROOT="/usr/local/android-sdk"
ENV PATH ${PATH}:${ANDROID_SDK_ROOT}/emulator:${ANDROID_SDK_ROOT}/tools:${ANDROID_SDK_ROOT}/tools/bin:${ANDROID_SDK_ROOT}/platform-tools

RUN mkdir "$ANDROID_SDK_ROOT" .android \
    && cd "$ANDROID_SDK_ROOT" \
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
        "system-images;android-28;google_apis;x86"

RUN echo no | avdmanager create avd -n "x86" --package "system-images;android-28;google_apis;x86" --tag google_apis

# COPY config.ini /root/.android/avd/x86.avd/config.ini
# ADD entrypoint.sh /entrypoint.sh
# CMD /entrypoint.sh
CMD ["/bin/bash"]
