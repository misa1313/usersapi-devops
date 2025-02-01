pipeline {
    agent any

    environment {
        COMPONENT = "users-api"
        REGISTRY = "${env.DOCKER_REGISTRY}"
        CLUSTER_NAME = "${env.EKS_CLUSTER_NAME}"
        AWS_REGION = "${env.GLOBAL_AWS_REGION}"
        BANDIT_FAIL = ""
        GRYPE_FAIL = ""
        NAMESPACE = "default"
    }

    stages {
        stage('Lint and Test') {
            steps {
                withPythonEnv("/usr/bin/python3.9") {
                    script {
                        sh '''
                        docker run -d --name postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=userdb \
                        -p 5432:5432 postgres
                        '''

                        sh '''
                        python -m pip install --upgrade pip
                        pip install flake8 pylint black bandit bandit[sarif] nose
                        pip install -r requirements.txt
                        '''

                        // sh 'black --check .'

                        sh '''
                        flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics --ignore="F821,F822"
                        flake8 . --count --exit-zero --max-complexity=10 --max-line-length=120 --statistics
                        '''

                        sh 'pylint **/*.py || true' 

                        sh '''
                        export POSTGRES_HOST=localhost
                        export POSTGRES_PORT=5432
                        python -m nose tests.py
                        '''

                        sh '''
                        bandit -r . -f sarif -o bandit-report.sarif || echo "BANDIT_FAIL=true" 
                        '''
                    }
                }
            }
        }

        stage('Bandit Report Results') {
            when {
                expression { env.BANDIT_FAIL == "true" }
            }
            steps {
                echo "Bandit scan failed!"
                error("Exiting due to Bandit failure")
            }
        }

        stage('Docker Build and Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'USERNAME', passwordVariable: 'PASSWORD')]) {
                    sh '''
                        echo "$PASSWORD" | docker login -u "$USERNAME" --password-stdin

                        docker build -t ${COMPONENT}:latest .

                        docker tag ${COMPONENT}:latest ${REGISTRY}/${COMPONENT}:latest 

                        docker push ${REGISTRY}/${COMPONENT}:latest 

                        grype ${REGISTRY}/${COMPONENT}:latest  --fail-on medium -o sarif > grype-report.sarif || echo "GRYPE_FAIL=true" 
                    '''
                }
            }
        }

        stage('Grype Report Results') {
            when {
                expression { env.GRYPE_FAIL == "true" }
            }
            steps {
                echo "Grype scan failed!"
                error("Exiting due to Grype failure")
            }
        }

        stage('Archive Reports') {
            steps {
                archiveArtifacts artifacts: '*.sarif', fingerprint: true
            }
        }

        stage('AWS Authentication & Update Kubeconfig') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-creds',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh "aws eks --region ${AWS_REGION} update-kubeconfig --name ${CLUSTER_NAME}"
                    }
                }
            }
        }

        stage('Deploy Helm Chart') {
            steps {
                script {
                    withCredentials([[
                        $class: 'AmazonWebServicesCredentialsBinding',
                        credentialsId: 'aws-creds',
                        accessKeyVariable: 'AWS_ACCESS_KEY_ID',
                        secretKeyVariable: 'AWS_SECRET_ACCESS_KEY'
                    ]]) {
                        sh '''
                            helm dependency build ./chart
                            helm upgrade --install ${COMPONENT} ./chart -n ${NAMESPACE} -f ./chart/values.yaml 
                        '''
                    }
                }
            }
        }

    }

    post {
        always {
            script {
                sh 'docker stop postgres || true && docker rm postgres || true'
            }
        }
    }
}

