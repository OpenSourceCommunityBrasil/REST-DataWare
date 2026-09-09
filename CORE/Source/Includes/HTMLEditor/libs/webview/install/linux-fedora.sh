#!/bin/sh
set -e
sudo dnf install -y gtk3 webkit2gtk4.1 || sudo dnf install -y gtk3 webkit2gtk3
