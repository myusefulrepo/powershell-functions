# ------ FUNCTION --------------

Function Set-Filename
# Set file name for saving export
{
    [void][System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")
    $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog
    $SaveFileDialog.Filter = "Text files (*.txt)|*.txt"
   
    $SaveFileDialog.initialDirectory = "c:\"
    
    if ($SaveFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK)
    { $SaveFileDialog.FileName }
}

# ------ USAGE -------

$filename = Set-FileName

"some output text" | out-file $filename - append
