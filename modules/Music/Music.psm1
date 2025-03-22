Using Module "..\Logger\Logger.psm1"

[string]$module = "Music"

Class Playlist {
    #region Members
    [string]$FilePath
    [string]$DisplayName
    [System.Collections.Generic.List[Track]]$Tracks

    hidden [Logger.Logger]$myLogger
    #endregion Members

    #region Static Members
    #endregion Static Members

    #region Constructors
    Playlist() {
        $this.Tracks = [System.Collections.Generic.List[Track]]::new()

        $this.myLogger = [Logger.Logger]::GetInstance()
    }
    #endregion Constructors

    #region Methods
    [void] ingest([Playlist]$other) {
        foreach($track in $other.Tracks) {
            if ($this.Tracks.FilePath -notcontains $track.FilePath) {
                $this.Tracks.Add($track)
            }
        }
    }
    #endregion Methods

    #region Static Methods
    #endregion Static Methods
}

Class Track {
    #region Members
    [string]$FilePath

    hidden [Logger.Logger]$myLogger   
    #endregion Members

    #region Static Members
    #endregion Static Members

    #region Constructors
    Track() {
        $this.myLogger = [Logger.Logger]::GetInstance()
    }
    #endregion Constructors

    #region Methods
    #endregion Methods

    #region Static Methods
    #endregion Static Methods
}