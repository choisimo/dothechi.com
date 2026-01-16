FROM gradle:8.8.0-jdk17 AS builder

WORKDIR /workspace

COPY --chown=gradle:gradle . .

RUN chmod +x ./gradlew && ./gradlew bootJar -x test

FROM eclipse-temurin:17-jre-alpine

WORKDIR /app

RUN addgroup -g 1000 spring && adduser -u 1000 -G spring -s /bin/sh -D spring

COPY --from=builder /workspace/build/libs/*-SNAPSHOT.jar app.jar

RUN chown -R spring:spring /app

USER spring

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
