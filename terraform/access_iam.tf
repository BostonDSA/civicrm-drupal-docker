data "aws_iam_policy_document" "codebuild-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codebuild" {
  name               = "role-codebuild-${var.project_name}"
  path               = "/${var.project_name}/"
  assume_role_policy = "${data.aws_iam_policy_document.codebuild-assume-role-policy.json}"
}

data "aws_iam_policy_document" "codebuild_policy" {
  statement {
    sid = 1
    actions = [
	"s3:PutObject",
	"s3:GetBucketAcl",
	"s3:GetBucketLocation",
	"s3:GetObject",
	"s3:GetObjectVersion"
      ]
    resources = [
	"arn:aws:s3:::codepipeline-${var.aws_region}-*"
    ]
  }

  statement {
    sid = 2
    actions = [
	"ecr:BatchCheckLayerAvailability",
	"ecr:CompleteLayerUpload",
	"ecr:GetAuthorizationToken",
	"ecr:InitiateLayerUpload",
	"ecr:PutImage",
	"ecr:UploadLayerPart"
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${var.aws_account_id}:repository/${var.project_name}"
    ]
  }

  statement {
    sid = 3
    actions = [
	"logs:CreateLogGroup",
	"logs:CreateLogStream",
	"logs:PutLogEvents"
    ]
    resources = [
      "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/codebuild/${var.project_name}-build",
      "arn:aws:logs:${var.aws_region}:${var.aws_account_id}:log-group:/aws/codebuild/${var.project_name}-build:*"
    ]
  }
}

resource "aws_iam_role_policy" "codebuild" {
  name = "policy-codebuild-${var.project_name}"
  role = "${aws_iam_role.codebuild.id}"
  policy = "${data.aws_iam_policy_document.codebuild_policy.json}"
}
