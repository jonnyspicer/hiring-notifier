package main

import (
	"context"
	"fmt"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sns"
	"os"
)

func handler(ctx context.Context) error {
	sess, _ := session.NewSession(&aws.Config{
		Region: aws.String("eu-west-1")},
	)

	// Create SNS service client
	svc := sns.New(sess)

	// Get topic ARN from environment variable
	topicArn := os.Getenv("SNS_TOPIC_ARN")

	// Publish message
	result, err := svc.Publish(&sns.PublishInput{
		Message:  aws.String("Hello, World!"),
		TopicArn: aws.String(topicArn),
	})

	if err != nil {
		fmt.Println(err.Error())
		return err
	}

	fmt.Println(*result.MessageId)
	return nil
}

func main() {
	// Run the lambda function
	lambda.Start(handler)
}
