// This file relates to internal XMOS infrastructure and should be ignored by external users

@Library('xmos_jenkins_shared_library@v0.36.0')

def archiveSandbox(String repoName) {
    sh "cp ${WORKSPACE}/${repoName}/build/manifest.txt ${WORKSPACE}"
    sh "rm -rf .get_tools .venv"
    sh "git -C ${repoName} clean -xdf"
    def repoNameUpper = repoName.toUpperCase()
    zip zipFile: "${repoNameUpper}_sw.zip", archive: true, defaultExcludes: false
}

getApproval()
pipeline {
    agent {
        label 'documentation'
    }
    parameters {
        string(
            name: 'TOOLS_VERSION',
            defaultValue: '15.3.0',
            description: 'XTC tools version'
        )
        string(
            name: 'XMOSDOC_VERSION',
            defaultValue: 'v6.2.0',
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
                    buildDocs()
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
