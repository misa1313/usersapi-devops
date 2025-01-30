pipeline {
    agent any

    environment {
        COMPONENT = "users-api"
        BANDIT_FAIL = ""
        GRYPE_FAIL = ""
    }

    stages {
        stage('Lint and Test') {
            agent {
                docker {
                    image 'python:3.9'
                    args '--network=host'  
                }
            }
            steps {
                script {
                    sh '''
                    docker run -d --name postgres -e POSTGRES_PASSWORD=password -e POSTGRES_DB=userdb \
                    -p 5432:5432 postgres
                    '''

                    sh '''
                    python3 -m pip install --upgrade pip
                    pip install flake8 pylint black bandit bandit[sarif] nose
                    pip install -r requirements.txt
                    '''

                    sh 'black --check .'

                    sh '''
                    flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
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

        stage('Upload Bandit Report') {
            when {
                expression { env.BANDIT_FAIL == "true" }
            }
            steps {
                echo "Bandit scan failed!"
                error("Exiting due to Bandit failure")
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    sh '''
                    docker build -t ${COMPONENT}:latest .
                    '''

                    sh '''
                    grype ${COMPONENT}:latest --fail-on medium -o sarif > grype-report.sarif || echo "GRYPE_FAIL=true" 
                    '''
                }
            }
        }

        stage('Upload Grype Report') {
            when {
                expression { env.GRYPE_FAIL == "true" }
            }
            steps {
                echo "Grype scan failed!"
                error("Exiting due to Grype failure")
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

