# S3 bucket for storing audio files
resource "aws_s3_bucket" "audio_storage" {
  bucket = "${var.project_name}-audio-storage-${random_id.bucket_id.hex}"

  tags = {
    Name = "${var.project_name}-audio-storage"
  }
}

resource "random_id" "bucket_id" {
  byte_length = 8
}

resource "aws_s3_bucket_public_access_block" "audio_storage" {
  bucket = aws_s3_bucket.audio_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
