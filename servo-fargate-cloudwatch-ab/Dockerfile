# adapted from https://github.com/opsani/servo-ec2asg-newrelic/blob/master/Dockerfile
FROM python:3.6-slim

WORKDIR /servo

# Install dependencies (use latest pip packages)
# hadolint ignore=DL3013
RUN apt-get update && apt-get install -y --no-install-recommends apache2-utils curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && pip3 install requests PyYAML python-dateutil boto3

RUN mkdir measure.d/

# Install servo:  fargate adjust (which uses the servo base adjust.py) and
# aws cloudwatch measure (which uses the servo base measure.py) and
# apache benchmark measure (which uses the servo base measure.py)
ADD https://raw.githubusercontent.com/opsani/servo/master/servo \
    https://raw.githubusercontent.com/opsani/servo/master/adjust.py \
    https://raw.githubusercontent.com/opsani/servo/master/measure.py \
    https://raw.githubusercontent.com/kumulustech/servo-fargate/master/adjust \
    https://raw.githubusercontent.com/opsani/servo-magg/master/measure \
    /servo/

ADD https://raw.githubusercontent.com/opsani/servo/master/measure.py \
    /servo/measure.d/measure.py
    
ADD https://raw.githubusercontent.com/opsani/servo-ab/master/measure \
    /servo/measure.d/ab

ADD https://raw.githubusercontent.com/kumulustech/servo-cloudwatch/master/measure \
    /servo/measure.d/cloudwatch

RUN chmod a+rwx /servo/adjust /servo/measure /servo/servo /servo/measure.d/ab /servo/measure.d/cloudwatch

# TODO: remove when testing complete
RUN sed -i 's/30,         # warmup time in seconds/0,         # warmup time in seconds/' measure.d/ab
# Default value works in this case, uncomment to adjust ab load duration
# RUN sed -i 's/180,         # time limit in seconds/180,         # time limit in seconds/' measure.d/ab

ENV PYTHONUNBUFFERED=1

ENTRYPOINT [ "python3", "servo" ]
