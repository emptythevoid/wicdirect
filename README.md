# Fixes for CDP's WIC Direct CoreInterop

CDP's WIC Direct runs as a local web service at https://localhost:9999

The EBT prodweb page will query this webservice at this link:
 https://localhost:9999/Interop/GetVersionInformation?method=jsonp1718055921049&_=1718055921230

This will return a json that provides basic information, such as the version of CoreInterop that's installed.

This query can fail for several reasons.

1.) If the CoreInterop Windows service isn't running, all requests to localhost:9999 will fail.

2.) If the pinpad isn't attached, https://localhost:9999/Interop/ will return CoreInterop information, but the full GetVersionInformation link will fail

3.) localhost:9999 uses a self-signed cert. The WIC Direct installer generates the CA for this during install and adds it into the Windows Credential store. If this fails, you will get a self-signed security warning and the query will fail.

4.) Even if the CA is loaded into the Certificate store, Firefox will not use this by default, and requires a policies.json file to enable this (or use about:config).  If this happens, localhost:9999 will work in Edge/Chrome, but Firefox will fail. Load https://localhost:9999/Interop/ in Firefox and see if it triggers a self-signed warning.  

The policies.json needs to include this directive:

"Certificates":
{
"ImportEnterpriseRoots": true
}
