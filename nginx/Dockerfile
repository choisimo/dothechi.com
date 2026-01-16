FROM ghcr.io/cirruslabs/flutter:3.22.3 AS flutter-builder

WORKDIR /app

COPY flutter_app/pubspec.yaml flutter_app/pubspec.lock ./

RUN flutter pub get

COPY flutter_app/ ./

RUN flutter build web --release

FROM nginx:alpine

RUN mkdir -p /var/www/certbot

COPY nginx/nginx.conf /etc/nginx/nginx.conf

COPY --from=flutter-builder /app/build/web /usr/share/nginx/html

EXPOSE 80 443
