# Sử dụng image Node làm base image
FROM node:20-bullseye

# Cài đặt các phụ thuộc cần thiết cho build Android
RUN apt-get update && apt-get install -y openjdk-11-jdk wget unzip build-essential git

# Thiết lập biến môi trường cho Android
ENV ANDROID_HOME=/opt/android-sdk
RUN echo "ANDROID_HOME: $ANDROID_HOME"
ENV PATH=${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools

# Tải và cài đặt Android SDK command line tools
RUN mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    cd ${ANDROID_HOME}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-9477386_latest.zip && \
    unzip commandlinetools-linux-9477386_latest.zip -d latest && \
    rm commandlinetools-linux-9477386_latest.zip

# Chấp nhận giấy phép và cài đặt các gói Android SDK cần thiết
RUN yes | ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager --licenses && \
    ${ANDROID_HOME}/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.0"

RUN ping -c 1 google.com
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
