/**
* TestOrgCreationJob.groovy is used to produce Sustainability App test orgs for manual testing.
* The job requires two parameters (see properties stanza below):
* - An valid email address - the email address will be associated with the new user accounts on the test org
* - Org duration - the number of days this org will be available
*
* The job will use the dev hub defined in folder jenkins/properties/job.properties, create a new scratch org,
* push the application source to the scratch org, create two new user accounts on the org and then issue
* password reset requests for each user account.
* 
* At completion of the job an email is sent to email address provided to this job with details on the new test org.
*/

library identifier: 'salesforcedx-library'

// properties([
//     parameters([
//         string(defaultValue: '', description: 'Enter a valid email address that will be associated with the Manager and Auditor accounts created for you.', name: 'org_email', trim:true),
//         string(defaultValue: '7', description: '', name: 'scratch_org_duration', trim: true),
//         booleanParam(defaultValue: false, description: 'Include sample data in the scratch org', name: 'hasSampleData')
//     ])
// ])

node() {
    sh echo 'Test'
    sh 'env'
    // extract cliChannel from env
    deleteDir()
    checkout scm
    
    //def properties = readProperties file: 'jenkins/properties/job.properties'
    // merge project properties with Jenkins env
    //applyPropertiesToEnv(properties)
    // load library code for this repo
    // library identifier: 'sustain-library@master',
    //         retriever: modernSCM(github(apiUri: 'https://git.soma.salesforce.com/api/v3',
    //                 traits: [[$class: 'org.jenkinsci.plugins.github_branch_source.OriginPullRequestDiscoveryTrait', strategyId: 1]],
    //                 repoOwner: 'sustainability-cloud',
    //                 credentialsId: properties.GIT_SOMA_CRED_ID,
    //                 repository: 'Sustainability-App'))
    // withCredentials([file(credentialsId: properties.DEV_HUB_CONNECTED_APP_KEY_FILE_ID, variable: 'JWT_KEY_FILE'),
    //         string(credentialsId: properties.DEV_HUB_CONSUMER_KEY_ID, variable: 'CONSUMER_KEY')]) {
    //     withEnv(addSfdxEnvParams([
    //             "SFDX_USE_GENERIC_UNIX_KEYCHAIN=true",
    //             "HOME=${env.WORKSPACE}",
    //             "XDG_DATA_HOME=${env.WORKSPACE}",
    //             "SKIP_HEALTH_CHECKS=true",
    //             "SFDX_CMD=sfdx",
    //             "SFDX_NPM_REGISTRY=https://registry.npmjs.org/" // using public registry
    //     ])) 
    //     {
    //         def orgDetails
            
    //         try {
    //             stage('install sfdx cli and salesforcedx locally') {
    //                 installSfdxCli('./dx-cli', 'sfdx', env.SFDX_NPM_REGISTRY, ["salesforcedx@${properties.CLI_CHANNEL}"])
    //             }
    //             stage('auth to test dev hub') {
    //                 def dxCmd = "./dx-cli/${SFDX_CMD} force:auth:logout -u ${properties.DEV_HUB_USERNAME} --noprompt"
    //                 echo dxCmd
    //                 sh script: dxCmd, returnStatus: true
    //                 dxCmd = "./dx-cli/${SFDX_CMD} force:auth:jwt:grant -i ${CONSUMER_KEY} -f ${JWT_KEY_FILE} -u ${properties.DEV_HUB_USERNAME} -a SUSTAINDEVHUB"
    //                 echo dxCmd
    //                 sh dxCmd
    //             }
    //             stage('create test org') {
    //                 def dxCmd = "./dx-cli/${SFDX_CMD} force:org:create -f config/project-scratch-def.json -v ${properties.DEV_HUB_USERNAME} --durationdays ${params.scratch_org_duration} -s -a scratchOrg --json"
    //                 echo dxCmd
    //                 sh dxCmd
    //                 dxCmd = "./dx-cli/${SFDX_CMD} force:org:display -u scratchOrg --json"
    //                 echo dxCmd
    //                 (rc, orgDetails, stderr) = spawn(script: dxCmd, returnStatus: true, returnStdout: true, returnStderr: true, parseStdoutAsJson: true)
    //             }
    //             stage('push source') {
    //                 def dxCmd = "./dx-cli/${SFDX_CMD} force:source:push"
    //                 echo dxCmd
    //                 sh dxCmd
    //             }
    //             stage('inject sample data, if requested') {
    //                 def dxCmd = "./dx-cli/${SFDX_CMD} force:user:permset:assign -u scratchOrg -o scratchOrg -n SustainabilityAppManager"
    //                 echo dxCmd
    //                 sh dxCmd
    //                 dxCmd = "./dx-cli/${SFDX_CMD} force:user:permset:assign -u scratchOrg -o scratchOrg -n SustainabilityCloud"
    //                 echo dxCmd
    //                 sh dxCmd
    //                 if (params.hasSampleData) {
    //                     dxCmd = "./dx-cli/${SFDX_CMD} force:apex:execute -f scripts/PopulateData.apex -u scratchOrg"
    //                     echo dxCmd
    //                     sh dxCmd
    //                 }
    //             }
    //             stage('create users and request password reset') {
    //                 def dxCmd = "./dx-cli/${SFDX_CMD} force:user:create -f config/users/app_manager.json email=${params.org_email}"
    //                 echo dxCmd
    //                 sh dxCmd
    //                 dxCmd = "./dx-cli/${SFDX_CMD} force:user:create -f config/users/auditor.json email=${params.org_email}"
    //                 echo dxCmd
    //                 sh dxCmd
    //                 dxCmd = "./dx-cli/${SFDX_CMD} force:apex:execute -f scripts/reset_pwd.apex"
    //                 echo dxCmd
    //                 sh dxCmd
    //             }
    //             stage('email results') {
    //                 def days_or_day = params.scratch_org_duration == '1' ? 'day.' : 'days.'
    //                 emailext body: getEmailBody(orgDetails?.result?.instanceUrl, params.scratch_org_duration),
    //                     replyTo: 'no-reply@salesforce.com',
    //                     subject: 'Test org created for your use',
    //                     to: params.org_email
    //             }
    //         } finally {
    //             fileOperations([folderDeleteOperation('dx-cli')])
    //         }
    //     }
    // }
}
