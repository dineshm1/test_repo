# Django With CI/CD (Docker Container & Kubernetes) #

Python based application development to production ship with kubernetes

This Repository help to deploy your djnago web app in production or set your development environment with in 2 minute or less than 

#### REPOSITORY CLONE  ####
    
    git clone -b master https://github.com/uzzal2k5/django-docker.git
An example django app "<b><i>exampleapp</i></b>" are attached in this repository for you to understand the whole scenario.

    # copy  <b><i>exampleapp</i></b> to your project directory
    
    mv exampleapp ${SOURCE_DIR}/${PROJECT_NAME}/

#### PROJECT STRUCTURE ####        
Change <b><i>SOURCE_DIR</i></b> and  <b><i>PROJECT_NAME </i></b>according to yours, where project structure as bellow -
                    
  

                SOURCE_DIR /
                            PROJECT_NAME /
                                         exampleapp
                                         
                                         
                Note: exampleapp app is your main django web  application 
  
If you want to use your custom name rather than exampleapp, you should follow <b><u>CUSTOM SECTION</u></b> and buid the images                 
 


#### RUN CONTAINER #### 
You can use image already build by
        
        # PULL IMAGES FROM DOCKER HUB
        docker pull uzzal2k5/django-docker
           
 
Run the container into you local or production Machine
    
        # SHELL SCRIPT THAT WOULD RUN  YOUR CONTAINER
         
        
        #!/usr/bin/env bash
        SOURCE_DIR="/home/uzzal/PycharmProjects"
        PROJECT_NAME="example.com"
        docker rm $(docker stop django-docker)
        docker run -itd  --name django-docker \
         -v ${SOURCE_DIR}/${PROJECT_NAME}:/var/www/html \
         -v ${SOURCE_DIR}/${PROJECT_NAME}/nginx_log:/var/log/nginx \
         -p 4443:443 --restart always \
         --hostname django-docker \
         uzzal2k5/django-docker:latest
        docker exec -it django-docker bash -c "python /var/www/html/exampleapp/manage.py runserver &"
        


#### CUSTOM IMAGE BUILD ####

To build you custom images , you need to adjust configuration according to your project and domain name.  You can easily build your custom image to deploy your django web app with SSL Certificate

<b> CREATE SSL CERTIFICATE (Self Signed) </b>

    #Before starting Image build
    cd  ssl
    sh SSLCertificate.sh
    
* Modify SSLCetificate.sh
    Replace <i>example.com</i> as per your <YOUR DOMAIN> as well as other information 
    
        #!/usr/bin/env bash
        openssl req -nodes -newkey rsa:4096 -keyout example.com.key -out example.com.csr -subj "/C=BD/ST=Dhaka/L=Dhaka/O=DevOps Engineers Ltd. /OU=RND/CN=example.com"
        openssl x509 -req -in example.com.csr -signkey example.com.key -out example.com.crt
   
* FOR PRODUCTION, Replace the key and crt file with your original Certificate that you buy from your CA  




<b>CHANGE WEB CONFIG </b>

