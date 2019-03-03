# Source : http://noahcoad.com/post/66/powershell-startup-auto-load-scripts
# Google Searching tools for PowerShell, by Noah Coad 5/18/09
# Google is now a verb, http://dictionary.reference.com/browse/google

# use the OS system shell process to execute, useful for URL handlers and other registered system file types
Function Start-SystemProcess {[System.Diagnostics.Process]::Start("" + $args + $input)}

# common types of Google searches
Function Google-Search {Start-SystemProcess ("http://www.google.com/search?hl=en&q=" + $args + $input)}
Function Google-Image {Start-SystemProcess ("http://images.google.com/images?sa=N&tab=wi&q=" + $args + $input)}
Function Google-Video {Start-SystemProcess ("http://video.google.com/videosearch?q=" + $args + $input)}
Function Google-News {Start-SystemProcess ("http://news.google.com/news?ned=us&hl=en&ned=us&q=" + $args + $input)}

# common things or domains to search Google for
Function Google-PowerShell {Google-Search ("PowerShell " + $args + $input)}
Function Google-MSDN {Google-Search ("site:msdn.microsoft.com " + $args + $input)}

Set-Alias Open-Url Start-SystemProcess

# shortcuts for googling
Set-Alias google     Google-Search
Set-Alias ggit       Google-Search     # go google it
Set-Alias gimg       Google-Image
Set-Alias gnews      Google-News
Set-Alias gvid       Google-Video
Set-Alias gpshell    Google-PowerShell
Set-Alias gmsdn      Google-MSDN
