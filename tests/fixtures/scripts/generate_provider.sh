#!/bin/bash

set -e

echo "In generate_provider.sh"

function generate_tf_state_file_name () {
  if [ -n "$TF_STATE_FILE_NAME" ]; then
    filename="$TF_STATE_FILE_NAME"
  else
    filename="tf-state-$1"
  fi

  if [ -n "$TF_STATE_FILE_NAME_APPEND" ]; then
    filename="${filename}-${TF_STATE_FILE_NAME_APPEND}"
  fi
  echo $filename
}

echo "
terraform {
  required_providers {
    aws = {
      source  = \"hashicorp/aws\"
      version = \"~> 4.30\"
    }
    random = {
      source  = \"hashicorp/random\"
      version = \">= 2.2\"
    }
  }

  backend \"s3\" {
    region  = \"${AWS_DEFAULT_REGION}\"
    bucket  = \"${TF_STATE_BUCKET}\"
    key     = \"$(generate_tf_state_file_name site)\"
    encrypt = true #AES-256encryption
  }
}

provider \"aws\" {
  region = \"${AWS_DEFAULT_REGION}\"
  default_tags {
    tags = merge(
      local.aws_tags,
      var.aws_additional_tags
    )
  }
}
" > "${GITHUB_ACTION_PATH}/terraform_code/provider.tf"
