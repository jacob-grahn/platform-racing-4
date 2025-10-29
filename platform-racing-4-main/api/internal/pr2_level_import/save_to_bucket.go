package pr2_level_import

import (
	"fmt"
	"os"
	"strings"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

var (
	bucket    = os.Getenv("BUCKET")
	awsRegion = os.Getenv("AWS_REGION")
)

func saveToBucket(key string, buffer []byte) error {
	fmt.Println("stashFile", key)

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(awsRegion)},
	)
	if err != nil {
		return err
	}
	svc := s3.New(sess)

	_, err = svc.PutObject(&s3.PutObjectInput{
		Bucket: aws.String(bucket),
		Key:    aws.String(key),
		Body:   aws.ReadSeekCloser(strings.NewReader(string(buffer))),
	})
	return err
}
