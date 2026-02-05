# frozen_string_literal: true

# Disable automatic checksum calculation for S3-compatible services (Cloudflare R2)
# R2 doesn't support multiple checksums, which causes "InvalidRequest" errors
if defined?(Aws::S3)
  Aws.config.update(
    request_checksum_calculation: "WHEN_REQUIRED",
    response_checksum_validation: "WHEN_REQUIRED"
  )
end
