pipeline {
    agent {
        label 'kaniko-git'
    }

    options {
        skipDefaultCheckout(true)
    }

    environment {
        AWS_REGION = 'us-west-2'
        ECR_REPOSITORY = '894662486142.dkr.ecr.us-west-2.amazonaws.com/lesson-8-9-ecr'
        CHART_VALUES_FILE = 'charts/django-app/values.yaml'
        TARGET_BRANCH = 'main'
        SOURCE_BRANCH = 'lesson-8-9'
        GIT_SSH_CREDENTIALS_ID = 'github-rsa-key'
        GIT_REPOSITORY_SSH = 'git@github.com:vmix-woolf/jenkins-lesson-8-9.git'
        GIT_USER_NAME = 'jenkins'
        GIT_USER_EMAIL = 'jenkins@example.com'
    }

    stages {
        stage('checkout') {
            steps {
                container('git') {
                    sshagent(credentials: ["${GIT_SSH_CREDENTIALS_ID}"]) {
                        sh '''
                            mkdir -p ~/.ssh
                            ssh-keyscan -t rsa,ecdsa,ed25519 github.com > ~/.ssh/known_hosts
                            chmod 700 ~/.ssh
                            chmod 644 ~/.ssh/known_hosts

                            git clone --branch "${SOURCE_BRANCH}" "${GIT_REPOSITORY_SSH}" .
                            git config --global --add safe.directory "${WORKSPACE}"
                            git status
                        '''
                    }
                }
            }
        }

        stage('generate image tag') {
            steps {
                container('git') {
                    script {
                        env.IMAGE_TAG = sh(
                            script: 'git rev-parse --short HEAD',
                            returnStdout: true
                        ).trim()
                    }

                    echo "Image tag: ${IMAGE_TAG}"
                }
            }
        }

        stage('build and push image with kaniko') {
            steps {
                container('kaniko') {
                    sh '''
                        /kaniko/executor \
                          --context "${WORKSPACE}/app" \
                          --dockerfile "${WORKSPACE}/app/Dockerfile" \
                          --destination "${ECR_REPOSITORY}:${IMAGE_TAG}" \
                          --destination "${ECR_REPOSITORY}:latest"
                    '''
                }
            }
        }

        stage('update helm values') {
            steps {
                container('git') {
                    sh '''
                        sed -i "s|tag: .*|tag: ${IMAGE_TAG}|g" "${CHART_VALUES_FILE}"

                        echo "Updated Helm values:"
                        grep -A 4 "^image:" "${CHART_VALUES_FILE}"
                    '''
                }
            }
        }

        stage('commit and push helm values') {
            steps {
                container('git') {
                    sshagent(credentials: ["${GIT_SSH_CREDENTIALS_ID}"]) {
                        sh '''
                            git config user.name "${GIT_USER_NAME}"
                            git config user.email "${GIT_USER_EMAIL}"

                            if git diff --quiet "${CHART_VALUES_FILE}"; then
                              echo "No Helm values changes to commit"
                              exit 0
                            fi

                            git add "${CHART_VALUES_FILE}"
                            git commit -m "update django image tag to ${IMAGE_TAG}"
                            git push origin HEAD:${TARGET_BRANCH}
                        '''
                    }
                }
            }
        }
    }
}