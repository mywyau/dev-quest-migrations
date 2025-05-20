



docker build -t flyway-migrations .
docker tag flyway-migrations 890742562318.dkr.ecr.us-east-1.amazonaws.com/flyway-migrations:<tag>
docker push 890742562318.dkr.ecr.us-east-1.amazonaws.com/flyway-migrations:<tag>


aws ecs run-task \
  --cluster your-cluster-name \
  --launch-type FARGATE \
  --task-definition your-task-def-arn \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-xxx],securityGroups=[sg-xxx],assignPublicIp=ENABLED}"
