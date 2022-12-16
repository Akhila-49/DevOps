def image = null
pipeline{
    agent any
    stages{
        stage('user input'){
            steps{
                script{
                    image = input(
                        message: 'enter the image name',
                        ok: 'Submit',
                        parameters: [string(defaultValue: 'nginx', name: 'image name')]
                    )
                }
            }
        }

        stage('launch container'){
            steps{
                sh """
                cd
                whoami
                pwd
                IMAGE=${image} docker-compose up -d
                """
            }
        }
        stage('list all containers'){
            steps{
                sh """
                docker ps -a
                """
            }
        }
    }
}
