FROM ubuntu:22.04 AS build

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y git curl unzip xz-utils zip

# Fix for tar ownership extraction issue on Render Docker containers
RUN mv /bin/tar /bin/tar-original && \
    printf '#!/bin/sh\n/bin/tar-original --no-same-owner "$@"' > /bin/tar && \
    chmod +x /bin/tar

RUN git clone https://github.com/flutter/flutter.git -b 3.19.0 /sdks/flutter
ENV PATH="/sdks/flutter/bin:${PATH}"

RUN flutter config --no-analytics
RUN flutter config --enable-web

WORKDIR /app
COPY frontend_flutter/ .
RUN flutter pub get
RUN flutter build web --release

FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
