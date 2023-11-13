# Build stage
FROM golang:1.20-alpine AS build

WORKDIR /app

# Pre-copy/cache go.mod for pre-downloading dependencies and only redownloading them in subsequent builds if they change
COPY go.mod go.sum ./
RUN go mod download && go mod verify

# Copy the source code into the container
COPY . .

# Build the Go application
RUN go build -v -o app .

# Final stage
FROM alpine:latest

WORKDIR /app/

COPY .env .

# Copy the built binary from the build stage
COPY --from=build /app/app .

# Create a non-root user and set ownership and permissions
RUN adduser -D -u 1001 serviceuser && \
    chown serviceuser:serviceuser /app/app && \
    chmod +x /app/app

USER serviceuser

# Expose the port your application listens on
EXPOSE 8080

# Command to run the application
CMD ["./app"]
