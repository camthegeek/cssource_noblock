# NoBlock Plugin for Counter-Strike: Source

A SourceMod plugin that allows players to pass through each other and optionally disables collision for grenades.

## Features

- Removes player collision (players can walk through each other)
- Optional grenade collision removal (grenades pass through players)
- Dynamic control through ConVars
- No commands needed - works automatically

## Installation

1. Make sure you have SourceMod installed on your CS:S server
2. Download the plugin files
3. Upload `camsNoBlock.smx` to your `css/addons/sourcemod/plugins/` directory
4. Restart your server or load the plugin using `sm plugins load camsNoBlock`

## Configuration

The following ConVars can be added to your `server.cfg` or changed in-game:

```
// Enable/disable player collision removal (Default: 1)
sm_noblock "1"

// Enable/disable grenade collision removal (Default: 1)
sm_noblock_nades "1"
```

### ConVar Details

- `sm_noblock`
  - 1 = Players can walk through each other
  - 0 = Normal player collision

- `sm_noblock_nades`
  - 1 = Nades pass through players
  - 0 = Normal grenade collision

## Requirements

- SourceMod 1.12 or higher
- Counter-Strike: Source dedicated server

## Notes

- Changes to ConVars take effect immediately
- Plugin automatically hooks into new players joining the server
- Works with all types of grenades (HE, Flash, Smoke)

## Support

For issues or feature requests, please create an issue on the GitHub repository.
