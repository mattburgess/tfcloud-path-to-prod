output "workspace_names" {
  value = [for workspace in tfe_workspace.pipeline_environment : workspace.name]
}

output "workspace_ids" {
  value = { for workspace in tfe_workspace.pipeline_environment : workspace.name => workspace.id }
}
