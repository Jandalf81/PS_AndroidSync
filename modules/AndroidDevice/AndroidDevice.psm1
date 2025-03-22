Using Module "..\Logger\Logger.psm1"

[string]$module = "AndroidDevice"

Class AndroidDevice {
    #region Members
    [string]$Name
    [string]$MainDir

    hidden [Logger.Logger]$myLogger
    #endregion Members

    #region Static Members
    #endregion Static Members

    #region Constructors
    AndroidDevice() {
        $this.myLogger = [Logger.Logger]::GetInstance()
    }
    #endregion Constructors

    #region Methods
    [void] CopyItemToPath([string]$SourceItem, [string]$TargetSubDir, [string]$TargetFile) {

        $module = $script:module
        $class = $this.GetType().Name
        $method = (Get-PSCallStack)[0].FunctionName

        $this.myLogger.info($module, $class, $method, "Copying ""$($SourceItem)"" to ""$(Join-Path $this.MainDir $TargetSubDir $TargetFile)""...)")

        $itemToCopy = Get-Item -Path $SourceItem
        $shell = New-Object -ComObject Shell.Application
        $phoneObject = $shell.Namespace(17).self.GetFolder.Items() | Where-Object {$_.name -eq $this.Name}

        # create directory structure if needed
        $currentPath = (Join-Path $phoneObject.Path $this.MainDir)
        $currentDir = $shell.Namespace($currentPath).self.GetFolder

        foreach($part in $TargetSubDir.Split('\')) {
            $nextSubDir = $currentDir.Items() | Where-Object {$_.Name -eq "$($part)"}

            if ($null -eq $nextSubDir) {
                $this.myLogger.debug($module, $class, $method, "Directory ""$($part)"" does not exist, creating it...")

                $currentDir.NewFolder($part)
                #Start-Sleep -Milliseconds 100
            }

            $currentPath = (Join-Path $currentPath $part)
            $currentDir = $shell.Namespace($currentPath).self.GetFolder
        }
        # copy file and wait for it
        $this.myLogger.debug($module, $class, $method, "Begin copy...")
        $currentDir.CopyHere($SourceItem)

        $copiedFile = $null
        do {
            Start-Sleep -Milliseconds 50
            $copiedFile = $null
            $copiedFile = $currentDir.Items() | Where-Object {$_.Name -eq "$($itemToCopy.Name)"}
        } while ($null -eq $copiedFile)

        $this.myLogger.debug($module, $class, $method, "End copy...")
    }
    #endregion Methods

    #region Static Methods
    #endregion Static Methods
}