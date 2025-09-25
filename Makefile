# Variables
STACK_NAME ?= grafana-ecs
AWS_PROFILE ?= ecs-test
TEMPLATE_FILE = grafana-ecs-fargate.yaml
PARAMETERS_FILE = parameters.json

# Deploy stack
deploy:
	aws cloudformation create-stack \
		--stack-name $(STACK_NAME) \
		--template-body file://$(TEMPLATE_FILE) \
		--parameters file://$(PARAMETERS_FILE) \
		--capabilities CAPABILITY_IAM \
		--profile $(AWS_PROFILE)

# Update stack
update:
	aws cloudformation update-stack \
		--stack-name $(STACK_NAME) \
		--template-body file://$(TEMPLATE_FILE) \
		--parameters file://$(PARAMETERS_FILE) \
		--capabilities CAPABILITY_IAM \
		--profile $(AWS_PROFILE)

# Delete stack
delete:
	aws cloudformation delete-stack \
		--stack-name $(STACK_NAME) \
		--profile $(AWS_PROFILE)

# Check stack status
status:
	aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--profile $(AWS_PROFILE) \
		--query 'Stacks[0].StackStatus' \
		--output text

# Get stack outputs
outputs:
	aws cloudformation describe-stacks \
		--stack-name $(STACK_NAME) \
		--profile $(AWS_PROFILE) \
		--query 'Stacks[0].Outputs'

# Validate template
validate:
	aws cloudformation validate-template \
		--template-body file://$(TEMPLATE_FILE) \
		--profile $(AWS_PROFILE)

.PHONY: deploy update delete status outputs validate