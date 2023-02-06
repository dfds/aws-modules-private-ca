## Private CA

variable "key_algorithm" {
  type        = string
  description = "Type of the public key algorithm and size, in bits, of the key pair that your key pair creates when it issues a certificate"
  default     = "RSA_2048"
}

variable "signing_algorithm" {
  type        = string
  description = "Name of the algorithm your private CA uses to sign certificate requests"
  default     = "SHA256WITHRSA"
}

variable "common_name" {
  type        = string
  description = "Fully qualified domain name (FQDN) associated with the certificate subject"
  default     = ""
}

variable "country" {
  type        = string
  description = "Two digit code that specifies the country in which the certificate subject located"
  default     = ""
}

variable "locality" {
  type        = string
  description = "Locality (such as a city or town) in which the certificate subject is located"
  default     = ""
}

variable "organization" {
  type        = string
  description = "Legal name of the organization with which the certificate subject is affiliated"
  default     = ""
}

variable "organizational_unit" {
  type        = string
  description = "Subdivision or unit of the organization (such as sales or finance) with which the certificate subject is affiliated"
  default     = ""
}

variable "private_ca_tags" {
  type        = object({})
  description = "Map of tags for private CA"
  default     = {}
}

variable "cloudfront_tags" {
  type        = object({})
  description = "Map of tags for Cloudfront distribution"
  default     = {}
}

variable "state" {
  type        = string
  description = "State in which the subject of the certificate is located"
  default     = ""
}

variable "usage_mode" {
  type        = string
  description = "Specifies whether the CA issues general-purpose certificates that typically require a revocation mechanism, or short-lived certificates that may optionally omit revocation because they expire quickly"
  default     = "GENERAL_PURPOSE"
}

variable "ca_type" {
  type        = string
  description = "Type of the certificate authority. Defaults to `SUBORDINATE`"
  default     = "SUBORDINATE"
}


## CRL

variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket that contains the CRL"
  default     = ""
}

variable "custom_cname" {
  type        = string
  description = "Name inserted into the certificate CRL Distribution Points extension that enables the use of an alias for the CRL distribution point. Use this value if you don't want the name of your S3 bucket to be public"
  default     = ""
}

variable "enable_crl" {
  type        = bool
  description = "Whether to enable Certificate Revocation Lists"
  default     = true
}

variable "expiration_in_days" {
  type        = number
  description = "Number of days until a certificate expires"
  default     = 7
}

variable "s3_object_acl" {
  type        = string
  description = "Determines whether the CRL will be publicly readable or privately held in the CRL Amazon S3 bucket"
  default     = "BUCKET_OWNER_FULL_CONTROL"
}


## OCSP

variable "enable_ocsp" {
  type        = bool
  description = "Whether a custom OCSP responder is enabled"
  default     = true
}

variable "ocsp_custom_cname" {
  type        = string
  description = "CNAME specifying a customized OCSP domain"
  default     = ""
}

## KMS

variable "create_kms" {
  type        = bool
  description = "Whether to create a KMS key for S3 bucket"
  default     = true
}

variable "kms_key_alias" {
  type        = string
  description = "Alias for the KMS key"
  default     = ""
}

variable "enable_kms_default_policy" {
  type        = bool
  description = "Whether to enable default policy for KMS key"
  default     = true
}

variable "enable_key_rotation" {
  type        = bool
  description = "Whether to enable key rotation"
  default     = true
}

variable "kms_key_administrators" {
  type        = list(string)
  description = "List of KMS key administrators"
  default     = []
}

variable "kms_key_users" {
  type        = list(string)
  description = "List of KMS key users"
  default     = []
}


## Cloudfront

variable "cloudfront_logging_bucket" {
  type        = string
  description = "Name of the S3 bucket for Cloudfront logs"
  default     = ""
}
