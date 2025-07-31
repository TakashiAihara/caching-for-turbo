# Stage 1: Build the application
FROM node:22.17.1-slim AS builder

WORKDIR /app

# Install dependencies
COPY package.json package-lock.json ./
RUN npm ci

# Copy source and build
COPY . .
RUN npm run package

# Stage 2: Create the final, lean image
FROM gcr.io/distroless/nodejs22-debian12

WORKDIR /app

# Copy only the built application from the builder stage
COPY --from=builder /app/dist ./dist

# Expose the port the app runs on
ENV TURBOGHA_SERVER_HOST=0.0.0.0
ENV TURBOGHA_PORT=41230

EXPOSE 41230

# Define the command to run the app
CMD ["dist/cli/index.js", "start", "--foreground"]