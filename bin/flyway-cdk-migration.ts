#!/usr/bin/env node
import * as cdk from "aws-cdk-lib";
import { FlywayMigrationTask } from "../lib/constructs/flyway-migration-task";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as secretsmanager from "aws-cdk-lib/aws-secretsmanager";
import * as ssm from "aws-cdk-lib/aws-ssm";

// Set up CDK app
const app = new cdk.App();
const env = {
  account: process.env.CDK_DEFAULT_ACCOUNT,
  region: process.env.CDK_DEFAULT_REGION || "us-east-1",
};

// Shared resources lookup
const vpc = ec2.Vpc.fromLookup(app, "Vpc", {
  isDefault: false,
  vpcName: "SharedVpc", // Update with your actual VPC name/tag
});

const cluster = ecs.Cluster.fromClusterAttributes(app, "Cluster", {
  clusterName: "SharedCluster", // Update to match yours
  vpc,
  securityGroups: [], // optional
});

const dbSecret = secretsmanager.Secret.fromSecretNameV2(
  app,
  "DbSecret",
  "devquest/creds"
);

// Get DB host from SSM Parameter Store
const dbHost = ssm.StringParameter.valueFromLookup(app, "/devquest/backend/db-host");

// Instantiate FlywayMigrationTask
new FlywayMigrationTask(app, "FlywayMigrationTask", {
  vpc,
  cluster,
  dbSecret,
  dbHost,
});
