#!/bin/bash

set -euxo pipefail

dpkg-query --showformat='${Package} (=${Version})\n' --show >> $EPOCHSECONDS
