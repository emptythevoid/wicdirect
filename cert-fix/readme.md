Place the .ps1 in the C:\cert-fix directory

Add it to Scheduled Task using the .xml template.  Currently it's set to run on any user login, and *not* run on a delay (but this needs to be investigated.)

Add policies.json into the Mozilla distribution folder and restart Firefox (this is so Firefox will use the Windows Credential Store)
