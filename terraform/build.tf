resource "aws_ecr_repository" "build" {
  name = "${var.org_name}"
}

resource "aws_s3_bucket" "build" {
  bucket = "codepipeline-${var.project_name}"
  acl = "private"
}

resource "aws_codepipeline" "build" {
  name = "${var.project_name}"
  role_arn = "${aws_iam_role.codepipeline.arn}"

  artifact_store {
    location = "${aws_s3_bucket.build.bucket}"
    type = "S3"
  }

  stage {
    name = "Source"

    action {
      name = "Source"
      category = "Source"
      owner = "ThirdParty"
      provider = "GitHub"
      version = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
	Owner = "${var.github_owner}"
	Repo = "${var.project_name}"
	Branch = "master"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name = "Build"
      category = "Build"
      owner = "AWS"
      provider = "CodeBuild"
      input_artifacts = ["SourceArtifact"]
      version = "1"

      configuration = {
	ProjectName = "${aws_codebuild_project.build.name}"
      }
    }
  }
}

resource "aws_codebuild_project" "build" {
  name = "${var.project_name}"
  build_timeout = "5"
  service_role = "${aws_iam_role.codebuild.arn}"

  artifacts {
    type = "CODEPIPELINE"
  }

  cache {
    type = "S3"
    location = "${aws_s3_bucket.build.bucket}"
  }

  environment {
    compute_type = "BUILD_GENERAL1_SMALL"
    image = "aws/codebuild/docker:18.09.0"
    type = "LINUX_CONTAINER"
    privileged_mode = true

    environment_variable {
      "name" = "AWS_DEFAULT_REGION"
      "value" = "${var.aws_region}"
    }

    environment_variable {
      "name" = "IMAGE_REPO_NAME"
      "value" = "${var.project_name}"
    }

    environment_variable {
      "name" = "IMAGE_TAG"
      "value" = "latest"
    }

    environment_variable {
      "name" = "AWS_ACCOUNT_ID"
      "value" = "${var.aws_account_id}"
    }

  }

  source {
    type = "CODEPIPELINE"
  }

}
