## README

### Dockerfile Overview

This Dockerfile is designed to build a Go application using a multi-stage build approach, resulting in a smaller final image. The build stage uses the `golang:1.20-alpine` image to compile the Go code, and the final stage utilizes the minimal `alpine:latest` image to create a lightweight production image.

### Build Stage

1. **Base Image:** `golang:1.20-alpine`
2. **Working Directory:** `/app`
3. **Copy `go.mod` and `go.sum`:**
   - These are copied separately to take advantage of Docker layer caching. Dependencies will only be re-downloaded if these files change.
4. **Download Dependencies:**
   - `go mod download` is used to pre-download Go module dependencies.
   - `go mod verify` ensures the integrity of downloaded modules.
5. **Copy Source Code:**
   - Copies the entire source code into the container.
6. **Build Application:**
   - `go build -v -o app .` compiles the Go application and produces an executable named `app`.

### Final Stage

1. **Base Image:** `alpine:latest`
2. **Working Directory:** `/app`
3. **Copy `.env` File:**
   - Copies the environment file into the container.
4. **Copy Built Binary:**
   - Copies the compiled `app` binary from the build stage into the final image.
5. **Create Non-Root User:**
   - `adduser -D -u 1001 serviceuser` creates a non-root user named `serviceuser` with UID 1001.
   - `chown serviceuser:serviceuser /app/app` sets ownership of the application binary.
   - `chmod +x /app/app` makes the application binary executable.
6. **Switch to Non-Root User:**
   - `USER serviceuser` switches to the non-root user for improved security.
7. **Expose Port:**
   - `EXPOSE 8080` documents that the application inside the container listens on port 8080.
8. **Command to Run Application:**
   - `CMD ["./app"]` specifies the command to run the application when the container starts.

### Building and Running the Docker Image

To build the Docker image, run the following command in the directory containing the Dockerfile:

```bash
docker build -t your-image-name .
```

To run the container:

```bash
docker run -p 8080:8080 your-image-name
```

Replace `your-image-name` with the desired name for your Docker image.

### Additional Notes

- Make sure to customize the `EXPOSE` and `CMD` directives if your application uses a different port or command.
- Ensure that any runtime configurations required by your application are appropriately handled.
- This Dockerfile assumes that your application can run as a non-root user for security best practices. Adjustments may be needed depending on your specific use case.