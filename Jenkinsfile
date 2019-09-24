node{
//Define all variables
  def project = 'eighth-service-250517'
  def appName = 'hello-world'
  def serviceName = "${appName}-backend"  
  def imageVersion = 'development'
  def namespace = 'development'
  def feSvcName = 'hello-world'
  def imageTag = "gcr.io/${project}/${appName}:${imageVersion}.${env.BUILD_NUMBER}"
  
  //Checkout Code from Git
  checkout scm
  
  //Stage 1 : Build the docker image.
  stage('Build image') {
      sh("docker build -t ${imageTag} .")
  }
  
  //Stage 2 : Push the image to docker registry
  stage('Push image to registry') {
    withEnv(['GCLOUD_PATH=/home/bontsrik/google-cloud-sdk/bin']) {
      withCredentials([[$class: 'FileBinding', credentialsId:'Gcloud',variable:'Gcloud']]) {
              sh ("${GCLOUD_PATH}/gcloud auth activate-service-account --key-file ${Gcloud}")
              sh("${GCLOUD_PATH}/gcloud docker -- push ${imageTag}")
}
 }
  }
  
  //Stage 3 : Deploy Application
  stage('Deploy Application') {
       switch (namespace) {
              //Roll out to Dev Environment
              case "development":
                   withEnv(['GCLOUD_PATH=/home/bontsrik/google-cloud-sdk/bin']){
                   // Create a one node cluster in google cloud  
                   sh("${GCLOUD_PATH}/gcloud container clusters create hello-world-cluster --num-nodes 1 --machine-type n1-standard-1 --zone us-central1-c --project=eighth-service-250517") 
                   // Establishing connection to Created cluster so that access can be made through SDK 
                   sh("${GCLOUD_PATH}/gcloud container clusters get-credentials hello-world-cluster --zone us-central1-c --project eighth-service-250517")
                   // Create namespace if it doesn't exist
                   sh("kubectl get ns ${namespace} || kubectl create ns ${namespace}")
           //Update the imagetag to the latest version
                   sh("sed -i.bak 's#gcr.io/${project}/${appName}:${imageVersion}#${imageTag}#' ./k8s/development/*.yaml")
                   //Create or update resources
                   sh("kubectl --namespace=${namespace} apply -f k8s/development/deployment.yaml")
                   sh("kubectl --namespace=${namespace} apply -f k8s/development/service.yaml")
           //Grab the external Ip address of the service
                    sh("echo http://`kubectl --namespace=${namespace} get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}") 
                   //sh("echo http://`kubectl --namespace=${namespace} get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
                   }
                   break
           
        //Roll out to Dev Environment
              case "production":                                                                                                                                                                                                          
                   // Create namespace if it doesn't exist
                   sh("kubectl get ns ${namespace} || kubectl create ns ${namespace}")
           //Update the imagetag to the latest version
                   sh("sed -i.bak 's#gcr.io/${project}/${appName}:${imageVersion}#${imageTag}#' ./k8s/production/*.yaml")
           //Create or update resources
                   sh("kubectl --namespace=${namespace} apply -f k8s/production/deployment.yaml")
                   sh("kubectl --namespace=${namespace} apply -f k8s/production/service.yaml")
           //Grab the external Ip address of the service
                   sh("echo http://`kubectl --namespace=${namespace} get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
                   break
       
              default:
                   sh("kubectl get ns ${namespace} || kubectl create ns ${namespace}")
                   sh("sed -i.bak 's#gcr.io/${project}/${appName}:${imageVersion}#${imageTag}#' ./k8s/development/*.yaml")
                   sh("kubectl --namespace=${namespace} apply -f k8s/development/deployment.yaml")
                   sh("kubectl --namespace=${namespace} apply -f k8s/development/service.yaml")
                   sh("echo http://`kubectl --namespace=${namespace} get service/${feSvcName} --output=json | jq -r '.status.loadBalancer.ingress[0].ip'` > ${feSvcName}")
                   break
  }

}