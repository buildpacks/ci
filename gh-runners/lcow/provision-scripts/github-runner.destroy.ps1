param (
    # github owner
    [string]$Owner,
    # github repo
    [string]$Repo
)

$ErrorActionPreference = "Stop"

$ACTIONS_RUNNER_INSTALL_DIR = "\actions-runners\$Owner-$Repo"
$ACTIONS_RUNNER_WORK_DIR = "$ACTIONS_RUNNER_INSTALL_DIR-work"

Push-Location $ACTIONS_RUNNER_INSTALL_DIR

  $ACTIONS_RUNNER_INPUT_TOKEN = (cat .\.github-runner-token)
  echo "> Token: $ACTIONS_RUNNER_INPUT_TOKEN"

  echo "> Unregistering runner..."
  .\config.cmd remove --unattended --token $ACTIONS_RUNNER_INPUT_TOKEN

Pop-Location

echo "> Cleaning up..."
rm -Recurse -Force $ACTIONS_RUNNER_INSTALL_DIR
rm -Recurse -Force $ACTIONS_RUNNER_WORK_DIR
