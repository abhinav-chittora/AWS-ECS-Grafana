# Grafana ECS Fargate Deployment

This project deploys Grafana on AWS ECS Fargate with Azure AD authentication, accessible via Application Load Balancer over HTTPS.

## Architecture

- **ECS Fargate**: Serverless container hosting
- **Application Load Balancer**: HTTPS termination and load balancing
- **EFS**: Persistent storage for Grafana data
- **Secrets Manager**: Secure credential storage
- **Azure AD**: Single sign-on authentication
- **CloudWatch**: Logging and monitoring

## Prerequisites

- AWS CLI configured with appropriate permissions
- ACM certificate for `*.hws-gruppe.de` domain
- Azure AD application registration
- Make utility installed

## Quick Start

1. **Clone and navigate to project**
   ```bash
   git clone <repository-url>
   cd MigrateGrafana2ECS
   ```

2. **Create parameters file**
   ```bash
   cp parameters.json.example parameters.json
   # Edit parameters.json with your values
   ```

3. **Deploy stack**
   ```bash
   make deploy
   ```

4. **Access Grafana**
   - URL: `https://grafana.hws-gruppe.de`
   - Login via Azure AD or admin credentials

## Configuration Files

### parameters.json
Create this file with your specific values:
```json
[
  {
    "ParameterKey": "CertificateArn",
    "ParameterValue": "arn:aws:acm:region:account:certificate/cert-id"
  },
  {
    "ParameterKey": "GrafanaDomainName",
    "ParameterValue": "grafana.hws-gruppe.de"
  },
  {
    "ParameterKey": "AzureClientId",
    "ParameterValue": "your-azure-client-id"
  },
  {
    "ParameterKey": "AzureClientSecret",
    "ParameterValue": "your-azure-client-secret"
  },
  {
    "ParameterKey": "AzureTenantId",
    "ParameterValue": "your-azure-tenant-id"
  },
  {
    "ParameterKey": "GrafanaAdminPassword",
    "ParameterValue": "your-admin-password"
  },
  {
    "ParameterKey": "TagProject",
    "ParameterValue": "ECS-POC"
  },
  {
    "ParameterKey": "TagOwner",
    "ParameterValue": "your-email@domain.com"
  }
]
```

## Makefile Commands

| Command | Description |
|---------|-------------|
| `make deploy` | Deploy CloudFormation stack |
| `make update` | Update existing stack |
| `make delete` | Delete stack |
| `make status` | Check stack status |
| `make outputs` | Get stack outputs |
| `make validate` | Validate template |

### Custom Variables
```bash
# Deploy with custom stack name and AWS profile
make deploy STACK_NAME=my-grafana AWS_PROFILE=prod

# Use custom parameters file
make deploy PARAMETERS_FILE=prod-params.json
```

## Azure AD Setup

1. **Register Application**
   - Go to Azure Portal > App Registrations
   - Create new registration
   - Note Client ID and Tenant ID

2. **Configure Redirect URI**
   - Add redirect URI: `https://your-alb-dns-name/login/azuread`
   - Or: `https://grafana.hws-gruppe.de/login/azuread`

3. **Create Client Secret**
   - Go to Certificates & secrets
   - Create new client secret
   - Note the secret value

4. **API Permissions**
   - Add Microsoft Graph permissions:
     - `openid`
     - `email` 
     - `profile`

## Network Access

- **Allowed IP**: `151.189.180.250/32`
- **Protocol**: HTTPS (port 443)
- **Health Check**: `/api/health`

## Monitoring & Troubleshooting

### CloudWatch Logs
```bash
# View Grafana logs
aws logs tail /ecs/grafana --follow
```

### ECS Exec Access
```bash
# Connect to running container
aws ecs execute-command \
  --cluster grafana-ecs \
  --task <task-id> \
  --container grafana \
  --interactive \
  --command "/bin/bash"
```

### Health Checks
- **Container Health**: `/healthz` endpoint
- **ALB Health**: `/api/health` endpoint
- **Interval**: 30 seconds
- **Timeout**: 5 seconds

## Security Features

- **Encryption**: EFS and Secrets Manager encrypted at rest
- **Network**: Private subnets for ECS tasks
- **Access**: IP-restricted ALB access
- **Secrets**: No hardcoded credentials
- **Transit**: HTTPS/TLS encryption

## Resource Specifications

- **CPU**: 256 units (0.25 vCPU)
- **Memory**: 512 MB
- **Storage**: EFS with access point
- **Networking**: VPC with public/private subnets
- **Availability**: Multi-AZ deployment

## Cost Optimization

- **Fargate**: Pay-per-use serverless compute
- **EFS**: Provisioned throughput mode
- **NAT Gateway**: Single gateway for cost efficiency
- **Log Retention**: 7 days for CloudWatch logs

## Cleanup

```bash
# Delete all resources
make delete

# Verify deletion
make status
```

## Troubleshooting

### Common Issues

1. **Certificate not found**
   - Verify ACM certificate ARN
   - Ensure certificate is in same region

2. **Azure AD login fails**
   - Check redirect URI configuration
   - Verify client ID/secret in parameters

3. **Health check failures**
   - Check container logs in CloudWatch
   - Verify EFS mount permissions

4. **Access denied**
   - Confirm IP address in security group
   - Check DNS resolution for domain

### Support

For issues or questions:
- Check CloudWatch logs
- Review ECS service events
- Validate parameters.json format
- Ensure AWS permissions are sufficient

## Files Structure

```
├── README.md                    # This documentation
├── grafana-ecs-fargate.yaml    # CloudFormation template
├── Makefile                     # Deployment automation
├── parameters.json              # Configuration (create from example)
└── .gitignore                   # Git ignore rules
```

**⚠️ Security Note**: Never commit `parameters.json` to version control as it contains sensitive credentials.