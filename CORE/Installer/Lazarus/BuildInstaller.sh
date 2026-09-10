#!/bin/sh
set -e
cd "$(dirname "$0")"
if pgrep -x lazarus >/dev/null 2>&1; then
 echo "Lazarus esta aberto. Feche a IDE antes de compilar o instalador."
 exit 1
fi
lazbuild RESTDWInstaller.lpi
