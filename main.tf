resource "aws_ecr_repository" "ch_aa_ecr_repo" {
  name                 = "ch_aa_ecr_repo"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}