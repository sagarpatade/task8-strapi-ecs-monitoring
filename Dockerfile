FROM node:20-bullseye

# 1. Install system dependencies (Keep this, it's correct!)
RUN apt-get update && apt-get install -y \
    libvips-dev python3 make g++ git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app

# 2. Copy dependency files first for better caching
COPY package*.json ./
RUN npm install --production && npm install pg --save

# 3. Copy your actual Strapi code from the local folder
COPY . .

# 4. Build the admin UI for production
RUN npm run build

# 5. Production Environment Variables
ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=1337

EXPOSE 1337

# 6. Start the optimized server
CMD ["npm", "run", "start"]