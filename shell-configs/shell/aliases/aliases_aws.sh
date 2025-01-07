# basic AWS CLI aliases
alias sand="aws sso login --profile sandbox-admin --"
alias data="aws sso login --profile data --"

# aws-vault aliases
alias avs="aws-vault exec sandbox-admin"
alias avs8="avs --duration8h"
alias avd="aws-vault exec data"
alias avd8="avd --duration8h"

# Persistent aws login (equivalent to aws-vault), but w/ no subshell
aws_login() {
    export AWS_PROFILE="$1"
    aws sso login --profile "$1"
}

# Aliases using the function
alias sso-sand='aws_login sandbox-admin'
alias sso-data='aws_login data'
alias sso-dataeng='aws_login dataeng'
