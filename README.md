# Obstacle Course Game

An obstacle course made on the Roblox game platform. 

## Features
- Persistent player progress data saving which includes saving retries, safeguards against duplicate saving, and forceful saving in case of game session shutdowns. This uses Roblox's own database system.

## Demo

## Project Structure

```
.
├── Main.legacy.luau  
│         
├── server-modules/
│   └── .gitignore
│   └── BADGES.luau
│   └── CollisionGrouping.luau
│   └── CustomNameTags.luau
│   └── DataStoring.luau
│   └── DevProductPurchases.luau
│   └── ServerComponents.luau
│   └── Spawning.luau
│   └── StageShifting.luau
│
├── Main.local.luau
│
├── client-modules/
│   └── ChatCustomization.luau
│   └── ClientComponents.luau
│   └── GameSounds.luau
│   └── UserInterfaceLogic.luau
│   └── VisualEffects.luau
│
├── .gitignore
└── README.md

```

## Design Notes
- The game logic is split using server-client architecture. Things like stage shifting and in-game purchases are requested from the client to the server. Local client behaviors such as the UI animations are handled by the client scripts. The server scripts grant permissions to client requests, as well as handle universal game behavior such as data saving and moving platforms. 

- All scripts focus on a single functionality, and they are called by their corresponding, main script. On the server side, Data Saving is called by...

## Notes
- This repo only includes my game scripts. It does not store in-game assets. 