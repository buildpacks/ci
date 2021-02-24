param (
    # github owner
    [string]$Owner,
    # github repo
    [string]$Repo,
    # github token
    [string]$Token,
    # github runner version
    [string]$Version,
    # service logon account
    [string]$ServiceAccount,
    # service logon password
    [string]$ServicePassword
)

$ErrorActionPreference = "Stop"

$ACTIONS_RUNNER_INSTALL_DIR = "\actions-runners\$Owner-$Repo"
$ACTIONS_RUNNER_WORK_DIR = "$ACTIONS_RUNNER_INSTALL_DIR-work"

echo "> Creating workspace..."
md -Force $ACTIONS_RUNNER_INSTALL_DIR
md -Force $ACTIONS_RUNNER_WORK_DIR

echo "> Downloading runner..."
curl.exe -Lo actions-runner-win-x64-$Version.zip https://github.com/actions/runner/releases/download/v$Version/actions-runner-win-x64-$Version.zip
Expand-Archive -Force -Path actions-runner-win-x64-$Version.zip -DestinationPath "$ACTIONS_RUNNER_INSTALL_DIR"

$RUNNER_TOKEN_REQUEST = @{
  Uri = "https://api.github.com/repos/${Owner}/${Repo}/actions/runners/registration-token"
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
  
  ./config.cmd --unattended --replace --runasservice `
      --windowslogonaccount "$ServiceAccount" `
      --windowslogonpassword "$ServicePassword" `
      --name "$(hostname)" `
      --labels "lcow" `
      --work $ACTIONS_RUNNER_WORK_DIR `
      --url "https://github.com/${Owner}/${Repo}" `
      --token $ACTIONS_RUNNER_INPUT_TOKEN

Pop-Location
