# Player Scripts - C# Conversion

This directory contains the C# versions of the player controller scripts, converted from the original GDScript implementations.

## Overview

The player controller is implemented using a modular approach with several components:

- **PlayerController.cs**: The main controller that coordinates all other components
- **MovementController.cs**: Handles player movement, jumping, and model rotation
- **InputController.cs**: Processes player input for movement and UI interactions
- **CameraController.cs**: Manages camera movement, rotation, and coupling with player movement
- **AnimationController.cs**: Controls character animations based on player state

## Usage

The player scene has been updated to use the C# version of the player controller. The modular design allows for easy extension and modification of individual components.

## Implementation Notes

- The C# implementation follows the same architecture as the original GDScript version
- C# naming conventions have been applied (PascalCase for methods and properties)
- The code has been documented with XML comments for better IDE integration
- A .csproj file has been added to the project root to ensure proper C# support

## Requirements

- Godot 4.0 or later with .NET support enabled
- .NET 6.0 SDK
