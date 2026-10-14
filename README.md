# Wellevate Jenkins local pilot

This repository runs an isolated Jenkins LTS controller on Docker Desktop for
evaluating CI/CD workflows. It uses Pipeline Graph View and Stage View for pipeline
visualization. Blue Ocean is deprecated, so it is not installed. No Wellevate
application deployment is configured.

## Run locally

From this folder in PowerShell:

```powershell
docker compose build
docker compose up -d
```

Open <http://127.0.0.1:8088/> and follow the first-run setup wizard. Retrieve the
one-time unlock password locally with:

```powershell
docker compose exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

Keep the password and the administrator account in your own secure storage. The
Jenkins home, including credentials and job history, is stored in the Docker
volume `wellevate-eco-jenkins_jenkins_home`.

The controller image uses Jenkins 2.580.1 with Java 25 and Debian Python 3.
The local build on 2026-10-14 provided Python 3.13.5 and pip 25.1.1; these
package versions can change when the image is rebuilt from Debian repositories.
Before the local Java 25
upgrade, Jenkins home was copied to Docker volume
`wellevate-eco-jenkins_jenkins_home-pre-jdk25-20261014-01`. Treat that backup as
sensitive because it contains Jenkins data.
Before adding Python, Jenkins home was also copied to
`wellevate-eco-jenkins_jenkins_home-pre-python-20261014-01`.

After setup, select **New Item → Pipeline**, then under **Pipeline** choose
**Pipeline script** and paste the contents of this repository's `Jenkinsfile`.
Save and run **Build Now**. The **Pipeline Overview** link on the build page opens
Pipeline Graph View. Stage View appears on the job page. This local repository is
not mounted in the controller, so `Pipeline script from SCM` needs a remote
repository before it can be used.

The Graph View version in `Dockerfile` is pinned to one compatible with the
current LTS; newer releases may require a newer Jenkins core. Refresh the core
and plugins together during future updates.

The Amazon EC2 plugin was added through Jenkins' UI during this local pilot.
Its required Node Iterator API version is pinned in `Dockerfile` because the
initial UI download left only an incomplete `.jpi.tmp` file. The EC2 plugin
remains in the persistent Jenkins home volume. Installing a plugin does not
configure AWS access or an EC2 build agent.

The included smoke Pipeline now checks `python`, creates `.venv`, and checks
pip inside that virtual environment. For a Python project, install dependencies
inside a job-specific environment, for example:

```sh
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
.venv/bin/python -m pytest
```

Use the Python version required by each application. The smoke Pipeline's
`agent any` can use the built-in node in this single-controller pilot, but no
Jenkins job run has been verified. Future application builds should use a
dedicated agent with that toolchain, since Jenkins recommends running builds
on agents.

```powershell
docker compose ps
docker compose stop
docker compose start
```

The service listens only on localhost port 8088 and has no Docker socket or
deployment credentials. Running application image builds or deployments would
require separate build agents, credentials, approval rules, and reviewed pipeline
definitions. The included `Jenkinsfile` checks pipeline execution and Python
availability; it does not build an application.

## Evaluation notes

The tutorial at <https://github.com/devopsjourney1/jenkins-101> is a learning
reference. Its Dockerfile uses Jenkins 2.414.2 with Java 11 and older Blue Ocean
plugins, so this pilot uses official Jenkins LTS with Java 25. Compare Jenkins
against existing GitHub Actions for Console UAT using build time, maintenance,
secret handling, approval, rollback, and operator effort before changing releases.

The Dockerfile names Docker Hub's direct registry host because the local Docker
client returned an authentication error for the usual `jenkins/jenkins` shortcut.
It is the same official `jenkins/jenkins` image.
