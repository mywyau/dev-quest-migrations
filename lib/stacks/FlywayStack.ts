import * as cdk from "aws-cdk-lib";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as secretsmanager from "aws-cdk-lib/aws-secretsmanager";
import * as ssm from "aws-cdk-lib/aws-ssm";
import { Construct } from "constructs";
import { FlywayMigrationTask } from "../constructs/FlywayMigrationTask";

export default class FlywayStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    const vpc = ec2.Vpc.fromLookup(this, "Vpc", {
      isDefault: false,
      tags: {
        Name: "DevQuestVpc",
      },
    });

    const cluster = ecs.Cluster.fromClusterAttributes(this, "Cluster", {
      clusterName: "dev-quest-cluster", // 👈 your real cluster name
      vpc,
      securityGroups: [], // optional
    });

    const dbSecret = secretsmanager.Secret.fromSecretNameV2(
      this,
      "DbSecret",
      "devquest-db-credentials" // 👈 your actual secret name
    );

    const dbHost = ssm.StringParameter.valueFromLookup(
      this,
      "/devquest/database/host"
    );

    const flywayMigrationTask = new FlywayMigrationTask(
      this,
      "FlywayMigrationTask",
      {
        vpc,
        cluster,
        dbSecret,
        dbHost,
      }
    );

    const dbSecurityGroupId = ssm.StringParameter.valueForStringParameter(
      this,
      "/devquest/database/sg-id"
    );

    const dbSecurityGroup = ec2.SecurityGroup.fromSecurityGroupId(
      this,
      "ImportedDbSG",
      dbSecurityGroupId
    );

    // Allow Flyway SG to connect to RDS
    dbSecurityGroup.addIngressRule(
      flywayMigrationTask.securityGroup,
      ec2.Port.tcp(5432),
      "Allow Flyway task to access RDS"
    );
  }
}
