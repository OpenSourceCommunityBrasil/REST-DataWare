#!/bin/sh
set -e
sudo apt-get update
sudo apt-get install -y libgtk-3-0 libwebkit2gtk-4.1-0 || \
sudo apt-get install -y libgtk-3-0 libwebkit2gtk-4.0-37
