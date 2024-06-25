# Fixes for CDP's WIC Direct CoreInterop

CDP's WIC Direct runs as a local web service at https://localhost:9999

The EBT prodweb page will query this webservice at this URL:
 https://localhost:9999/Interop/GetVersionInformation?method=jsonp1718055921049&_=1718055921230

This will return a json that provides basic information, such as the version of CoreInterop that's installed.

If this query fails, the WIC Pinpad will fail to operate.  The quickest way to see this behavior is to go into the EBT Search, try to replace someone's card, and click in the card number field.  If everything is working, the pinpad should say "EBT/ACCT#". If it continues to say "VERIFONE Welcome", the Coreinterop query has failed for some reason.

This query can fail for several reason.  

1.) If the CoreInterop Windows service isn't running, all requests to localhost:9999 will fail.

2.) If the pinpad isn't attached, https://localhost:9999/Interop/ will return CoreInterop information, but the full GetVersionInformation query will fail

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

There are two scripts in-progress to help keep CoreInterops working with the pinpad.  

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

## Case 1
https://localhost:9999/Interop/ is reachable, but the GetVersionInformation query fails and the pinpad does not respond. In this case, the service is running, but is not communicating with the pinpad. Use corefix.bat to reinstall the software.

## Case 2
https://localhost:9999/Interop/ returns a self-signed cert warning and fails. This is most likely to happen in Firefox. Either use a policies.json that includes the "ImportEnterpriseRoots": true  directive, or manually load https://localhost:9999/Interop/ in a tab and allow an exception. (Note, if you're already using a policies.json that clears out profile information on close, such as when using ezEMRx, you need to add the ImportEnterpriseRoots to make the fix permanent)

## Case Other
If cases 1 and 2 are not the problem, something else is preventing communication to the pinpad, such as the pinpad being physically disconnected.

# Notes
It's unclear what causes the pinpad to fail in Case 1.  The Coreinterop service is running, but the service fails to interact with the pinpad until it's reinstalled. This seems to correct the issue, but doesn't solve the underlying problem. Even restarting the service or uninstalling/scan-for-changes the pinpad from device manager does not seem to be sufficient.  The browser is *not* complaining about a self-signed cert. Instead, if complains that the CoreInterop GetVersionInformation isn't reachable. If /Interop/ works but GetVersionInformation fails, this only happens when Coreinterops thinks the pinpad is disconnected.  It would seem something in the software of either the coreinterops service or the pinpad driver stops working as expected. This is interesting, since when reinstalling WIC Direct, the only thing that's getting replaced is the service. The driver does not get replaced unless you manually make it happen.

# Ideas
If we can't figure out why Case 1 occurs, we can do is try to detect it *before* it's a problem for the user.  The check_coreinterop.ps1 script is told to simply restart the service, but this doesn't usually fix Case 1.  We could adjust this to do something else.  If it detects that /Interop/ is working but GetVersionInformation isn't, we could return a notification or something to indicate to the user that the pinpad isn't communicating with Coreinterop and needs to be fixed (CDP's EBT Portal is *supposed* to do this, but it isn't always reliable for Case 1).  Since this script runs in the context of SYSTEM, we could also incorporate the corefix into it so that when /Interop/ works but GetVersionInformation doesn't, we can run corefix to reinstall WIC Direct. *HOWEVER*, this assumes the pinpad is always hooked up. If the pinpad is legitimately detached from the computer, this approach will contstantly be reinstalling WIC Direct.  We would need, then, to have the script check to see if *WINDOWS* shows that the pinpad is hooked up (it appears in the Device Manager as "VX 805 Terminal (COM#)", where COM# is whatever COM port it's using).  To re-state:

If  /Interop/ responds and GetVersionInformation *doesn't* respond

and if Device Manager shows presence of VX 805 (somehow)

display a notice that coreinterop is being repaired and run the corefix script

Close browsers? I don't think this is required, despite CDP saying it is.
