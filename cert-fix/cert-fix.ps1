# This script works around an issue where WIC Direct's CoreInterop and DYMO Connect both
# expect to have certificates on localhost
# In order for this to work properly, CoreInterop MUST be installed first, and then DYMO Connect.

# Get thumbprint of the DYMO Connect Localhost certificate and store it as variable
$mylocalcert = Get-ChildItem -path Cert:\* -Recurse | where {$_.Subject –like "*localhost"} | Select-Object -ExpandProperty Thumbprint

# Set password for exported certificate
$mypwd = ConvertTo-SecureString -String '12345' -Force -AsPlainText

# Export the currently installed Dymo certificate using password
Get-ChildItem -Path Cert:\LocalMachine\My\$mylocalcert | Export-PfxCertificate -FilePath C:\cert-fix\dymo.pfx -Password $mypwd

# Remove the certificate using the thumbprint found above
Get-ChildItem Cert:\LocalMachine\My\$mylocalcert | Remove-Item

# Restart CoreInterop Service to get it working
Restart-Service -Name "Core Interop"

# Stop the Dymo Connect process
# Use taskkill because by default, the webapi service will run on startup as the user
# we need to make certain we kill any and all instances.
#Stop-Process -Name "DYMO.WebApi.Win.Host"
taskkill /IM "DYMO.WebApi.Win.Host.exe" /F

# Restore the Dymo localhsot certificate.
# This assumes the cert file has been exported to C:\cert-fix\dymo.pfx
# and that it's the most recent Dymo cert and exported out with private key as 12345
Import-PfxCertificate -Password (ConvertTo-SecureString -String "12345" -AsPlainText -Force) -CertStoreLocation Cert:\LocalMachine\My -FilePath C:\cert-fix\dymo.pfx -Exportable

# Start the Dymo Connect WebApi Process
& "C:\Program Files (x86)\DYMO\DYMO Connect\DYMO.WebApi.Win.Host.exe"
