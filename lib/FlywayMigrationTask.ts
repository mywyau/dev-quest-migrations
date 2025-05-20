import * as ecs from "aws-cdk-lib/aws-ecs";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as secretsmanager from "aws-cdk-lib/aws-secretsmanager";
import * as ecr from "aws-cdk-lib/aws-ecr";
import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";

export interface FlywayMigrationTaskProps {
  cluster: ecs.Cluster;
  dbSecret: secretsmanager.ISecret;
  dbHost: string;
  vpc: ec2.Vpc;
}

export class FlywayMigrationTask extends Construct {
  public readonly taskDefinition: ecs.FargateTaskDefinition;
  public readonly securityGroup: ec2.SecurityGroup;

  constructor(scope: Construct, id: string, props: FlywayMigrationTaskProps) {
    super(scope, id);

    const repo = ecr.Repository.fromRepositoryName(this, "FlywayRepo", "flyway-migrations");

    this.taskDefinition = new ecs.FargateTaskDefinition(this, "FlywayTaskDef", {
      cpu: 256,
      memoryLimitMiB: 512,
    });

    this.taskDefinition.addContainer("FlywayContainer", {
      image: ecs.ContainerImage.fromEcrRepository(repo, "latest"), // 👈 you can also pass in tag
      logging: ecs.LogDriver.awsLogs({ streamPrefix: "flyway" }),
      environment: {
        FLYWAY_URL: `jdbc:postgresql://${props.dbHost}:5432/dev_quest_db`,
        FLYWAY_USER: "dev_quest_user",
      },
      secrets: {
        FLYWAY_PASSWORD: ecs.Secret.fromSecretsManager(props.dbSecret, "password"),
      },
    });

    // Allow ECS Task to read DB secret
    props.dbSecret.grantRead(this.taskDefinition.taskRole);

    // Create a security group for the task
    this.securityGroup = new ec2.SecurityGroup(this, "FlywaySG", {
      vpc: props.vpc,
      description: "Security group for Flyway migration task",
      allowAllOutbound: true,
    });

    new cdk.CfnOutput(this, "FlywayTaskDefinitionArn", {
      value: this.taskDefinition.taskDefinitionArn,
    });

    new cdk.CfnOutput(this, "FlywaySecurityGroupId", {
      value: this.securityGroup.securityGroupId,
    });
  }
}
