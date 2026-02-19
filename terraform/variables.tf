variable "aws_region" {
  default = "us-east-1"
}

variable "image_tag" {
  description = "Docker image tag from GitHub Actions"
  type        = string
  default     = "latest"
}