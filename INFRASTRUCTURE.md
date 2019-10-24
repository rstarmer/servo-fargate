# Servo Fargate Driver Infrastructure

## Fargate Components

For the sake of simplicity, the servo-fargate driver was designed to adjust an already running Fargate service; it does not automate the orchestration of the service, but expects it to have been set up before hand. This list documents the components you must create and configure to make use of the driver

- Amazon VPC - If you do not have one already, there will be an option to generate one during creation of your cluster in the next step
- Amazon ECS Cluster - An Amazon ECS cluster is a regional grouping of one or more container instances on which you can run task requests.
    - __Note__ AWS docs claim each account receives a default cluster but it appears that is not the case. When creating the cluster, choose the "Networking Only" template
    - __Note__ the value of `cluster` in config.yaml must be set to the same name as this cluster (if not using the name "default")

- Amazon ECS Task Definition - A task definition specifies which containers are included in your task and how they interact with each other.
    - __Note__ The driver currently supports only 1 container definition when `environment` is included in config.yaml

- Amazon ECS Service - A service lets you specify how many copies of your task definition to run and maintain in a cluster. You can optionally use an Elastic Load Balancing load balancer to distribute incoming traffic to containers in your service. Amazon ECS maintains that number of tasks and coordinates task scheduling with the load balancer. You can also optionally use Service Auto Scaling to adjust the number of tasks in your service.
    - __Note__ The service must specify a Launch Type of FARGATE in order for this driver to work
    - __Note__ This service should reference the task definition and VPC mentioned above
    - __Note__ Setting Auto-assign Public IP to DISABLED can complicate setup: when using fargate, a public IP address needs to be assigned to the task's elastic network interface. The network interface must have a route to the internet or a NAT gateway that can route requests to the internet, for the task to pull container images. (https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-configure-network.html)
    - __Note__ The value of `service_name` in config.yaml must match the Service Name you gave this service on creation
    - __Note__ If using an application load balancer, it must be created prior to creating the service because load balancing can only be configured during service creation

## Additional infrastructure

- Amazon Application ELB (Elastic Load Balancer) - responsible for routing apache benchmark requests to the fargate tasks due to their public IP addresses being ephemeral and subject to change upon adjustment
    - __Note__ This must be created prior to creating the fargate service as its load balancer settings can only be set during creation

- Amazon Target Group - Your load balancer routes requests to the targets in a target group using the target group settings that you specify, and performs health checks on the targets using the health check settings that you specify
    - __Note__ Target type must be set to `IP`
    - __Note__ If creating target group during fargate service creation, it will populate a Path pattern and Health check pattern based on the task name which you will typically want to set back to the default value of `/`

- Amazon EC2 Instance, docker installed - this host executes the containerized driver code (see servo-fargate-cloudwatch-ab/Dockerfile) which references the config.yaml to run the utilities and api calls involved in measurement and adjustment. It must also be able to route to your target application in cases where apache benchmark is used
