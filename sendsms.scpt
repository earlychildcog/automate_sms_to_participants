on run {phoneNumber, messageToSend}
    tell application "Messages"
        set iMessageService to (1st account whose service type = SMS)
        set smsService to (1st account whose service type = iMessage)
        set theBuddy to participant phoneNumber of iMessageService
        
        try
            send messageToSend to theBuddy
        on error
            set theBuddy to participant phoneNumber of smsService
            send messageToSend to theBuddy
        end try
    end tell
end run
