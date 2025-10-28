# Image to build the app
FROM barichello/godot-ci:4.5 as build
COPY ./ /src
WORKDIR /src
RUN mkdir -v -p build/web
RUN godot --headless --verbose --export-release "Web" ./build/web/index.html
RUN bash docker/cache-bust.sh /src/build/web

# Image to serve the app
FROM nginx:1-alpine as web
RUN apk --no-cache upgrade
COPY --from=build src/build/web /usr/share/nginx/html
COPY docker/nginx.conf /etc/nginx/nginx.conf
COPY docker/privacy-policy.html /usr/share/nginx/html/privacy-policy.html
COPY docker/support.html /usr/share/nginx/html/support.html