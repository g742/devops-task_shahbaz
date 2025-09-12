pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-2'
        ECR_REPO = '423755636060.dkr.ecr.us-east-2.amazonaws.com/golu'
        IMAGE_TAG = "${BUILD_NUMBER}"
        KUBECONFIG = "${WORKSPACE}/kubeconfig"
    }

    stages {
        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/g742/devops-task_shahbaz.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                docker build -t ${ECR_REPO}:${IMAGE_TAG} .
                """
            }
        }

        stage('Login to ECR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-credentials', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    sh """
                        aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID
                        aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY
                        aws configure set region ${AWS_REGION}
                        aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                    """
                }
            }
        }

        stage('Push Image to ECR') {
            steps {
                sh "docker push ${ECR_REPO}:${IMAGE_TAG}"
            }
        }

        stage('Update Kubeconfig') {
            steps {
                sh """
                    aws eks update-kubeconfig --region ${AWS_REGION} --name my-cluster --kubeconfig ${KUBECONFIG}
                """
            }
        }

        stage('Apply Kubernetes Deployment') {
            steps {
                sh """
                    kubectl --kubeconfig=${KUBECONFIG} apply -f /home/ubuntu/deployment.yaml
                """
            }
        }

        stage('Update Image in Deployment') {
            steps {
                sh """
                    kubectl --kubeconfig=${KUBECONFIG} set image deployment/nginx-deployment swayatt=${ECR_REPO}:${IMAGE_TAG}
                    kubectl --kubeconfig=${KUBECONFIG} rollout status deployment/nginx-deployment

                """
            }
        }
    }

    post {
        failure {
            echo "Deployment failed!"
        }
        success {
            echo "App deployed successfully to EKS!"
        }
    }
}
