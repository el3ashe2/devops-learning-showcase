# RBAC Configuration for Koda Microservices

This directory contains Kubernetes RBAC (Role-Based Access Control) configurations for the Koda platform microservices. The RBAC policies follow the principle of least privilege, granting only the minimum permissions required for each service to function.

## Overview

The RBAC configuration consists of three main components:

1. **Namespaces** - Logical isolation for different microservice categories
2. **Roles** - Permission sets defining what actions can be performed
3. **RoleBindings** - Associations between service accounts and roles

## Namespaces

The platform is organized into five namespaces:

### platform
Core platform services and shared infrastructure components.

### auth
Authentication and authorization microservices with restricted access to secrets and configuration.

### questions
Question management services with read/write access to question-related resources.

### voting
Voting and poll management services with event monitoring capabilities.

### admin
Administrative dashboard services with read-only access across multiple resource types.

## Files

### namespaces.yaml
Defines all five namespaces with appropriate labels for environment tracking and management.

### roles.yaml
Defines Role resources for each namespace with least-privilege permissions:

- **platform-service-role**: Access to pods, services, configmaps, secrets, deployments (read-only)
- **auth-service-role**: Restricted access to secrets, configmaps, pods, and services (read-only)
- **questions-service-role**: Access to configmaps, secrets, pods, services, and pod logs (read-only)
- **voting-service-role**: Similar to questions with additional event monitoring
- **admin-service-role**: Broader read-only access for monitoring and management

### rolebindings.yaml
Binds each role to its corresponding service account within the appropriate namespace.

## Usage

### Deploy All RBAC Resources

Apply all RBAC configurations at once:

```bash
kubectl apply -f namespaces.yaml
kubectl apply -f roles.yaml
kubectl apply -f rolebindings.yaml
```

### Deploy Individual Namespace

To deploy RBAC for a specific namespace:

```bash
# Example: Deploy only auth namespace RBAC
kubectl apply -f namespaces.yaml
kubectl apply -f roles.yaml
kubectl apply -f rolebindings.yaml

# Then filter by namespace
kubectl get roles -n auth
kubectl get rolebindings -n auth
```

### Create Service Accounts

Before the RoleBindings can take effect, create the corresponding service accounts:

```bash
# Create service account for platform
kubectl create serviceaccount platform-service-account -n platform

# Create service account for auth
kubectl create serviceaccount auth-service-account -n auth

# Create service account for questions
kubectl create serviceaccount questions-service-account -n questions

# Create service account for voting
kubectl create serviceaccount voting-service-account -n voting

# Create service account for admin
kubectl create serviceaccount admin-service-account -n admin
```

### Verify RBAC Configuration

Check that all resources are created correctly:

```bash
# List all namespaces
kubectl get namespaces

# Check roles in each namespace
kubectl get roles -A

# Check rolebindings
kubectl get rolebindings -A

# Verify service accounts
kubectl get serviceaccounts -A | grep -service-account
```

### Test Permissions

Verify that a service account has the expected permissions:

```bash
# Test if platform service account can list pods
kubectl auth can-i list pods \
  --as=system:serviceaccount:platform:platform-service-account \
  -n platform

# Test if auth service account can create secrets (should be no)
kubectl auth can-i create secrets \
  --as=system:serviceaccount:auth:auth-service-account \
  -n auth
```

## Security Principles

### Least Privilege
Each role grants only the minimum permissions necessary for the microservice to function. Services cannot:
- Create or delete resources (only read)
- Access resources in other namespaces
- Modify cluster-wide settings

### Namespace Isolation
Resources are strictly isolated by namespace. A service in one namespace cannot access resources in another namespace.

### Read-Only by Default
Most permissions are read-only (`get`, `list`, `watch`). Write permissions (`create`, `update`, `delete`) are not granted unless absolutely necessary.

### Service Account Binding
Each role is bound to a specific service account, ensuring that only authorized pods can assume these permissions.

## Troubleshooting

### Permission Denied Errors

If a pod reports permission denied:

1. Check if the pod is using the correct service account:
   ```bash
   kubectl get pod <pod-name> -n <namespace> -o yaml | grep serviceAccountName
   ```

2. Verify the service account exists:
   ```bash
   kubectl get serviceaccount -n <namespace>
   ```

3. Check if the rolebinding is correct:
   ```bash
   kubectl get rolebinding -n <namespace> -o yaml
   ```

4. Test the specific permission:
   ```bash
   kubectl auth can-i <verb> <resource> \
     --as=system:serviceaccount:<namespace>:<service-account> \
     -n <namespace>
   ```

### RoleBinding Not Taking Effect

If permissions are not working:

1. Ensure the service account exists before applying rolebindings
2. Check for typos in service account names
3. Verify the role exists in the same namespace
4. Restart the pods to pick up new service account tokens

## Extending RBAC

### Adding a New Microservice

To add RBAC for a new microservice:

1. Add a new namespace definition to `namespaces.yaml`
2. Create a new Role in `roles.yaml` with appropriate permissions
3. Add a RoleBinding in `rolebindings.yaml`
4. Create the service account
5. Update your deployment to use the new service account

### Modifying Permissions

To grant additional permissions:

1. Edit the appropriate Role in `roles.yaml`
2. Add the required `apiGroups`, `resources`, and `verbs`
3. Reapply the role: `kubectl apply -f roles.yaml`
4. Restart affected pods

## Best Practices

1. **Regular Audits**: Periodically review and audit RBAC policies
2. **Principle of Least Privilege**: Always start with minimal permissions and add only what's needed
3. **Documentation**: Document why specific permissions are granted
4. **Testing**: Test RBAC changes in a non-production environment first
5. **Monitoring**: Monitor for permission-related errors in logs

## References

- [Kubernetes RBAC Documentation](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Configure Service Accounts](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/)
