FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y git curl unzip xz-utils zip libglu1-mesa

RUN git clone https://github.com/flutter/flutter.git -b stable /sdks/flutter
ENV PATH="/sdks/flutter/bin:${PATH}"

RUN flutter config --enable-web

WORKDIR /app
COPY frontend_flutter/ .
RUN flutter pub get
RUN flutter build web

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
