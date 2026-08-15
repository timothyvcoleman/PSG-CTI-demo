#!/bin/bash

sudo tee /etc/apt/auth.conf.d/unimrcp.conf > /dev/null <<EOF
machine unimrcp.org
 login      ${UNIMRCP_USERNAME}
 password   ${UNIMRCP_PASSWORD}
EOF

echo "deb [arch=amd64] https://unimrcp.org/repo/apt/ focal main asterisk-16" | sudo tee /etc/apt/sources.list.d/unimrcp.list > /dev/null