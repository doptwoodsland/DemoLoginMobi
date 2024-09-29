# Sử dụng image Node làm base image
FROM node:20

# Cài đặt các phụ thuộc cần thiết cho Android build
RUN apt-get update && \
    apt-get install -y wget unzip build-essential git && \
    apt-get install -y openjdk-17-jdk || apt-get install -y default-jdk

# Thiết lập biến môi trường cho Android
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=${PATH}:${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin:${ANDROID_SDK_ROOT}/platform-tools

# Tải và cài đặt Android SDK command line tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip -O /tmp/cmdline-tools.zip && \
    unzip /tmp/cmdline-tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools/latest && \
    mv ${ANDROID_SDK_ROOT}/cmdline-tools/cmdline-tools/* ${ANDROID_SDK_ROOT}/cmdline-tools/latest/ && \
    rm /tmp/cmdline-tools.zip

# Chấp nhận giấy phép và cài đặt các gói Android SDK cần thiết
RUN yes | ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager --licenses && \
    ${ANDROID_SDK_ROOT}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

# Tạo thư mục ứng dụng
WORKDIR /app

# Sao chép package.json và yarn.lock hoặc package-lock.json vào container
COPY package*.json ./

# Cài đặt các phụ thuộc
RUN npm install

# Sao chép toàn bộ dự án vào container
COPY . .

# Mở cổng 8081 cho Metro Bundler
EXPOSE 8081

# Khởi động Metro Bundler
CMD ["npm", "start"]
