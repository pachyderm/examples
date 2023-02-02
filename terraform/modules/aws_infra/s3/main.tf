data "aws_iam_policy_document" "s3_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${var.eks_oidc_url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [var.eks_oidc_arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "bucket_policy" {
  name = "${var.project_name}-bucket-policy"
  policy = jsonencode(
    {
      Statement = [
        {
          Action = [
            "s3:PutObject",
            "s3:ListBucket",
            "s3:GetObject",
            "s3:DeleteObject",
          ]
          Effect = "Allow"
          Resource = [
            "${aws_s3_bucket.s3_bucket.arn}/*",
            "${aws_s3_bucket.s3_bucket.arn}",
          ]
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role" "s3_role" {
  name               = "${var.project_name}-s3-role"
  assume_role_policy = data.aws_iam_policy_document.s3_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "s3_bucket_policy_attachment" {
  role       = aws_iam_role.s3_role.id
  policy_arn = aws_iam_policy.bucket_policy.arn
  depends_on = [
    aws_s3_bucket.s3_bucket,
  ]
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "${var.project_name}-bucket"
  force_destroy = true
  depends_on = [
    aws_iam_role.s3_role,
  ]
  tags = {
    Owner = var.admin_user
  }
}
