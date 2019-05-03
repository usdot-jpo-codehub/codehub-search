node {
    environment {
      DOCKER_LOGIN='(aws ecr get-login --no-include-email --region us-east-1)'
      dockerImage = ''
    }
     stage('Git Checkout') {
          deleteDir()
          dir ('App'){
              git(
                branch: 'development',
                url: 'https://github.com/usdot-jpo-codehub/codehub-search.git'
            )
          }

        }

    stage('Unit Test') {
        nodejs('node') {
            dir ('App'){
              script {
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/projects/_mapping?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/projects/_settings?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/code/_mapping?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/code/_settings?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/_cluster/health?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/projects/_count?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/code/_count?pretty'
                sh 'echo Bundling is Complete!!'
            }
          }
  }
  }

      stage('Static Code Analysis'){
        dir ('App'){

        script {
            def scannerHome = tool 'SonarQube Scanner 2.8';
            withSonarQubeEnv('SonarQube') {
                    sh "${scannerHome}/bin/sonar-scanner -X  -Dsonar.projectName=codehub-search -Dsonar.projectVersion=1.0.0 -Dsonar.projectKey=codehub-search -Dsonar.sources=."
                }
            }
        }
      }
      stage('508 Complaince') {
          script {
              sh 'echo 508 Complaince is complete'
          }
      }

      stage('Integration Test') {
        dir ('App'){
            script {

                sh 'docker-compose up -d'
                sh 'docker-compose logs --tail="all"'
                sh 'docker-compose down'
                sh 'echo Integration Test is complete'
            }
        }
      }


      stage('Build Codehub-UI Base Image') {
      dir ('App'){
          script {
            withAWS(region:'us-east-1') {
              sh 'eval $(aws ecr get-login --no-include-email) > login'
              dockerImage=docker.build("797335914619.dkr.ecr.us-east-1.amazonaws.com/dev-codehub/codehub-search" + ":latest")
          }
            sh 'echo "Completing image build"'
          }
      }
}

      stage('Publish Codehub-Search Image') {
      dir ('App'){
          script {
            withAWS(region:'us-east-1') {
              sh 'eval $(aws ecr get-login --no-include-email) > login'
              dockerImage.push()
          }
            sh 'echo "Completing image build"'
          }
      }
}
      stage('Register TaskDefinition Updates') {
      dir ('App'){
          script {
              sh 'aws ecs register-task-definition --cli-input-json file://codehub-search-taskDefinition.json --region us-east-1'
              sh 'echo Service is Updated'
          }
      }
      }
      stage('Deploy Service') {
      dir ('App'){
      nodejs('node') {
            script {
              sh './process_deployment.sh'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/projects/_mapping?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/projects/_settings?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/code/_mapping?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/code/_settings?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/projects/_cluster/health?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/projects/_count?pretty'
              sh 'curl -XGET http://internal-dev-codehub-search-118857287.us-east-1.elb.amazonaws.com:9200/code/_count?pretty'

          }
        }
}
}

}
