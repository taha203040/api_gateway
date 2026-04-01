FROM openresty/openresty:alpine

COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf

EXPOSE 80

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-g", "daemon off;"]