A watchdog for the CoreInterop service, to be used as a Scheduled Task

This pair of scripts will try to load https://localhost:9999/Interop/ page. 
If if fails, it will delete the CoreInterop Service, and then reinstall it.

This solution is being tested because there is an error case where the
CoreInterop Service is running, but the URL fails to load.
Simply stopping and starting the service does not correct it,
but reinstalling WIC Direct does. Testing this solution to see if it's 
a quicker, easier band-aid than a complete re-install.

A sample Scheduled Task xml file is included. This will run the task at Log In,
and then will preform the check every minute indefinitely.  

The .ps1 and .bat file must be saved in the directory:  C:\core
