# Phone Dial Entity for Garry's Mod

This repository contains the scripts for a custom entity in Garry's Mod called "Phone Dial". This entity facilitates interactive communication between players within the game, using custom phone dials and simulated call functionalities.

## Description

The Phone Dial entity is designed to provide a realistic and immersive phone communication experience in Garry's Mod. Players can interact with phone dials to make and receive calls, with full support for networked variables and server-client communication.

### Scripts Overview

- `cl_init.lua`: Client-side initialization script that handles the rendering of phone dials and the client-side user interface for managing calls.
- `init.lua`: Server-side script responsible for setting up the entity, handling interactions, and processing network messages related to phone operations.
- `shared.lua`: Shared script that defines the properties and network variables of the Phone Dial entity.

## Features

- Create and receive simulated phone calls within Garry's Mod between two users. 
- Customizable phone IDs and names using an interactive interface.
- Network communication to synchronize phone states across clients.
- Special audio effects for ringing and dial tones.
- Advanced and Modern UI elements for call management and information display.

## Installation

To install and use the Phone Dial entity in your Garry's Mod server:

1. Clone or download this repository to your local machine.
2. Copy the testent file into your server's `garrysmod/addons/[your_addon_folder]/lua/entities/` directory.
   - Replace `[your_addon_folder]` with the appropriate folder name for your specific addon.
3. Restart your Garry's Mod server or refresh the entities if the server is running.

## Usage

After installation, the Phone Dial entity can be spawned via the entity spawn menu 
Keep in mind this was made for fun and without in depth knowledge of Lua, so it might be buggy if combining with other addons or on large servers

