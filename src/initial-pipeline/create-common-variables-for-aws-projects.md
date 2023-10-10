# Create Common Variables for AWS Projects

In order for Terraform Cloud to be able to authenticate with AWS using short-lived credentials, we need to configure an OIDC connection. As all AWS projects will use this same authentication method, it makes sense to make the necessary information available via a shared variable set. Copy and paste the following into `aws_common_variables.tf`:

```hcl
{{#include terraform/aws_common_variables.tf}}
```

```admonish
* The values given to the various `oidc_*` locals are the defaults required if using Terraform Cloud; they only need to be changed if you have a local installation of Terraform Enterprise.

* AWS has good documentation on [obtaining the thumbprint for an OIDC provider](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_providers_create_oidc_verify-thumbprint.html).
```
