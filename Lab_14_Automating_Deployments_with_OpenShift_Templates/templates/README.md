# Template Library

## Available Templates

### web-app-template
- **Description**: Basic web application template
- **Parameters**: APP_NAME, ENVIRONMENT, IMAGE_NAME, etc.
- **Use Case**: Simple web applications with configurable resources

### postgresql-template
- **Description**: PostgreSQL database template
- **Parameters**: DATABASE_NAME, POSTGRESQL_USER, etc.
- **Use Case**: Database deployments with persistent storage

### advanced-web-template
- **Description**: Advanced web application with autoscaling
- **Parameters**: Includes HPA and health check configurations
- **Use Case**: Production-ready applications with scaling capabilities

## Usage Examples

```bash
# Deploy basic web app
oc process web-app-template -p APP_NAME=myapp | oc create -f -

# Deploy with parameter file
oc process web-app-template --param-file=dev-params.env | oc create -f -
