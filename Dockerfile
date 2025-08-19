FROM nginx:alpine

# Copy built frontend into nginx
COPY dist/ /usr/share/nginx/html

# Optional: use your own nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