changes should be at <i>webconfig</i>
    
    server_name <YOUR DOMAIN>.com www.<YOUR DOMAIN>.com; 
    
    ---
    
    alias /var/www/html/<YOUR DJANGO APP ROOT DIR>/static;
            
    ---
    
    
    ssl_certificate /etc/ssl/webcert/<YOUR DOMAIN>.crt;
    ssl_certificate_key /etc/ssl/webcert/<YOUR DOMAIN>.key;
    
    

   vi  config/webconfig
        
        server {
         listen 80 ;
         listen [::]:80 ;
         server_name example.com www.example.com;
         return 301 https://$server_name$request_uri;
        }
        server {
            listen 443 ssl default_server;
            listen [::]:443 default_server ssl;
            server_name example.com www.example.com;
            charset utf8mb4;
        
            location /static {
                autoindex on;
                alias /var/www/html/exampleapp/static;
        
        
            }
            location / {
                proxy_pass http://0.0.0.0:8000;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }
        
            # Configure file root, proxy_pass or whatever you use here
        
            ssl_certificate /etc/ssl/webcert/example.com.crt;
            ssl_certificate_key /etc/ssl/webcert/example.com.key;
        
            ssl     on;
            ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
            ssl_prefer_server_ciphers on;
            add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";
            ssl_session_cache   shared:SSL:10m;
            ssl_session_timeout 10m;
            keepalive_timeout   70;
        
        }

  
#### ADDING REQUIRE PACKAGES ####

Add all require packages int <b><i>req/requirements.txt</i></b>
        
   vi req/requirements.txt
    
        Django==1.11.4
        django-allauth==0.32.0
        django-datatable==0.3.1
        django-datatables-view==1.14.0
        django-debug-toolbar==1.9.1
        django-filter==0.13.0
        django-formtools==2.1
        django-kronos==1.0
        django-mathfilters==0.4.0
        django-model-utils==3.1.1
        django-otp==0.4.3
        django-otp-yubikey==0.4.2
        django-phonenumber-field==1.3.0
        django-pure-pagination==0.3.0
        django-two-factor-auth==1.7.0
        django-widget-tweaks==1.4.1
        djangorestframework==3.3.3
        djangorestframework-bulk==0.2
        #< ADD MORE PACKAGES HERE >       


#### BUILD AND DEPLOY CONTAINER ####

Run docker compose file to build and deploy your container

* BUILD IMAGES
    
  
    docker build -t django-docker:latest .
    
* BUILD & DEPLOY WITH docker-compose.yml
         
   
        django-web:
          build: .
          container_name: django-docker
          hostname: example.com
          # Volume Persistance
          volumes:
            - ${PWD}/example.com:/var/www/html
            - ${PWD}/example.com/nginx_log:/var/log/nginx
        
          ports:
            - 443:443/tcp
          restart: always
          
          
          
    Note : Change example.com according to PROJECT_NAME
    
* RUN DJANGO  WEB APPLICATION using runserver 

        
        docker exec -it django-docker bash
        #/python /var/www/html/exampleapp/manage.py runserver &
        #/exit
        
        # OR USE FOLLWING FROM HOST MACHINE 
        docker exec -it django-docker bash -c "python /var/www/html/exampleapp/manage.py runserver &"
        
        Note: Replace exampleapp with your application
        
#### ACCESS YOUR WEB APPLICATION ####


Add domain name to hosts file
    
     echo "<YOUR DOMAIN.COM>    < YOUR HOST MACHINE IP >" >> /etc/hosts
     echo "example.com  10.10.10.10" >> /etc/hosts
 
 
 Open  any browser and use <i>https://example.com</i> to access your web app
 
 Enjoy!!! 
 
 
#### CI/CD AUTOMATION ####
 
 
 *  Using<b> CircleCI </b>
 *  Using <b>Jenkins </b>
 


##### 1. Build With CircleCI  #####


Create .circleci/config.yml into your github project repository -
 

 * .circleci/config.yml
  
  
    version: 2
    jobs:
     build:
       machine: true
       steps:
         - checkout
         - run:
              name: Build and push Docker image
              command: |
                TAG="0.1.${CIRCLE_BUILD_NUM}"
                docker build -t uzzal2k5/django-docker:$TAG .
                docker login -u $DOCKER_LOGIN -p $DOCKER_PASSWORD
                docker push uzzal2k5/django-docker:$TAG

 
 
 
<b> 2. Build With Jenkins </b>
 <br>
 
 Create <b><i>Jenkinsfile</i></b> into your github repository root - 
 
    
   *    Jenkinsfile
   
 
 
 Make changes on <i>DOCKER_BUILD_SERVER , DOCKER_IMAGE_REGISTRY, REPOSITORY_NAME </i> according to your servers and repositories -
    
 
    #!groovy
    import groovy.json.JsonSlurperClassic
    def DOCKER_BUILD_SERVER = "tcp://10.10.10.10:2376"
    def DOCKER_IMAGE_REGISTRY = "index.docker.io/uzzal2k5/"
    def REPOSITORY_NAME = "https://github.com/uzzal2k5/django-docker.git"
    
    
    def IMAGE_NAME = "django-docker"
    def CONTAINER = "django-docker"
    def djangoImages
    
    
    //def pipeline
    
    # Version & Release Specified Here
    def getVersion(def projectJson){
        def slurper = new JsonSlurperClassic()
        project = slurper.parseText(projectJson)
        slurper = null
        return project.version.split('-')[0]
    }
    
    # Repository Clone here
    def CloneFromGit( REPOSITORY_NAME ){
        def version, revision
        try {
            git(branch: "${params.BRANCH}",
                    changelog: true,
                    credentialsId: 'FreeIPA_USERID',
                    poll: true,
                    url: "${REPOSITORY_NAME}"
            )
        }
        catch (Exception e) {
            println 'Some Exception happened here '
            throw e
    
        }
        finally {
            revision = version + "-" + sprintf("%04d", env.BUILD_NUMBER.toInteger())
            println "Start building  revision $revision"
    
        }
        return this
    }
    
    # Docker Image build &  Push to registry
    def DockerImageBuild( DOCKER_BUILD_SERVER, DOCKER_IMAGE_REGISTRY, IMAGE_NAME ){
    
    
        // Docker Image Build & Deploy
        withDockerServer([uri: "${DOCKER_BUILD_SERVER}"]) {
            stage('IMAGE BUILD'){
    
                djangoImages = docker.build("${DOCKER_IMAGE_REGISTRY}/${IMAGE_NAME}")
    
    
            }
    
            //PUSH to Registry
            stage('PUSH IMAGE'){
                withDockerRegistry(url: "${DOCKER_IMAGE_REGISTRY}") {
                    djangoImages.push("${IMAGE_NAME}:${env.BUILD_NUMBER}")
                    djangoImages.push("${IMAGE_NAME}:latest")
                }
    
    
            }
    
    
        }
        return this
    }
    
    // BUILD NODE
    node {
    
    
         stage('GIT CLONE') {
                CloneFromGit(REPOSITORY_NAME)
    
          }
    
         DockerImageBuild(SERVER_TO_DEPLOY,DOCKER_IMAGE_REGISTRY, IMAGE_NAME)
    
    
    //NODE END
    }
 
 
 
<b> DEPLOY WITH Kubernetes (K8S) </b>
 
 
 Deploy  kubernetes Cluster  [ Kubenrtenes Installation](https://uzzal2k5.github.io/kubernetes/), [GitHub Source](https://github.com/uzzal2k5/kubernetes)
 
 
 
 1. Create Volume that will use for Volume persistent  
    
    
    cd k8s
    kubectl apply -f django-volume.yml
 
 
 
 Modify  <i>django-volume.yml</i> if needed

 
 
    ---
    kind: PersistentVolume
    apiVersion: v1
    metadata:
       name: content-volume
       labels:
          type: local
    spec:
       storageClassName: manual
       capacity:
          storage: 10G
       accessModes:
          - ReadWriteOnce
       hostPath:
          path: "/var/django-container"
    ---
    kind: PersistentVolumeClaim
    apiVersion: v1
    metadata:
       name: content-volume-claim
    spec:
       storageClassName: manual
       accessModes:
          - ReadWriteOnce
       resources:
          requests:
             storage: 3Gi 
 
 
 
 2. Deploy Django web application using kubectl command
    
    
    kubectl apply -f django-deployment.yml
 
 
 
 Modify  <i>django-deployment.yml</i> if needed
 
     
    ---
    kind: Service
    apiVersion: v1
    metadata:
      name: djangoweb
      labels:
        app: djangoapp
    spec:
      selector:
        name: django-web
        app: django-app
      ports:
      - protocol: TCP
        port: 443
        name: django-port
        targetPort: 443
      type: NodePort
    
    ---
    apiVersion: apps/v1beta2
    kind: Deployment
    metadata:
      name: django-docker
    spec:
      replicas: 1
      selector:
        matchLabels:
          name: django-web
      template:
        metadata:
          labels:
            name: django-web
            app: django-app
        spec:
          volumes:
            - name: django-content-storage
              persistentVolumeClaim:
                claimName: content-volume-claim
          containers:
            - name: django-container
              image: docker.io/uzzal2k5/django-docker:0.1.4
              ports:
                - containerPort: 443
                  name: django-port
              volumeMounts:
                - mountPath: "/var/www/html"
                  name: django-content-storage
    
    

  
     
 
<b> HELPS NEEDED !! </b>
 
 
 Contact With
    
   *   GitHub:  [https://github.com/uzzal2k5](https://github.com/uzzal2k5)
   *   E-Mail: [uzzal2k5@gmail.com](uzzal2k5@gmail.com)
   *   Skype / Hangout : [uzzal2k5](uzzal2k5)
   *   LinkedIn: [https://www.linkedin.com/in/uzzal2k5/](https://www.linkedin.com/in/uzzal2k5/)
    
 
