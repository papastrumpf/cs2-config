# CS2 Configuration

## Key Bindings

### Movement & Actions
- `SPACE` - Jump Throw
- `CTRL` - Duck
- `SHIFT` - Clutch Volume Increase (Hold)
- `ALT` - Radar Scale Toggle (Hold)
- `C` - Switch Hands
- `E` - Defuse Zoom (Hold)
- `K` - AFK Movement Toggle
- `MOUSE3` - C4 Drop
- `MOUSE4` - Player Ping
- `MOUSE5` - Voice Record
- `MWHEELUP/DOWN` - Jump

### Weapon & Equipment
- `Q` - Quick Weapon Switch
- `1-5` - Weapon Slots
- `X` - HE Grenade (Default) / Buy HE (Caps Lock Hold)
- `F` - Flashbang (Default) / Buy Flash (Caps Lock Hold)
- `Z` - Smoke (Default) / Buy Smoke (Caps Lock Hold)
- `V` - Molotov (Default) / Buy Molotov (Caps Lock Hold)

### Buy Menu
- `M` - Buy Vest + Deagle
- `,` - Buy Full Loadout (CT)
- `.` - Buy Full Loadout (T)
- `/` - Buy AWP Loadout
##### Caps Lock Hold
- `1` - Buy AK47 or M4A1, Flash, Molotov, HE, Smoke.
- `2` - Buy AK47 or M4A1, Flash x2, Molotov, Smoke.
- `3` - Buy Vest.
- `4` - Buy Vest and Helmet.
- `5` - Buy Defuser.

### Utility
- `TAB` - Network Stats + Scoreboard
- `T` - Toggle Voice Enable/Disable
- `N` - Toggle Crosshair Recoil
- `I` - Infinite Inspect
- `CAPSLOCK` - Hold/Release Toggle Buy/Equip Mode

## Configuration Features

### Performance Optimizations
- Optimized launch parameters for better performance
- Network settings tuned for low latency
- Engine settings configured for smooth gameplay
- Micro-stutter prevention enabled

### Visual Settings
- Custom crosshair configuration
- Optimized viewmodel settings
- Radar customization
- HUD scaling and positioning

### Sound Settings
- Customized sound mixer levels
- Optimized voice settings
- Disabled unnecessary game sounds
- Enhanced footstep audio

### Gameplay Enhancements
- Jump throw script
- Bomb drop script
- AFK prevention
- Clutch volume increase
- Quick weapon switching
- Custom buy scripts
- Enemy team mute toggle

### Network & Performance
- Optimized network rates
- Low latency settings
- Custom interp settings
- Maximum ping limit set to 40

## Installation

1. Locate your CS2 config directory:
   - Windows: `C:\Program Files (x86)\Steam\steamapps\common\Counter-Strike Global Offensive\game\csgo\cfg`
   - Linux: `~/.steam/steam/steamapps/common/Counter-Strike Global Offensive/game/csgo/cfg`

2. Copy `autoexec.cfg` to the config directory

3. Add the following launch options to CS2:
```
-high -fullscreen +r_drawparticles 0 -r_emulate_g -softparticlesdefaultoff -novid -nohltv -nojoy +r_dynamic 0 +cl_forcepreload 1 -limitvsconst +mat_queue_mode 2 +engine_low_latency_sleep_after_client_tick true fps_max 0 +exec autoexec.cfg
```

4. Launch CS2 and verify the config is loaded by checking the console

## Notes
- Created by Papa Strumpf
- Optimized for competitive play
- Includes various quality-of-life improvements
- Customizable through the config file

## Support
For any issues or questions, please open an issue in the repository. 



# Video Settings
- Boost Player Contrast ENABLED
- V-Sync DISABLED
- NVIDIA Reflex ENABLED+BOOST
- FPS In Game 0
- FPS In Menus 200
- MSAA 2X MSAA
- Global Shadow Quality LOW
- Dynamic Shadows ALL
- Model/Texture Detail LOW
- Texture Filtering Mode - BILINEAR
- Shader Detail LOW
- Particle Detail LOW
- Ambient Occlusion DISABLED
- High Dynamic Range QUALITY
- FidelityFX Super Resolution DISABLED (HIGHEST QUALITY)

# Troubleshoot
- If config acts weird load it in the main menu, then once again in the game. From then it should work as expected.