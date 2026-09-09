#!/bin/sh
set -e
cd "$(dirname "$0")"
fpc -O2 -Mobjfpc -o../../RESTDWPackager RESTDWPackager.pas
