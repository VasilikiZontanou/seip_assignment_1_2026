# Use a lightweight base image 
FROM node:18-alpine

WORKDIR /app

# Smart caching
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the source code
COPY . .

# Expose port 3000
EXPOSE 3000

CMD ["node", "server.js"]