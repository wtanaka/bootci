#!/bin/sh
# Copyright (C) 2018 Wesley Tanaka
#
# This file is part of github.com/wtanaka/bootci
#
# github.com/wtanaka/bootci is free software: you can redistribute it
# and/or modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation, either version 3 of
# the License, or (at your option) any later version.
#
# github.com/wtanaka/bootci is distributed in the hope that it will be
# useful, but WITHOUT ANY WARRANTY; without even the implied warranty
# of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with github.com/wtanaka/bootci.  If not, see
# <http://www.gnu.org/licenses/>.

set -e

DIRNAME="`dirname $0`"

if [ -z "$BRANCH" ]; then
  BRANCH=master
fi

# PYTHONHTTPSVERIFY=0 to work around Ubuntu 16.04.1
# [SSL: CERTIFICATE_VERIFY_FAILED] certificate verify failed
if ! [ -f "$DIRNAME"/../gradlew ]; then
  (
    > "$DIRNAME"/../gradlew \
    env PYTHONHTTPSVERIFY=0 \
      "$DIRNAME"/download.sh \
      https://raw.githubusercontent.com/gradle/gradle/master/gradlew
      #https://raw.githubusercontent.com/wtanaka/bootci/$BRANCH/assets/gradlew
    chmod a+x gradlew
    mkdir -p "$DIRNAME"/../gradle/wrapper
    > "$DIRNAME"/../gradle/wrapper/gradle-wrapper.jar \
    env PYTHONHTTPSVERIFY=0 \
      "$DIRNAME"/download.sh \
      https://raw.githubusercontent.com/gradle/gradle/master/gradle/wrapper/gradle-wrapper.jar
      #https://raw.githubusercontent.com/wtanaka/bootci/$BRANCH/assets/gradle/wrapper/gradle-wrapper.jar
    > "$DIRNAME"/../gradle/wrapper/gradle-wrapper.properties \
    env PYTHONHTTPSVERIFY=0 \
      "$DIRNAME"/download.sh \
      https://raw.githubusercontent.com/gradle/gradle/v4.10.3/gradle/wrapper/gradle-wrapper.properties
      #https://raw.githubusercontent.com/wtanaka/bootci/$BRANCH/assets/gradle/wrapper/gradle-wrapper.properties
  )
fi
