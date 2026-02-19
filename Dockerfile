FROM node:20-bullseye

# 1. Install system dependencies
RUN apt-get update && apt-get install -y libvips-dev python3 make g++ git && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/app

# 2. Set Production environment variables BEFORE install/build
ENV NODE_ENV=production

# 3. Copy and install dependencies
COPY package*.json ./
# Using --include=dev because Strapi needs build tools to run 'npm run build'
RUN npm install --include=dev

# 4. Copy the rest of the application
COPY . .

# 5. Build the admin UI (non-interactive)
RUN npm run build

EXPOSE 1337

CMD ["npm", "run", "start"]
