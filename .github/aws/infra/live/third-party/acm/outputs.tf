output "certificate_arn" {
  description = "The ARN of the regional ACM certificate (for ALB)"
  value       = aws_acm_certificate_validation.main.certificate_arn
}

output "cloudfront_certificate_arn" {
  description = "The ARN of the CloudFront ACM certificate (us-east-1)"
  value       = aws_acm_certificate_validation.cloudfront.certificate_arn
}
