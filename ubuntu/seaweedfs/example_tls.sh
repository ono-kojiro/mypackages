#!/bin/sh

set -e

export PYTHONWARNINGS="ignore:Unverified HTTPS request"

export AWS_ACCESS_KEY_ID=mykey
export AWS_SECRET_ACCESS_KEY=mysecret

endpoint_url="https://localhost:8333"

aws_opts="--endpoint-url $endpoint_url --no-verify-ssl"

aws $aws_opts s3 rb s3://mybucket --force || true
aws $aws_opts s3 mb s3://mybucket
date > hello.txt
aws $aws_opts s3 cp hello.txt s3://mybucket/hello.txt
aws $aws_opts s3 ls s3://mybucket
aws $aws_opts s3 cp s3://mybucket/hello.txt ./hello_downloaded.txt
cat hello_downloaded.txt

