# Terraform Day Two (102)

## Overview - Creating Terraform modules.
A Terraform module is a grouping of variables, resources, and outputs that can be reused. 
It reduces code repitition, and means that the module can be maintained externally to the template using it.
And a module is just a Terraform template itself!

## Training Goals for day two
*  Understand how to create a module
*  How to use a module from GitHub
*  How to use a versioned module
*  Restrictions of modules

NOTE: We will be using the same user roles as trainingdayone had so all `terraform` commands should be run like this, to use the correct account and user.
```hcl
aws-vault exec terraformrole -- terraform init
aws-vault exec terraformrole -- terraform apply
```

## [Demo One](./demo_one) - Create a Terraform module and use it
1.  Create a module that creates an ec2 launch config, autoscaling group, and load balancer
2.  Create a template that uses the module

## [Demo Two](./demo_two) - Use a versioned module source in a Terraform template
1.  Using a Makefile to simplify commands
2.  Create an S3 bucket in a particular region