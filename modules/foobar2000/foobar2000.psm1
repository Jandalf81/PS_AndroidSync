Using Module "..\Logger\Logger.psm1"
Using Module "..\Music\Music.psm1"

[string]$module = "foobar2000"

Class App {
    #region Members
    [string]$ProfilePath

    hidden [Logger.Logger]$myLogger   
    #endregion Members

    #region Static Members
    #endregion Static Members

    #region Constructors
    App() {
        $this.ProfilePath = "$([Environment]::GetFolderPath([Environment+SpecialFolder]::ApplicationData))\foobar2000-v2"

        $this.myLogger = [Logger.Logger]::GetInstance()
    }
    #endregion Constructors

    #region Methods
    [System.Collections.Generic.List[Music.Playlist]] getPlaylists() {
        [System.Collections.Generic.List[Music.Playlist]]$retObj = [System.Collections.Generic.List[Music.Playlist]]::new()

        $module = $script:module
        $class = $this.GetType().Name
        $method = (Get-PSCallStack)[0].FunctionName

        $this.myLogger.info($module, $class, $method, "Refreshing Playlists...")

        [string]$playlistsIndex = "$($this.ProfilePath)\playlists-v2.0\index.txt"
        
        $playlistsIndexContent = Get-Content -Path $playlistsIndex
        $this.myLogger.debug($module, $class, $method, "Got $($playlistsIndexContent.Count) playlists")

        $this.myLogger.debug($module, $class, $method, "Reading Tracks for playlist...")
        foreach ($line in $playlistsIndexContent) {
            $splitter = $line.IndexOf(":")
            
            [Music.Playlist]$myPlaylist = [Music.Playlist]::new()
            $myPlaylist.FilePath = "$($this.ProfilePath)\playlists-v2.0\playlist-$($line.Substring(0, $splitter)).fplite"
            $myPlaylist.DisplayName = $line.Substring($splitter + 1)
            $this.myLogger.debug($module, $class, $method, "Playlist: $($myPlaylist.DisplayName)")

            $playlistContent = Get-Content -Path $myPlaylist.FilePath
            foreach ($line in $playlistContent) {            
                [Music.Track]$myTrack = [Music.Track]::new()
                $myTrack.FilePath = $line.Replace("file://", "")

                $myPlaylist.Tracks.Add($myTrack)
            }
            $this.myLogger.debug($module, $class, $method, "Tracks read: $($myPlaylist.Tracks.Count)")

            $retObj.Add($myPlaylist)
        }

        return $retObj
    }
    #endregion Methods

    #region Static Methods
    #endregion Static Methods
}