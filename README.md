# Roblox Material Pickup Script

A simple server-side Lua script for Roblox that handles material pickup,
inventory limits, and bag scaling.

This script is designed as a **drop-in ServerScript** and was extracted
from a personal Roblox game project.

## Features
- Touch-based material collection
- Server-side inventory handling
- Dynamic inventory limits using BagLevel
- Attribute-based configuration
- Supports BasePart and Model pickups

## Setup
1. Place the script inside `ServerScriptService`
2. Parent the script to a material BasePart or Model
3. Add `MaterialValue` as an Attribute or IntValue
4. Ensure player has leaderstats:
   - `Materials`
   - `BagLevel`
