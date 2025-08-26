pipeline {
    agent any

    environment {
        GIT_REPO_URL     = 'https://github.com/Ekangaki/jenkins-app.git'
        GIT_BRANCH       = 'main'
        APP_NAME         = 'jenkins-app'
        DOCKERHUB_ORG    = 'ekangaki'
        DOCKER_IMAGE_TAG = "${DOCKERHUB_ORG}/${APP_NAME}"
        CONTAINER_PORT   = '3000'      // Adjust if needed
        HOST_PORT        = '3000'      // Adjust if needed
    }
        triggers {
        // This is the trigger that listens for a push to the GitHub repository.
        githubPush()
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo "📥 Cloning ${GIT_REPO_URL} (branch: ${GIT_BRANCH})"
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO_URL}"
            }
        }

        stage('Install Dependencies') {
            steps {
                echo "📦 Installing app dependencies using npm"
                sh 'npm install'
            }
        }

        stage('Build Application') {
            steps {
                echo "⚙️ Building the frontend app"
                sh 'npm run build'
            }
        }

        stage('Build Docker Image') {
            steps {
                echo "🐳 Building Docker image: ${DOCKER_IMAGE_TAG}:${env.BUILD_NUMBER}"
                sh "docker build -t ${DOCKER_IMAGE_TAG}:${env.BUILD_NUMBER} ."
                sh "docker tag ${DOCKER_IMAGE_TAG}:${env.BUILD_NUMBER} ${DOCKER_IMAGE_TAG}:latest"
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo "📤 Pushing image to DockerHub"
                withCredentials([usernamePassword(
                    credentialsId: 'docker-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                    sh "docker push ${DOCKER_IMAGE_TAG}:${env.BUILD_NUMBER}"
                    sh "docker push ${DOCKER_IMAGE_TAG}:latest"
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                echo "🚀 Running container from image"
                // Stop and remove existing container if any
                sh "docker rm -f ${APP_NAME} || true"
                // Run container detached and map port
                sh "docker run -d -p ${HOST_PORT}:${CONTAINER_PORT} --name ${APP_NAME} ${DOCKER_IMAGE_TAG}:${env.BUILD_NUMBER}"
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully!"
        }
        failure {
            echo "❌ Pipeline failed. Please check the error logs."
        }
    }
}
