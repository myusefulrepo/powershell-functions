# ---------- FUNCTION -------------

Function Get-FileName
# Open file dialog box and select a file to import
{   
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.filter = "Text Files (*.txt)| *.txt" # Set the file types visible to dialog

    # Alternate filters include:
    # "CSV files (*.csv) | *.csv"

    $OpenFileDialog.initialDirectory = "c:\"
    
    $OpenFileDialog.ShowDialog() | Out-Null
    $OpenFileDialog.filename
}

# --------- USAGE ---------------

$filename = Get-FileName
$filecontents = Get-Content $filename

foreach ($line in $filecontents)
....
