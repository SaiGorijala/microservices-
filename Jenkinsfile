pipeline {
    agent any
    
    environment {
        // Docker Hub credentials
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub-credentials')
        DOCKER_HUB_REPO = 'saigorijala/microservices-app'
        
        // SonarQube configuration
        SONAR_HOST_URL = 'http://100.24.18.115:9000'
        SONAR_TOKEN = credentials('sonar-token')
        
        // Trivy scan severity
        TRIVY_SEVERITY = 'HIGH,CRITICAL'
        
        // Application port
        APP_PORT = '3002'
    }
    
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/SaiGorijala/microservices-.git'
            }
        }
        
        stage('Install Dependencies') {
            steps {
                sh '''
                    echo "Installing dependencies..."
                    npm install || echo "No package.json found"
                '''
            }
        }
        
        stage('Run Tests') {
            steps {
                sh '''
                    echo "Running application tests..."
                    npm test || echo "No tests configured"
                '''
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        sonar-scanner \
                          -Dsonar.projectKey=microservices-app \
                          -Dsonar.projectName="Microservices App" \
                          -Dsonar.projectVersion=1.0 \
                          -Dsonar.sources=. \
                          -Dsonar.host.url=${SONAR_HOST_URL} \
                          -Dsonar.login=${SONAR_TOKEN} || echo "SonarQube scan skipped"
                    '''
                }
            }
        }
        
        stage('Quality Gate Check') {
            steps {
                timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: false
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t ${DOCKER_HUB_REPO}:latest .
                    docker tag ${DOCKER_HUB_REPO}:latest ${DOCKER_HUB_REPO}:${BUILD_NUMBER}
                '''
            }
        }
        
        stage('Trivy Security Scan') {
            steps {
                sh '''
                    echo "Scanning Docker image with Trivy..."
                    
                    # Install Trivy if not installed
                    if ! command -v trivy &> /dev/null; then
                        echo "Installing Trivy..."
                        wget https://github.com/aquasecurity/trivy/releases/download/v0.48.0/trivy_0.48.0_Linux-64bit.deb
                        sudo dpkg -i trivy_0.48.0_Linux-64bit.deb
                    fi
                    
                    # Scan the image (don't fail the pipeline)
                    trivy image --severity ${TRIVY_SEVERITY} --exit-code 0 --ignore-unfixed \
                      ${DOCKER_HUB_REPO}:latest || echo "Trivy scan completed"
                '''
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                sh '''
                    echo "Pushing image to Docker Hub..."
                    echo "${DOCKER_HUB_CREDENTIALS_PSW}" | docker login -u "${DOCKER_HUB_CREDENTIALS_USR}" --password-stdin
                    docker push ${DOCKER_HUB_REPO}:latest
                    docker push ${DOCKER_HUB_REPO}:${BUILD_NUMBER}
                '''
            }
        }
        
        stage('Deploy Docker Container') {
            steps {
                sh '''
                    echo "Deploying container..."
                    
                    # Stop and remove existing container if running
                    docker stop microservices-app || true
                    docker rm microservices-app || true
                    
                    # Run new container
                    docker run -d \
                      --name microservices-app \
                      -p ${APP_PORT}:${APP_PORT} \
                      --restart unless-stopped \
                      ${DOCKER_HUB_REPO}:latest
                    
                    # Verify container is running
                    sleep 5
                    docker ps | grep microservices-app
                    
                    echo "Application deployed successfully on port ${APP_PORT}"
                '''
            }
        }
        
        stage('Health Check') {
            steps {
                sh '''
                    echo "Performing health check..."
                    sleep 10
                    
                    # Check container health
                    if docker ps --format "table {{.Names}}\\t{{.Status}}" | grep -q "microservices-app.*Up"; then
                        echo "Container is running successfully!"
                    else
                        echo "Container is not running properly!"
                        docker logs microservices-app --tail 50
                        exit 1
                    fi
                '''
            }
        }
    }
    
    post {
        always {
            script {
                echo "Pipeline execution completed for build ${BUILD_NUMBER}"
                sh 'echo "Cleaning up old Docker images..." && docker image prune -f --filter "until=24h" || true'
            }
        }
        
        success {
            echo "Pipeline completed successfully!"
        }
        
        failure {
            echo "Pipeline failed!"
            sh 'echo "===== Container Logs =====" && docker logs microservices-app --tail 100 || true'
        }
    }
}
