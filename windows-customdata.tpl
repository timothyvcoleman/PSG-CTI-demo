$authContent = @"
machine unimrcp.org
 login      ${UNIMRCP_USERNAME}
 password   ${UNIMRCP_PASSWORD}
"@

Set-Content -Path "/etc/apt/auth.conf.d/unimrcp.conf" -Value $authContent -Force

$repoContent = "deb [arch=amd64] https://unimrcp.org/repo/apt/ focal main asterisk-16"

Set-Content -Path "/etc/apt/sources.list.d/unimrcp.list" -Value $repoContent -Force