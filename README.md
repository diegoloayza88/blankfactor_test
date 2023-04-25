# Blankfactor
AWS and Terraform code for Blankfactor Test

---
Test Description
-
* Create a nginx web service that utilizes multi-AZ in AWS. This Web service must only be accessible from NAB's public IPs (using your current public IP is also fine)
* Create an RDS server that's accessible to the web servers. All configurations must be as secure as possible (think of what you need to do to make everything secure).
* The web server needs to scale on-demand; when CPU load hits 65% or higher it needs to scale up, when it's 40% or lower it needs to scale down.
* All infrastructure components must be created using Terraform.

---
I've created a folder structure with the following:

modules/
* networking
.- All vpc resources are part of it
* rds
.- All rds resources are part of it
* web
.- All nginx resources like autoscaling group, load balancer, etc
are part of it

The consuming stack is within blankfactor_test folder, and basically
it's calling the respective modules and variables to be able to deploy the
aws services and resources.