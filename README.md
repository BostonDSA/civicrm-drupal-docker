# Overview

This repository has a few components:

* A Dockerfile to build a [Drupal](https://www.drupal.org) + [CiviCRM](https://civicrm.org) Docker container.
* [Terraform](https://www.terraform.io) configuration for deploying the container to Amazon Web Services.

# Docker

The Dockerfile starts from the official Drupal 7* + Apache Docker image. It adds the CiviCRM module and any PHP dependencies that are not in the base image. A docker-compose is provided for local development.

* CiviCRM support for Drupal 8 is in beta.

# Terraform

The Terffaform code has two main parts: a build pipeline and configuration for cloud resources to run the container and database.

## Build Pipeline

The build portion of the terraform configuration will setup an AWS CodePipeline that has three stages:

1. Source: GitHub. The pipeline watches for changes on the master branch of this repository.
2. Build: CodeBuild. Launches an AWS Docker container that will run the Docker build process as configured by buildspec.yml. The resulting image will be pushed to an Elastic Container Repository.
3. Deploy: ECS. The container then gets launched into the Elastic Container Service (EC2 version).

## Cloud Resources

Once the container is built and deployed it will be running on the Elastic Container Service and connect to an RDS MySQL Database. The Simple Email Service handles outgoing email. Terraform will also setup the networking and IAM permissions to connect these resources together. DNS configuration is not currently supported.

## Configuration

**AWS**
: The AWS access key, secret, and account ID need to be configured prior to running Terraform commands. See https://www.terraform.io/docs/providers/aws/index.html. 

**GitHub**
: The GITHUB_TOKEN environment variable must be set. See https://help.github.com/en/articles/creating-a-personal-access-token-for-the-command-line.

