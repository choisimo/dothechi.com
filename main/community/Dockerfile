FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

RUN addgroup -g 1000 spring && adduser -u 1000 -G spring -s /bin/sh -D spring

COPY build/libs/community-0.0.1-SNAPSHOT.jar app.jar

RUN chown -R spring:spring /app

USER spring

EXPOSE 18081

HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:18081/actuator/health || exit 1

ENTRYPOINT ["java", "-jar", "app.jar"]
