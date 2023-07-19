pipeline {
      agent {
        docker {
            image 'zedfurios/gradles:v2'
            args  '-u 0:0 --net host --privileged -v /var/run/docker.sock:/var/run/docker.sock -v /opt/jenkins:/home/gradle'
            reuseNode 'true'
         }    
       }
  stages {
    stage('Checkout') {
      steps {
               git branch: 'main',
               url: 'https://Zedfurios@bitbucket.org/zedfuriosapp/androidci.git'
            }
         }
    stage("sonar-scan"){
      steps{
          //sonarscanner
                  withSonarQubeEnv('sonar-scanner') {
          sh "/opt/sonar/sonar-scanner-4.8.0.2856-linux/bin/sonar-scanner"
           }
      }
    }
    stage('Quality gate') {
      steps {
            timeout(time: 5, unit: 'MINUTES') {
            waitForQualityGate abortPipeline: true
                  }
                }
              }
    stage('Build') {
      steps {
        // env.ANDROID_HOME = '/opt/sdk/'
        // build app using gradle
          sh '''
                    #!/bin/bash
                     chmod +x gradlew  
                    ./gradlew clean  
                    ./gradlew assembleDebug  
                '''
      }
    }
    stage("Fetch the artifect"){
        steps{
           //move the artifact to a folder
           sh 'cp -r /var/lib/jenkins/workspace/apkvs2@2/app/build/outputs/apk/ /home/gradle'
     }
   }
 }
}
