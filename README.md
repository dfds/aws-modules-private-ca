# aws-modules-private-ca
AWS Private CA enables creation of private certificate authority (CA) hierarchies, including root and subordinate CAs

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.50.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.53.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cloudfront"></a> [cloudfront](#module\_cloudfront) | git::https://github.com/dfds/aws-modules-cloudfront.git | main |
| <a name="module_cloudfront_logging_bucket"></a> [cloudfront\_logging\_bucket](#module\_cloudfront\_logging\_bucket) | git::https://github.com/dfds/aws-modules-s3.git | main |
| <a name="module_crl_bucket"></a> [crl\_bucket](#module\_crl\_bucket) | git::https://github.com/dfds/aws-modules-s3.git | main |

## Resources

| Name | Type |
|------|------|
| [aws_acmpca_certificate_authority.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acmpca_certificate_authority) | resource |
| [aws_cloudfront_origin_access_identity.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudfront_origin_access_identity) | resource |
| [aws_kms_alias.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket_name"></a> [bucket\_name](#input\_bucket\_name) | Name of the S3 bucket that contains the CRL | `string` | `""` | no |
| <a name="input_ca_type"></a> [ca\_type](#input\_ca\_type) | Type of the certificate authority. Defaults to `SUBORDINATE` | `string` | `"SUBORDINATE"` | no |
| <a name="input_cloudfront_logging_bucket"></a> [cloudfront\_logging\_bucket](#input\_cloudfront\_logging\_bucket) | Name of the S3 bucket for Cloudfront logs | `string` | `""` | no |
| <a name="input_cloudfront_tags"></a> [cloudfront\_tags](#input\_cloudfront\_tags) | Map of tags for Cloudfront distribution | `object({})` | `{}` | no |
| <a name="input_common_name"></a> [common\_name](#input\_common\_name) | Fully qualified domain name (FQDN) associated with the certificate subject | `string` | `""` | no |
| <a name="input_country"></a> [country](#input\_country) | Two digit code that specifies the country in which the certificate subject located | `string` | `""` | no |
| <a name="input_create_kms"></a> [create\_kms](#input\_create\_kms) | Whether to create a KMS key for S3 bucket | `bool` | `true` | no |
| <a name="input_custom_cname"></a> [custom\_cname](#input\_custom\_cname) | Name inserted into the certificate CRL Distribution Points extension that enables the use of an alias for the CRL distribution point. Use this value if you don't want the name of your S3 bucket to be public | `string` | `""` | no |
| <a name="input_enable_crl"></a> [enable\_crl](#input\_enable\_crl) | Whether to enable Certificate Revocation Lists | `bool` | `true` | no |
| <a name="input_enable_key_rotation"></a> [enable\_key\_rotation](#input\_enable\_key\_rotation) | Whether to enable key rotation | `bool` | `true` | no |
| <a name="input_enable_kms_default_policy"></a> [enable\_kms\_default\_policy](#input\_enable\_kms\_default\_policy) | Whether to enable default policy for KMS key | `bool` | `true` | no |
| <a name="input_enable_ocsp"></a> [enable\_ocsp](#input\_enable\_ocsp) | Whether a custom OCSP responder is enabled | `bool` | `true` | no |
| <a name="input_expiration_in_days"></a> [expiration\_in\_days](#input\_expiration\_in\_days) | Number of days until a certificate expires | `number` | `7` | no |
| <a name="input_key_algorithm"></a> [key\_algorithm](#input\_key\_algorithm) | Type of the public key algorithm and size, in bits, of the key pair that your key pair creates when it issues a certificate | `string` | `"RSA_2048"` | no |
| <a name="input_kms_key_administrators"></a> [kms\_key\_administrators](#input\_kms\_key\_administrators) | List of KMS key administrators | `list(string)` | `[]` | no |
| <a name="input_kms_key_alias"></a> [kms\_key\_alias](#input\_kms\_key\_alias) | Alias for the KMS key | `string` | `""` | no |
| <a name="input_kms_key_users"></a> [kms\_key\_users](#input\_kms\_key\_users) | List of KMS key users | `list(string)` | `[]` | no |
| <a name="input_locality"></a> [locality](#input\_locality) | Locality (such as a city or town) in which the certificate subject is located | `string` | `""` | no |
| <a name="input_ocsp_custom_cname"></a> [ocsp\_custom\_cname](#input\_ocsp\_custom\_cname) | CNAME specifying a customized OCSP domain | `string` | `""` | no |
| <a name="input_organization"></a> [organization](#input\_organization) | Legal name of the organization with which the certificate subject is affiliated | `string` | `""` | no |
| <a name="input_organizational_unit"></a> [organizational\_unit](#input\_organizational\_unit) | Subdivision or unit of the organization (such as sales or finance) with which the certificate subject is affiliated | `string` | `""` | no |
| <a name="input_private_ca_tags"></a> [private\_ca\_tags](#input\_private\_ca\_tags) | Map of tags for private CA | `object({})` | `{}` | no |
| <a name="input_s3_object_acl"></a> [s3\_object\_acl](#input\_s3\_object\_acl) | Determines whether the CRL will be publicly readable or privately held in the CRL Amazon S3 bucket | `string` | `"BUCKET_OWNER_FULL_CONTROL"` | no |
| <a name="input_signing_algorithm"></a> [signing\_algorithm](#input\_signing\_algorithm) | Name of the algorithm your private CA uses to sign certificate requests | `string` | `"SHA256WITHRSA"` | no |
| <a name="input_state"></a> [state](#input\_state) | State in which the subject of the certificate is located | `string` | `""` | no |
| <a name="input_usage_mode"></a> [usage\_mode](#input\_usage\_mode) | Specifies whether the CA issues general-purpose certificates that typically require a revocation mechanism, or short-lived certificates that may optionally omit revocation because they expire quickly | `string` | `"GENERAL_PURPOSE"` | no |

## Outputs

No outputs.
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
