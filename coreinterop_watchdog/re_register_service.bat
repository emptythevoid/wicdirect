echo Executed re-register script %date%>>"C:\core\de-register.log"

sc stop BB.EBT.ServiceHosts.CoreInterop

sc delete BB.EBT.ServiceHosts.CoreInterop

timeout /t 10

sc create "BB.EBT.ServiceHosts.CoreInterop" binpath= "C:\Program Files (x86)\WIC Direct - Core Interop\BB.EBT.ServiceHosts.CoreInterop.exe" DisplayName= "Core Interop" start= auto

sc start BB.EBT.ServiceHosts.CoreInterop

