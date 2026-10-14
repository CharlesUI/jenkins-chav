FROM registry-1.docker.io/jenkins/jenkins:2.580.1-jdk25

# The local pilot can run its smoke build on this controller. Install Python,
# with venv for per-job dependencies and the `python` alias for shell scripts.
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    python3-venv \
    python3-pip \
    python-is-python3 \
    && rm -rf /var/lib/apt/lists/*
USER jenkins

# Blue Ocean is deprecated. Keep the maintained graph and stage views available.
RUN jenkins-plugin-cli --plugins \
    workflow-aggregator \
    git \
    pipeline-stage-view \
    pipeline-graph-view:980.vb_db_0b_e5f683c \
    node-iterator-api:72.vc90e81737df1
