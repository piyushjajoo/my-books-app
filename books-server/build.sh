#!/bin/sh

GOOS=linux go build .
docker build -t books-server .