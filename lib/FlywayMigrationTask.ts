import * as cdk from "aws-cdk-lib";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecr from "aws-cdk-lib/aws-ecr";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as secretsmanager from "aws-cdk-lib/aws-secretsmanager";
import { Construct } from "constructs";

// Props required to configure the Flyway migration task
export interface FlywayMigrationTaskProps {
  cluster: ecs.Cluster;                 // ECS cluster where the task will run
  dbSecret: secretsmanager.ISecret;    // Secret containing DB credentials
  dbHost: string;                      // RDS hostname
  vpc: ec2.Vpc;                        // VPC used for networking (subnets, SGs)
}

// Construct that defines a Flyway database migration ECS task
export class FlywayMigrationTask extends Construct {
  public readonly taskDefinition: ecs.FargateTaskDefinition;
  public readonly securityGroup: ec2.SecurityGroup;

  constructor(scope: Construct, id: string, props: FlywayMigrationTaskProps) {
    super(scope, id);

    // 🔄 Reference the Flyway Docker image from ECR
    const repo = ecr.Repository.fromRepositoryName(
      this,
      "FlywayRepo",
      "flyway-migrations"
    );

    // ⚙️ Define a Fargate task for the migration
    this.taskDefinition = new ecs.FargateTaskDefinition(this, "FlywayTaskDef", {
      cpu: 256,
      memoryLimitMiB: 512,
    });

    // 🐳 Add a Flyway container to the task definition
    this.taskDefinition.addContainer("FlywayContainer", {
      image: ecs.ContainerImage.fromEcrRepository(repo, "latest"), // 🏷️ Uses the 'latest' tag
      logging: ecs.LogDriver.awsLogs({ streamPrefix: "flyway" }), // 📘 Logs go to CloudWatch
      environment: {
        FLYWAY_URL: `jdbc:postgresql://${props.dbHost}:5432/dev_quest_db`, // 💾 JDBC connection string
        FLYWAY_USER: "dev_quest_user",
      },
      secrets: {
        // 🔐 Load DB password securely from Secrets Manager
        FLYWAY_PASSWORD: ecs.Secret.fromSecretsManager(props.dbSecret, "password"),
      },
    });

    // ✅ Allow the ECS task role to read the secret
    props.dbSecret.grantRead(this.taskDefinition.taskRole);

    // 🔐 Create a security group for the task (for RDS access)
    this.securityGroup = new ec2.SecurityGroup(this, "FlywaySG", {
      vpc: props.vpc,
      description: "Security group for Flyway migration task",
      allowAllOutbound: true, // Needed for internet or RDS access
    });

    // 🔽 Export task definition and security group ID to CloudFormation outputs
    new cdk.CfnOutput(this, "FlywayTaskDefinitionArn", {
      value: this.taskDefinition.taskDefinitionArn,
    });

    new cdk.CfnOutput(this, "FlywaySecurityGroupId", {
      value: this.securityGroup.securityGroupId,
    });

    // 🧪 Publish key runtime values to SSM so GitHub Actions can fetch them
    new cdk.aws_ssm.StringParameter(this, "FlywaySGParam", {
      parameterName: "/devquest/backend/sg-id",
      stringValue: this.securityGroup.securityGroupId,
    });

    new cdk.aws_ssm.StringParameter(this, "DbSecretArnParam", {
      parameterName: "/devquest/database/secret-arn",
      stringValue: props.dbSecret.secretArn,
    });

    new cdk.aws_ssm.StringParameter(this, "DbHostParam", {
      parameterName: "/devquest/database/host",
      stringValue: props.dbHost,
    });
  }
}
