import * as cdk from "aws-cdk-lib";
import FlywayStack from "../lib/stacks/FlywayStack";

const app = new cdk.App();

new FlywayStack(app, "FlywayMigrationStack", {
  env: {
    account: process.env.CDK_DEFAULT_ACCOUNT,
    region: process.env.CDK_DEFAULT_REGION || "us-east-1",
  },
});
