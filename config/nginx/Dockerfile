FROM nginx:alpine

WORKDIR /etc/nginx
COPY ./nginx.conf ./conf.d/default.conf
COPY ./shared.conf ./shared.conf
EXPOSE 8000
ENTRYPOINT [ "nginx" ]
CMD [ "-g", "daemon off;" ]
