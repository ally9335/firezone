#!/usr/bin/env bash
set -xe

prefix=${MATRIX_OS}_${MATRIX_ARCH}

mkdir -p pkg/$prefix/opt/cloudfire/bin
mv cloudfire-${MATRIX_ARCH} pkg/$prefix/opt/cloudfire/bin/cloudfire
dpkg-deb --build pkg/$prefix
mv pkg/$prefix.deb ./cloudfire_$prefix.deb
