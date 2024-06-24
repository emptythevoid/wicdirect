# Add this as a scheduled task to run as SYSTEM daily every few minutes.

try {
    Invoke-WebRequest -Method Head -Uri https://localhost:9999/Interop/
}

catch {
    Restart-Service "BB.EBT.ServiceHosts.CoreInterop"
}
