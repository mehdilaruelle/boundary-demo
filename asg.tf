resource "aws_security_group" "instance" {
  name        = local.tags["Name"]
  description = "SG for Boundary"
  vpc_id      = aws_vpc.boundary.id

  #API port
  ingress {
    from_port   = "9200"
    to_port     = "9200"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port = "9201"
    to_port   = "9201"
    protocol  = "tcp"
    self      = true
  }
  #Proxy port
  ingress {
    from_port   = "9202"
    to_port     = "9202"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "session_manager" {
  name = local.tags["Name"]

  assume_role_policy = data.aws_iam_policy_document.instance-assume-role-policy.json
}

resource "aws_iam_role_policy_attachment" "session_manager" {
  role       = aws_iam_role.session_manager.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "session_manager" {
  name = local.tags["Name"]
  role = aws_iam_role.session_manager.name
}

resource "aws_iam_role_policy" "boundary" {
  name = local.tags["Name"]
  role = aws_iam_role.session_manager.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": {
    "Effect": "Allow",
    "Action": [
      "kms:DescribeKey",
      "kms:GenerateDataKey",
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:ListKeys",
      "kms:ListAliases"
    ],
    "Resource": [
      "${aws_kms_key.root.arn}",
      "${try(one(aws_kms_key.worker).arn, aws_kms_key.root.arn)}",
      "${try(one(aws_kms_key.recovery).arn, aws_kms_key.root.arn)}"
    ]
  }
}
EOF
}

data "template_file" "boundary_install" {
  template = file("${path.module}/userdata.tpl")
  vars = {
    db_url          = "${aws_db_instance.boundary.engine}://${aws_db_instance.boundary.username}:${random_password.db_master_pass.result}@${aws_db_instance.boundary.endpoint}/${aws_db_instance.boundary.name}"
    key_id_root     = aws_kms_key.root.arn
    key_id_worker   = try(one(aws_kms_key.worker).arn, aws_kms_key.root.arn)
    key_id_recovery = try(one(aws_kms_key.recovery).arn, aws_kms_key.root.arn)
  }
}

resource "aws_launch_template" "instance" {
  name          = local.tags["Name"]
  image_id      = data.aws_ami.amazon_latest.id
  instance_type = var.instance_type
  monitoring {
    enabled = false
  }
  iam_instance_profile {
    name = aws_iam_instance_profile.session_manager.name
  }
  vpc_security_group_ids = [aws_security_group.instance.id]

  user_data = base64encode(data.template_file.boundary_install.rendered)
}

resource "aws_autoscaling_group" "instance" {
  name                      = local.tags["Name"]
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 600
  health_check_type         = "EC2"
  desired_capacity          = 1
  force_delete              = true
  vpc_zone_identifier       = [aws_subnet.public.id]

  launch_template {
    id      = aws_launch_template.instance.id
    version = "$Latest"
  }

  dynamic "tag" {
    for_each = local.tags

    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
