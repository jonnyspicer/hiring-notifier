package main

import (
	"context"
	"database/sql"
	"encoding/json"
	"fmt"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/awserr"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/lambda"
	"os"
	"strings"

	"github.com/gocolly/colly"

	_ "github.com/lib/pq"
)

type MyEvent struct {
	URL string `json:"url"`
}

type Job struct {
	Id         string
	Title      string
	Department string
	Team       string
	Location   string
	Link       string
}

var (
	host     = os.Getenv("DB_HOST")
	port     = os.Getenv("DB_PORT")
	user     = os.Getenv("DB_USER")
	password = os.Getenv("DB_PASSWORD")
	dbname   = os.Getenv("DB_NAME")
)

// TODO: have this take some kind of HTML schema that can then be parsed
func scrapeURL(url string) ([]Job, error) {
	var jobs []Job
	c := colly.NewCollector()

	c.OnHTML("section.level-0", func(e *colly.HTMLElement) {
		department := e.ChildText("h3")

		e.ForEach("section.level-1", func(_ int, e *colly.HTMLElement) {
			team := e.ChildText("h4")

			e.ForEach("div.opening", func(_ int, e *colly.HTMLElement) {
				link := e.ChildAttr("a", "href")
				ls := strings.Split(link, "/")

				job := Job{
					Id:         fmt.Sprintf("%s-%s", ls[1], ls[3]),
					Title:      e.ChildText("a"),
					Department: department,
					Team:       team,
					Location:   e.ChildText("span.location"),
					Link:       fmt.Sprintf("%s/%s", url, strings.Join(ls[2:], "/")),
				}
				jobs = append(jobs, job)
			})
		})
	})

	err := c.Visit(url)
	if err != nil {
		return nil, err
	}

	return jobs, nil
}

func insertJobs(db *sql.DB, jobs []Job) error {
	for _, job := range jobs {
		query := `INSERT INTO jobs (title, department, team, location, remote, link, description, company_id, created_at, updated_at)
			VALUES ($1, $2, $3, $4, $5, $6, $7, NOW(), NOW())`

		res, err := db.Exec(query, job.Title, job.Department, job.Team, job.Location, true, job.Link, "", 1)
		if err != nil {
			return err
		}

		ra, err := res.RowsAffected()
		if ra > 0 {
			invokeLambda(job)
		}
	}
	return nil
}

func invokeLambda(job Job) {
	sess := session.Must(session.NewSessionWithOptions(session.Options{
		SharedConfigState: session.SharedConfigEnable,
	}))

	svc := lambda.New(sess, &aws.Config{Region: aws.String("eu-west-1")})

	payload, err := json.Marshal(job)
	if err != nil {
		fmt.Println("Error marshalling Job struct into JSON")
		fmt.Println(err)
		return
	}

	input := &lambda.InvokeInput{
		FunctionName: aws.String("notifier"),
		Payload:      payload,
	}

	result, err := svc.Invoke(input)
	if err != nil {
		if aerr, ok := err.(awserr.Error); ok {
			fmt.Printf("%+v", aerr)
		} else {
			fmt.Println(err.Error())
		}
		return
	}

	fmt.Println(result)
}

func HandleRequest(ctx context.Context, event MyEvent) (string, error) {
	db, err := sql.Open("postgres", fmt.Sprintf("host=%s port=%s user=%s "+"password=%s dbname=%s sslmode=disable", host, port, user, password, dbname))
	if err != nil {
		return "", err
	}
	defer db.Close()

	jobs, err := scrapeURL(event.URL)
	if err != nil {
		return "", err
	}

	err = insertJobs(db, jobs)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("Scraped and inserted jobs from %s", event.URL), nil
}

func main() {
	//lambda.Start(HandleRequest)

	jobs, _ := scrapeURL("https://boards.greenhouse.io/strava")

	fmt.Printf("%+v\n", jobs)
}
