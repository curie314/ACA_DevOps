FROM nginx

RUN mkdir -p /usr/share/nginx/html/artyom
COPY artyom/index.html /usr/share/nginx/html/artyom/index.html
