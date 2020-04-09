FROM arm64v8/ubuntu
LABEL maintainer="michael@mysmartbeat.com" \
    vendor="SmartBeat" \
    version="1.1.0" \
    description.architecture="ARM64" \
    description.os="Ubuntu" \
    description.features="OpenCV-3.4.2 \
    FFMPEG \
    GMOCK \
    GTEST \
    TeamCity Build Agent"

COPY ./buildAgent.zip /home/buildAgent.zip

ENV OPENCV_VERSION=3.4.2 \
    SERVER_URL="http://teamcity-server-instance:8111" \
    AGENT_NAME="Docker-arm64"

# Libraries and Commands
RUN apt-get update; \
    apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    curl \
    frei0r-plugins-dev \
    g++ \
    git \
    gnutls-dev \
    openjdk-8-jdk-headless \
    ladspa-sdk \
    libass-dev \
    libatlas-base-dev \
    libavcodec-dev \
    libavformat-dev \
    libbluray-dev \
    libcaca-dev \
    libcdio-paranoia-dev \
    libchromaprint-dev \
    libcodec2-dev \
    libdrm-dev \
    libfdk-aac-dev \
    libfontconfig1-dev \
    libfreetype6-dev \
    libfribidi-dev \
    libglu1-mesa-dev \
    libgme-dev \
    libgmp-dev \
    libgsm1-dev \
    libgtest-dev \
    libgtk2.0-dev \
    libjack-dev \
    libjpeg-dev \
    liblilv-dev \
    libmodplug-dev \
    libmp3lame-dev \
    libopencore-amrnb-dev \
    libopencore-amrwb-dev \
    libopenjp2-7-dev \
    libopenal-dev \
    libopenmpt-dev \
    libopus-dev \
    libpng-dev \
    libpulse-dev \
    librsvg2-dev \
    librubberband-dev \
    librtmp-dev \
    libshine-dev \
    libsmbclient-dev \
    libsnappy-dev \
    libsoxr-dev \
    libspeex-dev \
    libssh-dev \
    libswscale-dev \
    libtesseract-dev \
    libtheora-dev \
    libtiff-dev \
    libtwolame-dev \
    libv4l-dev \
    libvo-amrwbenc-dev \
    libvorbis-dev \
    libvpx-dev \
    libwavpack-dev \
    libwebp-dev \
    libx264-dev \
    libx265-dev \
    libxvidcore-dev \
    libxml2-dev \
    libzmq3-dev \
    libzvbi-dev \
    make \
    opencl-dev \
    pkg-config \
    python3 \
    python3-dev \
    python3-pip \
    python3-numpy \
    unzip \
    wget \
    zip;

# Python Alternatives
RUN update-alternatives --install /usr/bin/python python /usr/bin/python2 1; \
    update-alternatives --install /usr/bin/python python /usr/bin/python3 2; \
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 2;

