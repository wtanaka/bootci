#!/bin/sh
# Copyright (C) 2020 Wesley Tanaka
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
ABSTARGET="`${DIRNAME}/realpath.sh ${TARGET}`"

. "${DIRNAME}"/common.sh

echo "uname -s is $(uname -s)"
if [ $(uname -s) == "Darwin" ]; then
  /bin/sh "$DIRNAME"/download.sh \
    https://github.com/downloads/GPGTools/GPGTools/GPGTools-20120318.dmg > \
    /tmp/GPGTools.dmg
  hdiutil attach /tmp/GPGTools.dmg
  # TODO: Find a GPG package that does not need root to install
  sudo installer -pkg /Volumes/GPGTools/GPGTools.mpkg -target /
  hdiutil detach /Volumes/GPGTools
  find "$DIRNAME"
fi
