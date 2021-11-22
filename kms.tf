resource "aws_kms_key" "root" {
  description             = "Boundary root key"
  deletion_window_in_days = 7
}

resource "aws_kms_key" "worker" {
  count = var.env == "prod" ? 1 : 0

  description             = "Boundary worker authentication key"
  deletion_window_in_days = 7
}

resource "aws_kms_key" "recovery" {
  count = var.env == "prod" ? 1 : 0

  description             = "Boundary recovery key"
  deletion_window_in_days = 7
}
