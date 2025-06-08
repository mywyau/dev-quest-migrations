# dev-quest-migrations

PoatgreSql Migrations for DevIrl app

Uses flyway and cdk to create a ecs task which is can be triggered via github actions. 

To trigger the task make sure app is deployed with AWS RDS setup appropriately. The go into github actions and run the workflow.

#### Note: you may need to clear out cdk.context.json before running to get the latest vpc names/ids and any other shared parameters in the infra stack.