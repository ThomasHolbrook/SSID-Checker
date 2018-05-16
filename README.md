# SSID Checker

Simple Swift Command Line Tool to detect, disconnect and remove from Prefered Networks SSID's that dont match the allowed SSID in OSX & macOS. 

Includes an example LaunchD to trigger the tool whenever a WiFi change occurs. 

The latest (and possiably only) release will be avaliable here:

https://github.com/ThomasHolbrook/SSID-Checker/releases

	#Usage:
	SSIDChecker <allowed_ssid> <wait_time>
	
	SSIDChecker checks the current SSID against allowed SSID
	
	wait_time defines the amount of time we wait for WiFi to settle before executing the check

	Where a match is not found the client is disassociated and the SSID removed from Prefered Networks

	#Example - 	SSIDChecker "Tom Tom" 30

	Thomas Holbrook - The software is provided "as is", without warranty of any kind