# GMock
WORKDIR /home
RUN wget -q https://github.com/google/googletest/archive/release-1.8.0.tar.gz; \
    tar xzf release-1.8.0.tar.gz; \
    rm release-1.8.0.tar.gz; \
    cd googletest-release-1.8.0; \
    mkdir build && cd build; \
    cmake ..; \
    make -j$(nproc); \
    cp googlemock/*.a /usr/lib; \
    rm -r /home/googletest-release-1.8.0;

# GTest
WORKDIR /usr/src/gtest
RUN cmake CMakeLists.txt; \
    make -j$(nproc); \
    cp *.a /usr/lib;

# FFMPEG
WORKDIR /home
RUN git clone --depth 1 https://github.com/FFmpeg/FFmpeg.git; \
    cd FFmpeg; \
    ./configure \
    --arch="arm64v8" \
    --enable-gpl \
    --enable-version3 \
    --enable-cross-compile \
    --disable-static \
    --enable-shared \
    --enable-small \
    --enable-avisynth \
    --enable-chromaprint \
    --enable-frei0r \
    --enable-gmp \
    --enable-gnutls \
    --enable-ladspa \
    --enable-libass \
    --enable-libcaca \
    --enable-libcdio \
    --enable-libcodec2 \
    --enable-libdrm \
    --enable-libfontconfig \
    --enable-libfreetype \
    --enable-libfribidi \
    --enable-libgme \
    --enable-libgsm \
    --enable-libjack \
    --enable-libmodplug \
    --enable-libmp3lame \
    --enable-libopencore-amrnb \
    --enable-libopencore-amrwb \
    --enable-libopencore-amrwb \
    --enable-libopenjpeg \
    --enable-libopenmpt \
    --enable-libopus \
    --enable-libpulse \
    --enable-librsvg \
    --enable-librubberband \
    --enable-librtmp \
    --enable-libshine \
    --enable-libsnappy \
    --enable-libsoxr \
    --enable-libspeex \
    --enable-libssh \
    --enable-libtesseract \
    --enable-libtheora \
    --enable-libtwolame \
    --enable-libv4l2 \
    --enable-libvo-amrwbenc \
    --enable-libvorbis \
    --enable-libvpx \
    --enable-libwavpack \
    --enable-libwebp \
    --enable-libx264 \
    --enable-libx265 \
    --enable-libxvid \
    --enable-libxml2 \
    --enable-libzmq \
    --enable-libzvbi \
    --enable-lv2 \
    --enable-openal \
    --enable-opencl \
    --enable-opengl \
    --enable-nonfree \
    --enable-libfdk-aac \
    --enable-libbluray \
    --cxx=g++; \    
    make; \
    make install; \
    ldconfig;

# Download OpenCV
# Adapted from https://github.com/Valian/docker-python-opencv-ffmpeg/blob/master/Dockerfile-py3
WORKDIR /home
RUN wget -q https://github.com/opencv/opencv/archive/${OPENCV_VERSION}.zip -O opencv3.zip; \
    unzip -q opencv3.zip; \
    mv /home/opencv-${OPENCV_VERSION} /home/opencv; \
    rm opencv3.zip; \
    wget -q https://github.com/opencv/opencv_contrib/archive/${OPENCV_VERSION}.zip -O opencv_contrib3.zip; \
    unzip -q opencv_contrib3.zip; \
    mv /home/opencv_contrib-${OPENCV_VERSION} /home/opencv_contrib; \
    rm /home/opencv_contrib3.zip;

# Build OpenCV
WORKDIR /home/opencv
RUN mkdir build && cd build; \
    cmake -D CMAKE_BUILD_TYPE=RELEASE \
    -D BUILD_PYTHON_SUPPORT=ON \
    -D CMAKE_INSTALL_PREFIX=/usr/local \
    -D OPENCV_EXTRA_MODULES_PATH=/home/opencv_contrib/modules \
    -D BUILD_EXAMPLES=OFF \
    -D PYTHON_DEFAULT_EXECUTABLE=$(which python3) \
    -D BUILD_opencv_python3=ON \
    -D BUILD_opencv_python2=OFF \
    -D WITH_IPP=OFF \
    -D WITH_FFMPEG=ON \
    -D WITH_V4L=ON ..; \
    make -j$(nproc); \
    make install; \
    ldconfig; \
    rm -r /home/opencv /home/opencv_contrib;

# TeamCity Build Agent
WORKDIR /home
RUN echo "JAVA_HOME='/usr/bin/java'\nexport JAVA_COME" >> ~/.bashrc; \
    mkdir buildAgent && cd buildAgent; \
    unzip ../buildAgent.zip; \
    mv conf/buildAgent.dist.properties conf/buildAgent.properties; \
    echo "serverUrl=${SERVER_URL}\nname=${AGENT_NAME}\nworkDir=../work\ntempDir=../temp\nsystemDir=../system\nauthorizationToken=" >| conf/buildAgent.properties; \
    rm -rf /home/project.smartbeat.teamcity;

CMD [ "/home/buildAgent/bin/agent.sh","start" ]