data "aws_iam_policy_document" "s3-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${aws_iam_openid_connect_provider.eks.url}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_policy" "bucket-policy" {
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
            "${aws_s3_bucket.pachaform-s3-bucket.arn}/*",
            "${aws_s3_bucket.pachaform-s3-bucket.arn}",
          ]
          Sid = ""
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_iam_role" "pachaform-s3-role" {
  name               = "${var.project_name}-s3-role"
  assume_role_policy = data.aws_iam_policy_document.s3-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "pachaform-s3-bucket-policy_attachment" {
  role       = aws_iam_role.pachaform-s3-role.id
  policy_arn = aws_iam_policy.bucket-policy.arn
  depends_on = [
    aws_s3_bucket.pachaform-s3-bucket,
    aws_iam_role.pachaform-s3-role,
    aws_iam_policy.bucket-policy,
  ]
}

resource "aws_s3_bucket" "pachaform-s3-bucket" {
  bucket        = "${var.project_name}-bucket"
  force_destroy = true
  depends_on = [
    aws_iam_role.pachaform-s3-role,
    aws_internet_gateway.pachaform_internet_gateway,
    aws_nat_gateway.pachaform_nat_gateway,
  ]
}
