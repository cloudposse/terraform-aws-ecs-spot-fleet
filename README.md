# terraform-aws-ecs-ecs-spot-fleet
Terraform module to create a diversified spot fleet for running ECS cluster

This module is waiting on the launch templates to be added to spot fleets so that dynamic fleets can be created.
https://github.com/terraform-providers/terraform-provider-aws/issues/4267
