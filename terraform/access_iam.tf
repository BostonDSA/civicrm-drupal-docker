data "aws_iam_policy_document" "codebuild" {
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
      "arn:aws:ecr:${var.aws_region}:&{aws:userid}:repository/${var.project_name}"
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
	"arn:aws:logs:${var.aws_region}:&{aws:userid}:log-group:/aws/codebuild/${var.project_name}-build",
	"arn:aws:logs:${var.aws_region}:&{aws:userid}:log-group:/aws/codebuild/${var.project_name}-build:*",
    ]
  }
}

resource "aws_iam_policy" "codebuild" {
  name   = "${var.project_name}-codebuild"
  path   = "/${var.project_name}/"
  policy = "${data.aws_iam_policy_document.codebuild.json}"
}
