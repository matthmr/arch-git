#!/usr/bin/sh

case $1 in
  '--help'|'-h')
    echo "Usage:       remove.sh REGEXP"
    echo "Description: Remove every build file that matches REGEXP"
    exit 0 ;;
esac

for file in *.xz *.sign *.zst; do
  if [[ $file =~ "$REGEXP" ]]; then
    rm -v $file
  fi
done
