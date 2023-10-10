
locals {
  oidc_provider_site_address = replace(data.aws_iam_openid_connect_provider.tfcloud.url, "https://", "")
}

data "aws_iam_openid_connect_provider" "tfcloud" {
  url = var.oidc_provider_url
}

data "aws_iam_policy_document" "tfcloud_pipeline_plan_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        data.aws_iam_openid_connect_provider.tfcloud.arn,
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_site_address}:aud"
      values   = data.aws_iam_openid_connect_provider.tfcloud.client_id_list
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_provider_site_address}:sub"

      values = [
        "organization:${var.tfcloud_org}:project:${var.tfcloud_project}:workspace:${var.workspace_name}:run_phase:plan",
      ]
    }
  }
}

resource "aws_iam_role" "tfcloud_pipeline_plan" {
  name               = "${var.workspace_name}-plan"
  assume_role_policy = data.aws_iam_policy_document.tfcloud_pipeline_plan_assume_role.json
}

resource "aws_iam_role_policy_attachment" "tfcloud_pipeline_plan" {
  count      = length(var.plan_role_arns)
  role       = aws_iam_role.tfcloud_pipeline_plan.name
  policy_arn = var.plan_role_arns[count.index]
}

data "aws_iam_policy_document" "tfcloud_pipeline_apply_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type = "Federated"

      identifiers = [
        data.aws_iam_openid_connect_provider.tfcloud.arn,
      ]
    }

    actions = [
      "sts:AssumeRoleWithWebIdentity",
    ]

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_site_address}:aud"
      values   = data.aws_iam_openid_connect_provider.tfcloud.client_id_list
    }

    condition {
      test     = "StringLike"
      variable = "${local.oidc_provider_site_address}:sub"

      values = [
        "organization:${var.tfcloud_org}:project:${var.tfcloud_project}:workspace:${var.workspace_name}:run_phase:apply",
      ]
    }
  }
}

resource "aws_iam_role" "tfcloud_pipeline_apply" {
  name               = "${var.workspace_name}-apply"
  assume_role_policy = data.aws_iam_policy_document.tfcloud_pipeline_apply_assume_role.json
}

resource "aws_iam_role_policy_attachment" "tfcloud_pipeline_apply" {
  count      = length(var.apply_role_arns)
  role       = aws_iam_role.tfcloud_pipeline_apply.name
  policy_arn = var.apply_role_arns[count.index]
}
