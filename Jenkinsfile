pipeline {
    agent any

    tools {
        jdk 'JAVA_HOME'
        maven 'M2_HOME'
    }

    environment {
        DOCKERHUB_USER = 'mahmoudmsolly77'
        IMAGE_NAME     = 'mahmoudmsolly-5erpbi1-gestionprojets'
        BACKEND_IMAGE  = "${DOCKERHUB_USER}/${IMAGE_NAME}"
        FRONTEND_IMAGE = "${DOCKERHUB_USER}/${IMAGE_NAME}-frontend"
        TAG            = "${BUILD_NUMBER}"
        SONAR_URL      = 'http://localhost:9000'
    }

    stages {
        stage('Checkout GIT') {
            steps {
                // The code is already fetched by "Declarative: Checkout SCM"
                sh 'git log -1 --oneline'
            }
        }

        stage('Maven Clean & Compile') {
            steps {
                dir('backend') {
                    sh 'mvn -B clean compile'
                }
            }
        }

        stage('Tests Unitaires') {
            steps {
                dir('backend') {
                    sh 'mvn -B test'
                }
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: 'backend/target/surefire-reports/*.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('backend') {
                    withCredentials([string(credentialsId: 'sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh 'mvn -B org.sonarsource.scanner.maven:sonar-maven-plugin:4.0.0.4121:sonar -Dsonar.host.url=$SONAR_URL -Dsonar.login=$SONAR_TOKEN'
                    }
                }
            }
        }

        stage('Maven Package') {
            steps {
                dir('backend') {
                    sh 'mvn -B package -DskipTests'
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'backend/target/*.jar', fingerprint: true
                }
            }
        }

        stage('Build Docker Images') {
            steps {
                sh 'docker build -t $BACKEND_IMAGE:$TAG -t $BACKEND_IMAGE:latest backend'
                sh 'docker build -t $FRONTEND_IMAGE:$TAG -t $FRONTEND_IMAGE:latest frontend'
            }
        }

        stage('Push DockerHub') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
                    sh 'docker push $BACKEND_IMAGE:$TAG && docker push $BACKEND_IMAGE:latest'
                    sh 'docker push $FRONTEND_IMAGE:$TAG && docker push $FRONTEND_IMAGE:latest'
                }
            }
        }

        stage('Deploy (Docker Compose)') {
            steps {
                sh 'docker compose up -d --no-build'
                sh 'docker compose ps'
            }
        }
    }

    post {
        always {
            sh 'docker logout || true'
        }
        success {
            echo "Pipeline OK - image ${BACKEND_IMAGE}:${TAG} deployed"
        }
        failure {
            echo 'Pipeline FAILED'
        }
    }
}
