package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/acmpca"
	"github.com/aws/aws-sdk-go-v2/service/acmpca/types"
	"log"
	"os"
)


func HandleRequest(ctx context.Context) (string, error) {

	cfg, err := config.LoadDefaultConfig(ctx)
	if err != nil {
		log.Fatalf("failed to load configuration, %v", err)
	}

	svc := acmpca.NewFromConfig(cfg)

	caArn := aws.String(os.Getenv("CA_ARN"))

	// Chceck private CA status
	dcai := &acmpca.DescribeCertificateAuthorityInput{CertificateAuthorityArn: aws.String(os.Getenv("CA_ARN"))}
	dcao, err := svc.DescribeCertificateAuthority(ctx, dcai)
	if err != nil {
		fmt.Println(err.Error())
		return "", err
	}
	status := dcao.CertificateAuthority.Status
	if status != "PENDING_CERTIFICATE" && status != "EXPIRED" {
		fmt.Println("Certificate authority status: ", status)
	}

	// Retrieve the certificate signing request (CSR)
	csrInput := &acmpca.GetCertificateAuthorityCsrInput{
		CertificateAuthorityArn: aws.String(os.Getenv("CA_ARN")),
	}
	csrOutput, err := svc.GetCertificateAuthorityCsr(ctx, csrInput)
	if err != nil {
		fmt.Println(err.Error())
		return "", err
	}

	// Issue a self-signed RootCACertificate
	ici := &acmpca.IssueCertificateInput{
		CertificateAuthorityArn: caArn,
		Csr: []byte(*csrOutput.Csr),
		SigningAlgorithm: "SHA256WITHRSA",
		Validity: &types.Validity{Type: "DAYS", Value: aws.Int64(7)},
		TemplateArn: aws.String("arn:aws:acm-pca:::template/RootCACertificate/V1"),
	}
	ico, err := svc.IssueCertificate(ctx, ici)
	if err != nil {
		fmt.Println(err.Error())
		return "", err
	}

	// Retrieve the self-signed certificate
	gci := &acmpca.GetCertificateInput{
		CertificateArn: ico.CertificateArn,
		CertificateAuthorityArn: caArn,
	}
	gco, err := svc.GetCertificate(ctx, gci)
	if err != nil {
		fmt.Println(err.Error())
		return "", err
	}

	// Import the certificate into the private CA
	icaci := &acmpca.ImportCertificateAuthorityCertificateInput{
		Certificate: []byte(*gco.Certificate),
		CertificateAuthorityArn: caArn,
	}
	_, err = svc.ImportCertificateAuthorityCertificate(ctx, icaci)
	if err != nil {
		fmt.Println(err.Error())
		return "", err
	}

	return "Success!", nil
}

func main() {
	lambda.Start(HandleRequest)
}