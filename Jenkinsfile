#!groovy

node {
    def properties = readProperties file: 'job.properties'
    merge project properties with Jenkins env
    applyPropertiesToEnv(properties)

    def BUILD_NUMBER=env.BUILD_NUMBER
    def RUN_ARTIFACT_DIR="tests/${BUILD_NUMBER}"
    def DEV_HUB = properties.SF_USERNAME
    def CONNECTED_APP_CONSUMER_KEY = properties.SF_CONSUMER_KEY
    def SERVER_KEY_CREDENTIALS_ID = env.SERVER_KEY_CREDENTIALS_ID

    println DEV_HUB
    println 'env.BRANCH_NAME 'env.BRANCH_NAME
    println 'CHANGE_BRANCH 'CHANGE_BRANCH
    println 'CHANGE_TARGET 'CHANGE_TARGET

    def toolbelt = tool 'toolbelt'

    stage('checkout source') {
        // when running in multi-branch job, one must issue this command
        checkout scm
    }

    withCredentials([file(credentialsId: SERVER_KEY_CREDENTIALS_ID, variable: 'jwt_key_file')]) {
        stage('Authorize to Salesforce') {
			rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:auth:jwt:grant --clientid ${CONNECTED_APP_CONSUMER_KEY} --jwtkeyfile ${jwt_key_file} --username ${DEV_HUB} "
		    if (rc != 0) {
			    error 'Salesforce org authorization failed.'
		    }
		}

        stage('Create Scratch Org') {
            rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:org:create --definitionfile config/project-scratch-def.json --setdefaultusername"
            println rc
            if (rc != 0) {
                error 'create scratch org error'
            }
        }

        stage('Push To Scratch Org') {
            rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:source:push "
            if (rc != 0) {
                echo 'push failed'
            }
        }

        stage('Run test') {
            sh "mkdir -p ${RUN_ARTIFACT_DIR}"
            timeout(time: 180, unit: 'SECONDS') {
                rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:apex:test:run --testlevel RunLocalTests --outputdir ${RUN_ARTIFACT_DIR} --resultformat human "
                if (rc != 0) {
                    echo 'run test failed'
                }
            }
        }

        stage('Delete Scratch Org') {
            rc = sh returnStatus: true, script: "${toolbelt}/sfdx force:org:delete --noprompt"
            if (rc != 0) {
                error 'delete failed'
            }
        }
    }
}