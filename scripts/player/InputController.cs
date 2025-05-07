using Godot;
using System;

namespace PlatformerCollab.Player
{
    
    /// Handles player input for movement and UI interactions
    
    public partial class InputController : Node
{
    
    /// Process movement input and return a normalized vector
    
    public Vector3 GetMovementInput()
    {
        Vector3 input = Vector3.Zero;
        
        input.X = Input.GetAxis("move_left", "move_right");
        input.Z = Input.GetAxis("move_forward", "move_backwards");
        
        return input;
    }

    
    /// Handle UI input like ESC key
    
    public void HandleUiInput()
    {
        if (Input.IsActionJustPressed("ui_cancel"))
        {
            Input.MouseMode = Input.MouseModeEnum.Visible;
        }
    }
    }
}