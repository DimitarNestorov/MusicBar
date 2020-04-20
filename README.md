# MusicBar

[![GitHub license](https://img.shields.io/badge/license-EUPL-blue.svg)](https://raw.githubusercontent.com/dimitarnestorov/MusicBar/master/LICENSE)

## Player Support

Every player that supports the Now Playing Today widget is supported. If the player doesn't support album artwork in the widget (shows the player icon) then MusicBar doesn't support it either (with some exceptions).

|Player|Controls|Artist|Title|Album|Album Art|
|-|-|-|-|-|-|
|iTunes / Music|✅|✅|✅|✅|✅|
|Spotify|✅|✅|✅|✅|✅<sup>\[1\]</sup>|
|TIDAL|✅|✅|✅|✅|❌<sup>\[2\]</sup>|
|Deezer|❌|❌|❌|❌|❌|
|Qobuz|❌|❌|❌|❌|❌|
|[Google Play Music Desktop Player](https://www.googleplaymusicdesktopplayer.com/)|✅|✅|✅|✅|❌<sup>\[2\]</sup>|
|[Auryo](https://auryo.com/)|✅|✅|✅|✅|❌<sup>\[3\]</sup>|
|Google Chrome<sup>\[4\]</sup>|✅|✅|✅|✅|❌|
|IINA|✅|✅|✅|✅|❌|
|QuickTime Player|✅|✅|✅|✅|❌|
|VOX<sup>\[2\]</sup>|❌|❌|❌|❌|❌|
|VLC<sup>\[2\]</sup>|❌|❌|❌|❌|❌|

1. Support was implemented as a part of MusicBar (it may stop working)
1. Working on a solution
1. Waiting for https://github.com/auryo/electron-media-service/pull/1 to be merged
1. Requires media keys to be enabled

## License

Licensed under the [European Union Public Licence (EUPL) 🔗](https://choosealicense.com/licenses/eupl-1.2/#). [Translations 🔗](https://joinup.ec.europa.eu/collection/eupl/eupl-text-eupl-12).

Copyright © 2020 Dimitar Nestorov
