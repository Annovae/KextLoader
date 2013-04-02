#!/bin/sh

#  SetKextPermissions.sh
#  KextLoader
#
#  Created by 안 승례 on 13. 4. 2..
#  Copyright (c) 2013년 안 승례. All rights reserved.

KEXTPATH=$1

cd /tmp
/usr/sbin/chown -R root:wheel ${KEXTPATH}
find ${KEXTPATH} -type d -exec /bin/chmod 0755 {} \;
find ${KEXTPATH} -type f -exec /bin/chmod 0644 {} \;