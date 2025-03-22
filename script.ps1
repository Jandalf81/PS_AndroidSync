Using Module ".\modules\AndroidDevice\AndroidDevice.psm1"
Using Module ".\modules\foobar2000\foobar2000.psm1"
Using Module ".\modules\Logger\Logger.psm1"
Using Module ".\modules\Music\Music.psm1"


#region Define Logger
[Logger.Logger]$myLogger = [Logger.Logger]::GetInstance()

[Logger.Target]$fileTarget = [Logger.TextfileTarget]::new()
$fileTarget.MaxLogLevel = [Logger.LogLevel]::DEBUG
$fileTarget.Filepath = ".\script.log"
$myLogger.targets.Add($fileTarget)

[Logger.Target]$stdOutTarget = [Logger.StdoutTarget]::new()
$stdOutTarget.MaxLogLevel = [Logger.LogLevel]::DEBUG
$myLogger.targets.Add($stdOutTarget)
#endregion Define Logger


# import config
$config = Get-Content -Path ".\config.json" | ConvertFrom-Json


$myLogger.info("---------- START")
$myLogger.info("User: $(whoami) @ $(hostname)")


#region Get all Playlists from foobar2000
$myLogger.info("Getting all playlists from foobar2000...")

[foobar2000.App]$myFoobar = [foobar2000.App]::new()
[System.Collections.Generic.List[Music.Playlist]]$playlistsFromFoobar = $myFoobar.getPlaylists()

$myLogger.info("Got $($playlistsFromFoobar.Count) playlists")
#endregion Get all Playlists from foobar2000

#region Filter for playlists to actually sync
$myLogger.info("Filtering for Playlists to actually sync...")

[System.Collections.Generic.List[Music.Playlist]]$myPlaylistsToSync = [System.Collections.Generic.List[Music.Playlist]]::new()

foreach ($playlist in $playlistsFromFoobar) {
    if ($config.playlistsToSync -contains $playlist.DisplayName) {
        $myPlaylistsToSync.Add($playlist)
    }
}

if ($myPlaylistsToSync.Count -eq $config.playlistsToSync.Count) {
    $myLogger.info("Found $($myPlaylistsToSync.Count) of $($config.playlistsToSync.Count) Playlists to sync")
} else {
    $myLogger.warn("Found only $($myPlaylistsToSync.Count) of $($config.playlistsToSync.Count) Playlists to sync")
}
#endregion Filter for playlists to actually sync

#region Combine all playlists to one list to sync
$myLogger.info("Combining playlists...")

[Music.Playlist]$combinedPlaylist = [Music.Playlist]::new()
[int]$allEntries = 0

foreach ($playlist in $myPlaylistsToSync) {
    $combinedPlaylist.ingest($playlist)
    $allEntries += $playlist.Tracks.Count
}

$myLogger.info("Got $($combinedPlaylist.Tracks.Count) unique Tracks from $($myPlaylistsToSync.Count) Playlists with a combined $($allEntries) Tracks")
#endregion Combine all playlists to one list to sync

# iterate through combined playlist, transfer tracks as needed

[AndroidDevice.AndroidDevice]$myAndroid = [AndroidDevice.AndroidDevice]::new()
$myAndroid.Name = 'Pixel 6 Pro'
$myAndroid.MainDir = 'Interner gemeinsamer Speicher\#tmp'

$source = 'F:\Musik\Chiptunes\4mat\Decades (2010)\01 - I hear the Sound of Waves.mp3'
$targetSubDir = 'Chiptunes\4mat\Decades (2010)'
$targetFile= '01 - I hear the Sound of Waves.mp3'

$myAndroid.CopyItemToPath($source, $targetSubDir, $targetFile)