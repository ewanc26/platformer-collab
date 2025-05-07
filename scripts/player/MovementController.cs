using Godot;
using System;

namespace PlatformerCollab.Player
{
    
    /// Handles player movement, jumping and model rotation
    
    public partial class MovementController : Node
{
    // Node references
    private RayCast3D _grounded;
    private Node3D _model;
    private RigidBody3D _parent;

    // Movement parameters
    private float _jumpForce = 500.0f;
    private float _movementForce = 1200.0f;

    // State tracking
    public bool IsJumping { get; private set; } = false;
    private float _jumpCooldown = 0.0f;

    
    /// Constructor that initializes the controller with required references
    
    public MovementController(RigidBody3D playerParent, Node3D playerModel, RayCast3D playerGrounded)
    {
        _parent = playerParent;
        _model = playerModel;
        _grounded = playerGrounded;
    }

    
    /// Apply movement forces based on input and camera direction
    
    public void ApplyMovement(Vector3 input, Vector3 forwardDir, Vector3 rightDir, float delta)
    {
        // Calculate the movement force based on the camera's direction
        Vector3 force = forwardDir * input.Z * _movementForce * delta;
        
        // Add sideways movement perpendicular to the camera's forward direction
        force += rightDir * input.X * _movementForce * delta;
        
        // Apply the calculated force
        _parent.ApplyCentralForce(force);
    }

    
    /// Handle jumping logic
    
    public void HandleJump()
    {
        // Decrease jump cooldown if active
        if (_jumpCooldown > 0)
        {
            _jumpCooldown -= (float)GetProcessDeltaTime();
        }
        
        // Check if player is on ground
        bool onGround = _grounded.IsColliding();
        
        // Reset jumping state when landing
        if (onGround && IsJumping && _jumpCooldown <= 0)
        {
            IsJumping = false;
        }
        
        // Handle jump input
        if (Input.IsActionJustPressed("jump") && onGround)
        {
            _parent.ApplyCentralForce(Vector3.Up * _jumpForce);
            IsJumping = true;
            _jumpCooldown = 0.2f;  // Short cooldown to prevent immediate state change
        }
    }

    
    /// Rotate the model based on movement direction
    
    public void RotateModel(float inputLength, Vector3 forwardDir)
    {
        if (inputLength > 0.1f)
        {
            // Make the model face away from the camera
            Vector3 targetDirection = forwardDir;
            _model.LookAt(_model.GlobalPosition + targetDirection, Vector3.Up);
            // Adjust for the model's initial rotation (-90 degrees on Y axis from the scene file)
            _model.Rotation = new Vector3(_model.Rotation.X, _model.Rotation.Y + Mathf.Pi/2, _model.Rotation.Z);
        }
    }
}
}