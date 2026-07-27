FROM ghcr.io/cirrusci/flutter:3.19.0 AS build
WORKDIR /app
COPY frontend_flutter/ .
RUN flutter pub get
RUN flutter build web

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
