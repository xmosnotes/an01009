// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@v0.38.0') _

getApproval()
pipeline {
    agent {
        label 'documentation'
    }
    parameters {
        string(
            name: 'TOOLS_VERSION',
            defaultValue: '15.3.1',
            description: 'XTC tools version'
        )
        string(
            name: 'XMOSDOC_VERSION',
            defaultValue: 'v7.0.0',
            description: 'xmosdoc version'
        )
    }

    options {
        skipDefaultCheckout()
        timestamps()
        buildDiscarder(xmosDiscardBuildSettings(onlyArtifacts = false))
    }

    stages {
        stage('Checkout') {
            steps{

                println "Stage running on ${env.NODE_NAME}"

                script {
                    def (server, user, repo) = extractFromScmUrl()
                    env.REPO_NAME = repo
                }

                dir(REPO_NAME)
                {
                    checkoutScmShallow()
                }
            }
        }

        stage('Code build') {
            steps{
                dir(REPO_NAME) {
                    xcoreBuild()
                }
            }
        }

        stage('Doc build') {
            steps {
                dir(REPO_NAME) {
                    createVenv()
                    // Force Python doc build as docker-based xmosdoc can't access lib_xud in sandbox
                    buildDocs(xmosdocVenvPath: "${REPO_NAME}")
                }
            }
        }

        stage("Archive sandbox") {
            steps
            {
                archiveSandbox(REPO_NAME)
            }
        }

    } // stages
    post
    {
        cleanup
        {
             xcoreCleanSandbox()
        }
    }
} // pipeline
