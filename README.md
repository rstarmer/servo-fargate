# servo-fargate

_Optune adjust driver for ECS Fargate services_

This driver presently updates the 'cpu', 'memory', and 'replicas' settings of an ECS fargate service by copying its task definition into a new task definition revision only updating the desired parameters. Once the revision is created, the configured service (see config.yaml.example) is updated to reference the new revision. 

Further, you can also supply/modify environment variables of the container definition contained in the task definition of the ECS service. This is done via the section `environment` which is on the same level as section `settings`. Only range and enum setting types are supported. Range requires the properties `min`, `max` and `step`, whereas enum requires a `values` property. Both support a human readable 'unit' property and require a default value in cases where the environment variable is not set in the container definition

Once the service is updated, the driver waits and polls the running count of the latest service deployment until the running count matches the desired count (or it times out). The driver then polls the Elastic Load Balancer Target Groups associated with the service to ensure the number of healthy registered targets also matches the desired count

__Note__ currently, environment variables are only supported on services whose task definition only contains one container definition

__Note__ this driver requires `adjust.py` base class from the [Optune servo core](https://github.com/opsani/servo/). It can be copied or symlinked here as part of packaging.

## Required IAM Permissions

A Servo running this driver would need the following permissions:

ECS Permissions

- ecs:DescribeServices
- ecs:DescribeTaskDefinition
- ecs:RegisterTaskDefinition
- ecs:UpdateService

ELB

- elasticloadbalancing:DescribeTargetHealth

IAM

- iam:PassRole for ECS Task execution role. This role is required by tasks/services to pull container images and publish container logs to Amazon CloudWatch on your behalf

## Installation

1. Echo optune token into docker secret: `echo -n 'YOUR AUTH TOKEN' | docker secret create optune_auth_token -`
1. Run `docker build servo/ -t example.com/servo-fargate-ab-cloudwatch`
1. Referring to `config.yaml.example` create file `config.yaml` in driver's folder. It will contain settings you'd want to make adjustable on your Fargate service.
1. Create `.aws` folder with needed credential and permission (On EC2: ensure an appropriate instance profile is assigned)
1. Create a docker service:

```
docker service create -t
    --name DOCKER_SERVICE_NAME \
    --secret optune_auth_token \
    --env AB_TEST_URL= APACHED_BENCHMARK_URL \
    --mount type=bind,source=/PATH/TO/config.yaml,destination=/servo/config.yaml \
    --mount type=bind,source=/PATH/TO/.aws/,destination=/root/.aws/ \ # <- if not on EC2
    example.com/servo-fargate-ab-cloudwatch \
    APP_NAME  \
    --account USER_ACCOUNT \
```

## How to run tests

Prerequisites:

* Python 3.5 or higher
* PyTest 4.3.0 or higher

Follow these steps:

1. Pull the repository
1. Copy/symlink `adjust` (no file extension) from this repo's project folder to folder `test/`, rename to `adjust_driver.py`
1. Copy/symlink `adjust.py` from `https://github.com/opsani/servo/tree/master/` to folder `test/`
1. Source your aws_config.env file containing your AWS service key (or ensure your /home/user/.aws folder has a populated credentials file )
1. Run `pytest` from the servo-fargate project folder
