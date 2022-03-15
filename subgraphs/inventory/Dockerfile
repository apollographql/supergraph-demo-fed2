from gradle:7.4.1-jdk11

WORKDIR /usr/src/app

COPY app .

# Only download dependencies
# Eat the expected build failure since no source code has been copied yet
RUN gradle clean build --no-daemon > /dev/null 2>&1 || true

# Copy all files
COPY ./ /app/

# Do the actual build
RUN gradle clean build --no-daemon

CMD ["java", "-jar", "build/libs/app.jar"]
