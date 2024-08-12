# Flask App Deployment to ECS Fargate

This project demonstrates a simple Flask application deployment to AWS ECS Fargate using GitHub Actions for CI/CD.

## Project Structure

```
devops-demo/
│
├── .github/
│   └── workflows/
│       └── ci-cd.yml
│
├── app/
│   ├── templates/
│   │   └── index.html
│   └── app.py
│
├── docs/
│   └── [various documentation files]
│
├── Dockerfile
├── task-definition.json
├── task-execution-assume-role.json
├── deploy.sh
├── requirements.txt
└── README.md
```

## Prerequisites

- AWS Account
- GitHub Account
- Docker installed locally (for testing)
- AWS CLI configured with appropriate permissions

## Setup Instructions

1. Clone the repository:
   ```
   git clone https://github.com/your-username/devops-demo.git
   cd devops-demo
   ```

2. Create an ECR repository:
   ```
   aws ecr create-repository --repository-name flask-app-repo --region us-east-1
   ```

3. Create an ECS cluster:
   ```
   aws ecs create-cluster --cluster-name flask-app-cluster --region us-east-1
   ```

4. Create a log group for the ECS tasks:
   ```
   aws logs create-log-group --log-group-name /ecs/flask-app --region us-east-1
   ```

5. Create an ECS task execution role:
   ```
   aws iam create-role --role-name ecsTaskExecutionRole --assume-role-policy-document file://task-execution-assume-role.json
   aws iam attach-role-policy --role-name ecsTaskExecutionRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy
   ```
   
   The `task-execution-assume-role.json` file is included in the root of the project directory. It defines the trust relationship that allows ECS to assume this role.


6. Update the `task-definition.json` file:
   - Replace `your-account-id` with your actual AWS account ID.
   - Update the `executionRoleArn` with the ARN of the role created in step 5.

7. Create the ECS service:
   ```
   aws ecs create-service --cluster flask-app-cluster --service-name flask-app-service --task-definition flask-app-task --desired-count 1 --launch-type FARGATE --network-configuration "awsvpcConfiguration={subnets=[subnet-12345678,subnet-87654321],securityGroups=[sg-12345678],assignPublicIp=ENABLED}" --region us-east-1
   ```

8. Configure GitHub Secrets:
   - Go to your GitHub repository settings
   - Add the following secrets:
     - `AWS_ACCESS_KEY_ID`
     - `AWS_SECRET_ACCESS_KEY`

## Deployment

The project uses GitHub Actions for CI/CD. On every push to the `main` branch, the workflow will:

1. Build the Docker image
2. Push the image to ECR
3. Update the ECS task definition
4. Deploy the updated task definition to ECS
5. Perform a health check

To manually deploy:

1. Build the Docker image:
   ```
   docker build -t flask-app:latest .
   ```

2. Run the deployment script:
   ```
   ./deploy.sh
   ```

## Debugging

If you encounter issues during deployment or runtime, here are some steps to debug:

1. Check GitHub Actions logs:
   - Go to the "Actions" tab in your GitHub repository
   - Click on the latest workflow run
   - Examine the logs for each step

2. Check ECS task status:
   ```
   aws ecs list-tasks --cluster flask-app-cluster --service-name flask-app-service
   aws ecs describe-tasks --cluster flask-app-cluster --tasks <task-arn>
   ```

3. Check CloudWatch logs:
   - Go to CloudWatch in the AWS Console
   - Navigate to the log group `/ecs/flask-app`
   - Find the latest log stream and examine the logs

4. Common issues and solutions:
   - Image pull failures: Ensure ECR permissions are correct
   - Task failures: Check the task definition for any misconfigurations
   - Health check failures: Ensure the application is running on port 5000 and the security group allows inbound traffic

5. To SSH into the running container for debugging:
   - This is not directly possible with Fargate, but you can use AWS Systems Manager Session Manager for debugging
   - Ensure your task role has the necessary permissions for Session Manager
   - Use the AWS CLI to start a session:
     ```
     aws ecs execute-command --cluster flask-app-cluster --task <task-id> --container flask-app-container --command "/bin/sh" --interactive
     ```

## Additional Resources

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flask Documentation](https://flask.palletsprojects.com/)

For more detailed information about the project structure, infrastructure, and processes, please refer to the documents in the `docs/` directory.
