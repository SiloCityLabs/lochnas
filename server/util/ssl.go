package util

import (
	"crypto/x509"
	"encoding/pem"
	"fmt"
	"io/ioutil"
)

// https://stackoverflow.com/questions/45970008/how-to-check-validity-of-pem-certificate-issued-by-ca
func VerifyCert(rootPEMPath, certPEMPath string, name string) error {
	//Open root certificate
	rootPEM, err := ioutil.ReadFile(rootPEMPath)
	if err != nil {
		return err
	}
	//Open certificate
	certPEM, err := ioutil.ReadFile(certPEMPath)
	if err != nil {
		return err
	}

	roots := x509.NewCertPool()
	ok := roots.AppendCertsFromPEM(rootPEM)
	if !ok {
		return fmt.Errorf("failed to parse root certificate")
	}

	block, _ := pem.Decode(certPEM)
	if block == nil {
		return fmt.Errorf("failed to parse certificate PEM")
	}
	cert, err := x509.ParseCertificate(block.Bytes)
	if err != nil {
		return fmt.Errorf("failed to parse certificate: %v", err.Error())
	}

	opts := x509.VerifyOptions{
		DNSName: name,
		Roots:   roots,
	}

	if _, err := cert.Verify(opts); err != nil {
		return fmt.Errorf("failed to verify certificate: %v", err.Error())
	}

	return nil
}
