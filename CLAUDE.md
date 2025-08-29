# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a CS2 (Counter-Strike 2) configuration repository that contains customized game settings optimized for competitive play. The configuration includes custom keybinds, performance optimizations, buy scripts, and movement mechanics enhancements.

## Key Files and Structure

- **`autoexec.cfg`**: Main configuration file that contains all customizations including keybinds, buy scripts, network settings, and performance optimizations
- **`movement/`**: Directory containing advanced movement configuration files
  - `setup.cfg`: Main movement config with jump aliases and binds
  - `setup_async.cfg`: Asynchronous execution component
  - `tick0.cfg` through `tick10.cfg`: Frame-perfect timing configurations
  - `final.cfg`: Final movement settings

## Configuration System Architecture

### Script System
The configuration uses Source Engine's alias system to create complex multi-action binds:
- **Toggle aliases**: Switch between states (e.g., `mute-enemy-team_on/off`)
- **Hold/Release actions**: Different behavior on key press/release (e.g., `+incvol/-incvol`)
- **Mode switching**: CAPSLOCK acts as a modifier key to switch between equipment and buy modes
- **Chained actions**: Multiple commands executed in sequence

### Movement System
The movement configuration implements advanced techniques:
- Frame-perfect jump timing using `exec_async` and tick-based configs
- Multiple jump types: normal jump, jump-bind, longjump with various directions
- Movement key cancellation system for precise control
- Requires `sv_cheats 1` for the async execution system

## Common Development Tasks

When modifying configurations:

1. **Testing Changes**: 
   - Make changes to the relevant `.cfg` file
   - In CS2 console: `exec autoexec` to reload configuration
   - For movement changes: Re-execute `exec movement/setup` in lobby

2. **Adding New Binds**:
   - Add bind commands to `autoexec.cfg`
   - Use alias system for complex multi-action binds
   - Follow existing patterns for toggle/hold actions

3. **Modifying Buy Scripts**:
   - Buy binds are organized with CAPSLOCK as modifier
   - Primary buy scripts use `,` (CT) and `.` (T) keys
   - Individual grenade buys use X, F, Z, V keys

## Important Implementation Notes

- The configuration requires specific launch parameters to function properly
- Movement config uses `sv_cheats 1` which only works in private servers/lobbies
- Network settings are optimized for low ping (max 40ms) competitive play
- Some features like the AFK movement script use toggle mechanics that persist until manually disabled
- The configuration modifies console activation and developer mode settings

## Configuration Dependencies

- CS2 must be launched with the specified launch parameters for full functionality
- Movement system requires re-execution after ~6 hours due to engine limitations
- Some settings may need adjustment based on individual hardware (e.g., sensitivity at 1600 DPI)