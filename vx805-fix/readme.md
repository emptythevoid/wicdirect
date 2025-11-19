Experiments into identifying, fixing, or work-around-ing VX805 pinpad issues.

To try to kick-start the pinpads when they're resulting in Invalid Pins (only on Windows 11:

Restart device:

pnputil /restart-device /deviceid "USB\VID_11CA&PID_0220"

Remove/Re-scan

pnputil /remove-device /deviceid "USB\VID_11CA&PID_0220"

pnputil /scan-devices
