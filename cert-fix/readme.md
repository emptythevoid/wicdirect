Ensure that the software has been installed in this order: 1.) CoreInterop, 2.) Dymo Connect.  (The CoreInterop installer removes the Dymo Connect certificate, so you have to do it in this order for the scheduled task to work)

Place the .ps1 in the C:\cert-fix directory

Add it to Scheduled Task using the .xml template.  Currently it's set to run on any user login, and *not* run on a delay (but this needs to be investigated.)

If using Firefox with ezEMRx:

Add policies.json into the Mozilla distribution folder and restart Firefox (this is so Firefox will use the Windows Credential Store)
