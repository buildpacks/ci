param (
    # github owner
    [string]$Owner,
    # github repo
    [string]$Repo,
    # github token
    [string]$Token
)

$ErrorActionPreference = "Stop"

$ACTIONS_RUNNER_INSTALL_DIR = "\actions-runners\$Owner-$Repo"
$ACTIONS_RUNNER_WORK_DIR = "$ACTIONS_RUNNER_INSTALL_DIR-work"

$RUNNER_TOKEN_REQUEST = @{
  Uri = "https://api.github.com/repos/${Owner}/${Repo}/actions/runners/remove-token"
  Method = "POST"
  Headers = @{
    Authorization = "Bearer ${Token}"
    ContentType = "application/json"
  }
}

Push-Location $ACTIONS_RUNNER_INSTALL_DIR

  echo "> Configuring runner..."
  $ACTIONS_RUNNER_INPUT_TOKEN = (Invoke-RestMethod @RUNNER_TOKEN_REQUEST).token
  echo "Token: $ACTIONS_RUNNER_INPUT_TOKEN"
  
  echo "> Unregistering runner..."
  ./config.cmd remove --unattended --token $ACTIONS_RUNNER_INPUT_TOKEN

Pop-Location

echo "> Cleaning up..."
rm -Recurse -Force $ACTIONS_RUNNER_INSTALL_DIR
rm -Recurse -Force $ACTIONS_RUNNER_WORK_DIR
