output "private_ca_arn" {
  value       = aws_acmpca_certificate_authority.this.arn
  description = "ARN of the private certificate authority"
}