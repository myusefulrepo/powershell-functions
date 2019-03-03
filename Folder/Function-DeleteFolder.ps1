# ----------- FUNCTION ---------------------

Function Delete-Folder($folder)
# Test for and delete folder. Verify folder deletion.
{
    if (Test-Path $folder)
    {
        Remove-Item $folder -force -recurse
        if (Test-Path $folder) { return "Failed to delete folder." }
        else { return "Folder deleted." }
    }
    else { return "Folder not found." }
}

# ----------- USAGE ---------------------

$result = Delete-Folder("c:\test folder")

# Result returned by function - not necessarily required.
