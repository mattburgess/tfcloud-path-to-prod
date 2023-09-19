# Migrate Local State to Terraform Cloud

Edit `terraform.tf`, adding the following inside the existing `terraform {}` block:

   ```hcl
   terraform {
     ...
     cloud {
       organization = "your_tfcloud_org_name"

       workspaces {
         name = "tfcloud-mgmt-prod"
       }
     }
   }
   ```

Initialize Terraform again, and confirm that you want the current (local) state to be migrated to the Terraform Cloud Workspace:

```sh
$ terraform init

Initializing Terraform Cloud...
Do you wish to proceed?
  As part of migrating to Terraform Cloud, Terraform can optionally copy your
  current workspace state to the configured Terraform Cloud workspace.
  
  Answer "yes" to copy the latest state snapshot to the configured
  Terraform Cloud workspace.
  
  Answer "no" to ignore the existing state and just activate the configured
  Terraform Cloud workspace with its existing state, if any.
  
  Should Terraform migrate your existing state?

  Enter a value: yes
...
Terraform Cloud has been successfully initialized!
...
```

With the state migration complete, you can safely remove the `cloud{}` block that was temporarily added above; this is ignored by Terraform Cloud when the workspace is being managed by a VCS integration like GitHub.
