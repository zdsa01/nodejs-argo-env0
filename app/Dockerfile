FROM node:20-alpine

WORKDIR /app

# Install necessary system packages for binaries and networking
RUN apk update && apk upgrade && \
    apk add --no-cache \
    openssl curl bash gcompat iproute2 coreutils ca-certificates && \
    update-ca-certificates

# Copy application files
COPY package.json index.js index.html ./

# Install Node dependencies
RUN npm install --omit=dev && \
    chmod +x index.js

# Default runtime directory (writable)
ENV FILE_PATH=/tmp/.npm
ENV PORT=3000
ENV NODE_ENV=production

# Expose the HTTP port for subscription
EXPOSE 3000

# Create runtime dir
RUN mkdir -p /tmp/.npm && chmod 777 /tmp/.npm

CMD ["node", "index.js"]
