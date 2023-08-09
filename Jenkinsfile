pipeline {
    agent any

    stages {
        stage('Terraform') {
            steps {
                sh 'terraform init'
                sh 'terraform plan -out=tfplan'
            }
        }
        
        stage('Apply Terraform Changes') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }

        stage('Ansible') {
            steps {
                // Run Ansible playbooks
                sh 'ansible-playbook -i inventory playbook.yml'
            }
        }

        stage('Post-deployment') {
            steps {
                // Perform post-deployment actions
            }
        }
    }
}

pipeline {
    agent any

    environment {
        GCS_BUCKET = "your-gcs-bucket-name"
        SOURCE_DIR = "path/to/source/dir" // Directory to backup or restore from
    }

    stages {
        stage('Backup to GCS') {
            steps {
                script {
                    sh "gsutil -m rsync -r ${SOURCE_DIR} gs://${GCS_BUCKET}/backup/"
                }
            }
        }

        stage('Restore from GCS') {
            steps {
                script {
                    sh "gsutil -m rsync -r gs://${GCS_BUCKET}/backup/ ${SOURCE_DIR}"
                }
            }
        }
    }
}
