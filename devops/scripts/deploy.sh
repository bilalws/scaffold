#!/usr/bin/env bash
set -e

bash devops/scripts/deploy-backend.sh
bash devops/scripts/deploy-frontend.sh