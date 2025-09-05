# front-end-redbus/Dockerfile
# build stage
FROM node:18-alpine AS build
WORKDIR /app
COPY front-end-redbus/package*.json ./
RUN npm ci
COPY front-end-redbus/ ./

# Allow passing REACT_APP_API_URL at build time (create-react-app uses REACT_APP_*)
ARG REACT_APP_API_URL
ENV REACT_APP_API_URL=${REACT_APP_API_URL}
RUN npm run build

# production image - serve with nginx
FROM nginx:stable-alpine
COPY --from=build /app/build /usr/share/nginx/html
# Use our simple nginx config (create file below)
COPY deploy/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
