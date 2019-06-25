FROM gradle:5.4.1-jdk8-slim

USER root

# Install system packages
RUN dpkg --add-architecture i386 && apt-get update \
    && apt-get install --no-install-recommends -y \
        curl \
        git \
        make \
        python2.7 \
        python3 \
        ssh \
        libnet-ssleay-perl \
        libcrypt-ssleay-perl \
        wget \
        unzip \
        build-essential \
        libssl-dev \
        libexpat-dev

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
ENV ANDROID_HOME=$ANDROID_SDK_ROOT
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
        "platform-tools"

WORKDIR /usr/lib

ENV SERGE_VERSION=1.3

RUN wget https://github.com/evernote/serge/archive/1.3.zip -O serge-$SERGE_VERSION.zip && \
    unzip serge-$SERGE_VERSION.zip && \
    unlink serge-$SERGE_VERSION.zip

RUN cpan App::cpanminus

WORKDIR /usr/lib/serge-$SERGE_VERSION

RUN cpanm --force --installdeps . && \
    cpanm --test-only . && \
    ./Build distclean

WORKDIR /usr/lib

RUN ln -s serge-$SERGE_VERSION serge && \
    ln -s /usr/lib/serge/bin/serge /usr/bin/serge

RUN cpanm Serge::Sync::Plugin::TranslationService::Smartcat
RUN cpanm LWP::Protocol::https

CMD ["/bin/bash"]
