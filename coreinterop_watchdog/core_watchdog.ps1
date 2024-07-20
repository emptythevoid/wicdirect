

#Start-Transcript -path C:\mylogfile -append

#Invoke-WebRequest -Uri https://localhost:9999/Interop/
#
# Test if the main service is running
try {
    Invoke-WebRequest -UseBasicParsing -Uri https://localhost:9999/Interop/
} catch {
  c:\core\re_register_service.bat}

#Stop-Transcript
