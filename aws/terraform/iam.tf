# Spinnaker managing user
resource "aws_iam_user" "spinnaker" {
  name = "spinnaker"
  path = "/"
}

resource "aws_iam_access_key" "spinnaker" {
  user = "${aws_iam_user.spinnaker.name}"
}

resource "aws_iam_user_policy" "spinnaker" {
  name = "spinnaker"
  user = "${aws_iam_user.spinnaker.name}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Action": "sts:AssumeRole",
        "Resource": [
            "arn:aws:iam::${var.AWS_ACCOUNT_ID}:role/spinnaker-managed"
        ],
        "Effect": "Allow"
    }]
}
EOF
}

# Spinnaker managed role
resource "aws_iam_role" "spinnaker-managed" {
  name = "spinnaker-managed"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "AWS": "${aws_iam_user.spinnaker.arn}"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_role_policy" "spinnaker-managed" {
  name = "spinnaker-managed"
  role = "${aws_iam_role.spinnaker-managed.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [{
        "Effect": "Allow",
        "Action": [ "ec2:*" ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": "iam:PassRole",
        "Resource": "arn:aws:iam::${var.AWS_ACCOUNT_ID}:role/BaseIAMRole"
    }]
}
EOF
}

resource "aws_iam_role_policy" "spinnaker-managed-poweruser" {
  name = "poweruser"
  role = "${aws_iam_role.spinnaker-managed.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "NotAction": [
                "iam:*",
                "organizations:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole",
                "iam:DeleteServiceLinkedRole",
                "iam:ListRoles",
                "organizations:DescribeOrganization"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

# base ec2 iam role
resource "aws_iam_role" "base-iam-role" {
  name = "BaseIAMRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}
resource "aws_iam_instance_profile" "base-iam-role" {
  name  = "BaseIAMRole"
  role = "${aws_iam_role.base-iam-role.name}"
}


