FROM nodered/node-red:latest

# Set the working directory
WORKDIR /data

# Switch to root to install additional packages if needed
USER root

# Install additional system packages (uncomment if needed)
# RUN apt-get update && apt-get install -y \
#     git \
#     && rm -rf /var/lib/apt/lists/*

# Copy package.json if you have custom nodes to install
COPY package*.json ./

# Install additional Node-RED nodes if package.json exists
RUN if [ -f package.json ]; then npm install --unsafe-perm --no-update-notifier --no-audit --only=production; fi

# Copy your Node-RED flows and configuration
COPY flows*.json ./
COPY settings.js ./

# Copy any additional project files
COPY . ./

# Set proper ownership for the node-red user
RUN chown -R node-red:root /data

# Switch back to node-red user
USER node-red

# Expose the Node-RED port
EXPOSE 1880

# Set environment variables (customize as needed)
ENV NODE_RED_ENABLE_PROJECTS=false
ENV NODE_RED_ENABLE_SAFE_MODE=false

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:1880/ || exit 1

# Start Node-RED
CMD ["npm", "start"]