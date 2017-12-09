#!/bin/sh
# Copyright (C) 2017 Wesley Tanaka
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
set -x

DIRNAME="`dirname $0`"

"$DIRNAME"/make-curl.sh

if ! command -v rvm 2>&1 > /dev/null; then
  TARGET="`$DIRNAME/realpath.sh $DIRNAME/rvm`"
  if [ ! -x "$TARGET"/bin/rvm ]; then
    GNUPGHOME="$DIRNAME"
    export GNUPGHOME
    # Retry each gpg command because the first one can fail with:
    # gpg: WARNING: options in `/root/.gnupg/gpg.conf' are not yet active
    # during this run
    # gpg: no keyserver known (use option --keyserver)
    # gpg: keyserver receive failed: bad URI
    gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 ||
      gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 ||
      gpg --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 ||
      gpg --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 ||
      "$DIRNAME"/download.sh https://rvm.io/mpapis.asc | gpg2 --import - ||
      "$DIRNAME"/download.sh https://rvm.io/mpapis.asc | gpg --import - ||
      gpg2 --import "$DIRNAME"/409B6B1796C275462A1703113804BB82D39DC0E3.asc ||
      gpg --import "$DIRNAME"/409B6B1796C275462A1703113804BB82D39DC0E3.asc

    gpg2 --recv-keys 7D2BAF1CF37B13E2069D6956105BD0E739499BDB ||
      gpg2 --recv-keys 7D2BAF1CF37B13E2069D6956105BD0E739499BDB ||
      gpg --recv-keys 7D2BAF1CF37B13E2069D6956105BD0E739499BDB ||
      gpg --recv-keys 7D2BAF1CF37B13E2069D6956105BD0E739499BDB ||
      "$DIRNAME"/download.sh https://rvm.io/pkuczynski.asc | gpg2 --import - ||
      "$DIRNAME"/download.sh https://rvm.io/pkuczynski.asc | gpg --import - ||
      gpg2 --import "$DIRNAME"/7D2BAF1CF37B13E2069D6956105BD0E739499BDB.asc ||
      gpg --import "$DIRNAME"/7D2BAF1CF37B13E2069D6956105BD0E739499BDB.asc

    env PYTHONHTTPSVERIFY=0 "$DIRNAME"/download.sh https://get.rvm.io |
      env rvm_path="$TARGET" \
          rvm_user_install_flag=1 \
          bash -s stable
  fi
fi
