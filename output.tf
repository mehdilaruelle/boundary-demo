data "aws_instance" "boundary" {
  filter {
    name   = "tag:Name"
    values = [local.tags["Name"]]
  }

  depends_on = [aws_autoscaling_group.instance]
}

output "boundary_endpoint" {
  value = "http://${data.aws_instance.boundary.public_ip}:9200"
}

output "ami_version_id" {
  value = data.aws_ami.amazon_latest.id
}


output "vpc_id" {
  value = aws_vpc.boundary.id
}

output "subnets_private" {
  value = tolist(aws_subnet.private.*.id)
}
