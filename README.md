# Fixes for CDP's WIC Direct CoreInterop

CDP's WIC Direct runs as a local web service at https://localhost:9999

The EBT prodweb page will query this webservice at this link:
 https://localhost:9999/Interop/GetVersionInformation?method=jsonp1718055921049&_=1718055921230

This will return a json that provides basic information, such as the version of CoreInterop that's installed.

If this query fails, the WIC Pinpad will fail to operate.  The quickest way to see this behavior is to go into the EBT Search, try to replace someone's card, and click in the card number field.  If everything is working, the pinpad should say "EBT/ACCT#". If it continues to say "VERIFONE Welcome", the Coreinterop query has failed for some reason.

This query can fail for several reason.  

1.) If the CoreInterop Windows service isn't running, all requests to localhost:9999 will fail.

2.) If the pinpad isn't attached, https://localhost:9999/Interop/ will return CoreInterop information, but the full GetVersionInformation link will fail

3.) localhost:9999 uses a self-signed cert. The WIC Direct installer generates the CA for this during install and adds it into the Windows Credential store. If this fails, you will get a self-signed security warning and the query will fail.

4.) Even if the CA is loaded into the Certificate store, Firefox will not use this by default, and requires a policies.json file to enable this (or use about:config).  If this happens, localhost:9999 will work in Edge/Chrome, but Firefox will fail. Load https://localhost:9999/Interop/ in Firefox and see if it triggers a self-signed warning.  

The policies.json needs to include this directive:

```
"Certificates":
{
"ImportEnterpriseRoots": true
}
```

An example "example-policies.json" is available in this repo.

# Fixer scripts

There are two scrips in-progress to help keep CoreInterops working with the pinpad.  

## check_coreinterop.ps1
check_coreinterop.ps1 is a powershell script that's added to Task Scheduler that will constantly test to see if it can load the /Interop/ page.  If it fails, it will restart the CoreInterop service.  To add this as a Scheduled Task:

1. Run as System
2. Run with highest privileges
3. Trigger: on a schedule. Daily. Start time 8:00am. Recur every 1 days. Repeat task every 1 minute (this can be adjusted). For a duration of Indefinitely. Enabled.
4. Actions: start a program. Program/script = powershell   Add arguments: -File "C:\path\to\check_coreinterop.ps1"
5. Conditions. Allow run on demand. Run task as soon as possible after scheduled start missed.

## corefix
Corefix is a batch file that must be run as Administrator. It will remove whichever one version of WIC Direct that's currently installed, download the most current version from CDP, and then silently install it.  This will reinstall the CoreInterop service. You *may* need to restart your web browser for it to take effect, since it reinstalls the self-signed CA into Windows Certificate store.

# What to do, when?
This is still under research.  However, in most cases, one of two issues seems to regularly occur. 

1. https://localhost:9999/Interop/ is reachable, but the GetVersionInformation query fails and the pinpad does not respond. In this case, the service is running, but is not communicating with the pinpad. Use corefix.bat to reinstall the software.
2. https://localhost:9999/Interop/ returns a self-signed cert warning and fails. This is most likely to happen in Firefox. Either use a policies.json that includes the "ImportEnterpriseRoots": true  directive, or manually load https://localhost:9999/Interop/ in a tab and allow an exception. (Note, if you're already using a policies.json that clears out profile information on close, such as when using ezEMRx, you need to add the ImportEnterpriseRoots to make the fix permanent)
3. If cases 1 and 2 are not the problem, something else is preventing communication to the pinpad.
