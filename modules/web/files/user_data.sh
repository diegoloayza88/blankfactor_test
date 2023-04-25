#!/bin/bash
echo "Hello World, this is a TEST for Blankfactor!" >> /tmp/testfile.txt
echo "Bootstrapping nginx"
yum update -y
yum install nginx postgresql15 -y
systemctl enable nginx

echo "Adding hostname to nginx test html using https://docs.aws.amazon.com/es_es/AWSEC2/latest/UserGuide/instancedata-data-retrieval.html"
TOKEN=`curl -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"`
export AVAILABILITY_ZONE=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone)
export INSTANCE_ID=$(curl -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
export HOSTNAME="${hostname_prefix}-$INSTANCE_ID-$AVAILABILITY_ZONE"
sed -i -e "s/Welcome to nginx\!/Welcome to nginx\! from $HOSTNAME/g" /usr/share/nginx/html/index.html
systemctl start nginx
