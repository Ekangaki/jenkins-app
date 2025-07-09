# jenkins-app

# Building and Dockerizing a Node.js Application
Dockerizing a Node.js application involves creating a Docker image that contains your application and all its dependencies, making it portable and consistently runnable across any environment that has Docker.

# Prerequisites:
Node.js Project: You need an existing Node.js application (even a simple "Hello World" one).

Node.js and npm/yarn installed locally: To test your app before Dockerizing.

Docker Desktop (or Docker Engine) installed: To build and run Docker images.

Step 1: Prepare Your Node.js Application
Ensure your Node.js application is ready for deployment.

Project Structure:
A typical Node.js project looks something like this:


## Building and Dockerizing a Node.js Application

Dockerizing a Node.js application involves creating a Docker image that contains your application and all its dependencies, making it portable and consistently runnable across any environment that has Docker.

### **Prerequisites:**

1.  **Node.js Project:** You need an existing Node.js application (even a simple "Hello World" one).
2.  **Node.js and npm/yarn installed locally:** To test your app before Dockerizing.
3.  **Docker Desktop (or Docker Engine) installed:** To build and run Docker images.

### **Step 1: Prepare Your Node.js Application**

Ensure your Node.js application is ready for deployment.

1.  **Project Structure:**
    A typical Node.js project looks something like this:
    ```
    my-node-app/
    ├── node_modules/
    ├── public/
    ├── src/
    │   └── app.js
    ├── package.json
    ├── package-lock.json (or yarn.lock)
    └── .env (optional)
    ```

2.  **`package.json`:** Make sure your `package.json` has a `start` script defined, as this is commonly used by Docker to run your application.

    **Example `package.json`:**
    ```json
    {
      "name": "my-node-app",
      "version": "1.0.0",
      "description": "A simple Node.js app",
      "main": "src/app.js",
      "scripts": {
        "start": "node src/app.js",
        "test": "echo \"Error: no test specified\" && exit 1"
      },
      "dependencies": {
        "express": "^4.18.2"
      }
    }
    ```

3.  **Simple Node.js Application (`src/app.js`):**
    For demonstration, let's create a basic Express app.

    ```javascript
    // src/app.js
    const express = require('express');
    const app = express();
    const PORT = process.env.PORT || 3000;

    app.get('/', (req, res) => {
      res.send('Hello from Dockerized Node.js App!');
    });

    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
    ```

### **Step 2: Create a `Dockerfile`**

The `Dockerfile` is a text file that contains instructions for building a Docker image. Create a file named `Dockerfile` (no extension) in the root of your project directory (`my-node-app/Dockerfile`).

```dockerfile
# Stage 1: Build the application (using a multi-stage build)
# Use a slim Node.js image as the base for building
FROM node:20-slim AS builder

# Set the working directory inside the container
WORKDIR /app

# Copy package.json and package-lock.json (or yarn.lock) first
# This allows Docker to use cached layers if dependencies haven't changed
COPY package*.json ./

# Install dependencies
RUN npm install --omit=dev # For production builds, skip dev dependencies

# Copy the rest of the application source code
COPY . .

# Stage 2: Create the final, smaller production image
FROM node:20-alpine # Use a smaller, production-ready base image

# Set the working directory
WORKDIR /app

# Copy only the necessary files from the builder stage
# This includes node_modules and the application code
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/src ./src
COPY --from=builder /app/package.json ./package.json # Copy package.json if needed for 'npm start'

# Expose the port your application listens on
EXPOSE 3000

# Define the command to run your application when the container starts
CMD ["npm", "start"]

### **Step 3: Create a .dockerignore file**
