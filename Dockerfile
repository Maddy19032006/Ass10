FROM nginx:alpine
# Copy our production dashboard markup into the web server distribution index
COPY index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
