// Jenkinsfile
pipeline {
    agent any

    environment {
        // --- Existing Variables ---
        GIT_REPO_URL     = 'https://github.com/Ekangaki/jenkins-app.git' // Your application's repo
        GIT_BRANCH       = 'main'
        APP_NAME         = 'jenkins-app'
        DOCKERHUB_ORG    = 'ekangaki'
        CONTAINER_PORT   = '3000'

        // --- Docker Image Variables ---
        DOCKER_IMAGE_BASE       = "${DOCKERHUB_ORG}/${APP_NAME}"
        DOCKER_IMAGE_FULL_TAG   = "${DOCKER_IMAGE_BASE}:${env.BUILD_NUMBER}"
        DOCKER_IMAGE_LATEST_TAG = "${DOCKER_IMAGE_BASE}:latest"

        // --- NEW Kubernetes Deployment Variables (Adjusted for same repo) ---
        // Your K8s manifests are now relative to the current workspace
        K8S_MANIFESTS_PATH = 'deploy' // The folder within this repo that contains the YAMLs
        K8S_DEPLOYMENT_FILE = 'jenkins-app-deployment.yaml' // The specific K8s Deployment file to update
        K8S_SERVICE_FILE = 'jenkins-app-service.yaml' // The specific K8s Service file (optional, but good practice)
        K8S_NAMESPACE = 'jenkins-app-ns' // The Kubernetes namespace where the app will be deployed
    }

    stages {
        stage('Clone Application Repository') {
            steps {
                echo "📥 Cloning ${GIT_REPO_URL} (branch: ${GIT_BRANCH})"
                git branch: "${GIT_BRANCH}", url: "${GIT_REPO_URL}"
                // Note: The workspace now contains your app code AND your K8s manifests under 'deploy/'
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
                echo "🐳 Building Docker image: ${DOCKER_IMAGE_FULL_TAG}"
                sh "docker build -t ${DOCKER_IMAGE_FULL_TAG} ."
                sh "docker tag ${DOCKER_IMAGE_FULL_TAG} ${DOCKER_IMAGE_LATEST_TAG}"
            }
        }

        stage('Push to DockerHub') {
            steps {
                echo "📤 Pushing image to DockerHub"
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds', // Make sure this Jenkins credential ID matches
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "docker login -u ${DOCKER_USER} -p ${DOCKER_PASS}"
                    sh "docker push ${DOCKER_IMAGE_FULL_TAG}"
                    sh "docker push ${DOCKER_IMAGE_LATEST_TAG}"
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                echo "📝 Updating Kubernetes manifest in application repository"
                script {
                    // Define the old and new image strings for sed
                    def oldImageRegex = "${DOCKER_IMAGE_BASE}:.*" // Matches 'ekangaki/jenkins-app:' followed by any tag
                    def newImageTag = "${DOCKER_IMAGE_FULL_TAG}"   // e.g., 'ekangaki/jenkins-app:123'

                    // Update the deployment file using sed
                    echo "Updating image tag from '${oldImageRegex}' to '${newImageTag}' in ${K8S_MANIFESTS_PATH}/${K8S_DEPLOYMENT_FILE}"
                    sh "sed -i 's|${oldImageRegex}|${newImageTag}|g' ${K8S_MANIFESTS_PATH}/${K8S_DEPLOYMENT_FILE}"

                    echo "Committing and pushing updated manifest..."
                    // These git configs ensure the commit shows up nicely in GitHub
                    sh "git config user.email 'jenkins@example.com'"
                    sh "git config user.name 'Jenkins CI'"
                    sh "git add ${K8S_MANIFESTS_PATH}/${K8S_DEPLOYMENT_FILE}"
                    sh "git commit -m '[skip ci] Update ${APP_NAME} image to ${newImageTag}'"
                    // The '[skip ci]' in the commit message is CRUCIAL here.
                    // It prevents an infinite build loop: Jenkins pushes, GitHub receives, triggers Jenkins again.
                    // Make sure your GitHub webhook or polling configuration is set up to respect this.
                    sh "git push origin ${GIT_BRANCH}" // Push back to the *same* repository
                }
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline completed successfully! Image pushed and K8s manifest updated."
        }
        failure {
            echo "❌ Pipeline failed. Please check the error logs."
        }
    }
}
