# back-end-redbus/Dockerfile
FROM node:18-alpine AS builder
WORKDIR /app

# copy package files first (for caching)
COPY back-end-redbus/package*.json ./
RUN npm ci --production

# copy rest of backend source
COPY back-end-redbus/ ./

# expose port and default command
EXPOSE 5000
ENV NODE_ENV=production

# Use npm start (assumes package.json has start script)
CMD ["npm", "start"]
