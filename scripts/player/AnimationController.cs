using Godot;
using System;

namespace PlatformerCollab.Player
{
    
    /// Animation controller for the player character
    /// Handles loading and playing animations from the model
    
    public partial class AnimationController : Node
{
    // Node references
    private Node3D _model;
    private AnimationPlayer _animationPlayer;

    // Animation states
    public enum AnimationState
    {
        Idle,
        Walk,
        Run,
        JumpUp,
        JumpDown
    }

    // Current animation state
    private AnimationState _currentState = AnimationState.Idle;

    // Animation names from the GLB file
    private const string ANIM_WALK = "walk";
    private const string ANIM_RUN = "run";
    private const string ANIM_UP = "up";
    private const string ANIM_DOWN = "down";

    // Speed thresholds for determining animation state
    private const float WALK_THRESHOLD = 0.1f;
    private const float RUN_THRESHOLD = 5.0f;

    
    /// Constructor that initializes the controller with required references
    
    public AnimationController(Node3D playerModel)
    {
        _model = playerModel;
    }

    public override void _Ready()
    {
        // The model might not be fully loaded yet, so we need to wait
        if (!_model.IsInsideTree())
        {
            ToSignal(_model, "ready").OnCompleted(OnModelReady);
            return;
        }
        
        OnModelReady();
    }

    private void OnModelReady()
    {
        // Debug the model structure to find animations
        GD.Print("Model structure:");
        PrintNodeTree(_model);
        
        // Find the animation player in the model
        _animationPlayer = FindAnimationPlayer(_model);
        
        if (_animationPlayer != null)
        {
            GD.Print("Animation player found: ", _animationPlayer.Name);
            GD.Print("Available animations: ", string.Join(", ", _animationPlayer.GetAnimationList()));
        }
        else
        {
            GD.PushError("No AnimationPlayer found in the model!");
        }
    }

    
    /// Print the node tree for debugging
    
    private void PrintNodeTree(Node node, string indent = "")
    {
        GD.Print($"{indent}{node.Name} ({node.GetClass()})");
        
        foreach (Node child in node.GetChildren())
        {
            PrintNodeTree(child, indent + "  ");
        }
    }

    
    /// Recursively search for the AnimationPlayer node
    
    private AnimationPlayer FindAnimationPlayer(Node node)
    {
        if (node is AnimationPlayer animPlayer)
        {
            return animPlayer;
        }
        
        foreach (Node child in node.GetChildren())
        {
            AnimationPlayer found = FindAnimationPlayer(child);
            if (found != null)
            {
                return found;
            }
        }
        
        return null;
    }

    
    /// Update the animation based on player state
    
    public void UpdateAnimation(Vector3 velocity, bool isGrounded, bool isJumping)
    {
        if (_animationPlayer == null)
        {
            return;
        }
        
        // Calculate horizontal speed (ignoring vertical movement)
        float horizontalSpeed = new Vector2(velocity.X, velocity.Z).Length();
        
        // Determine the appropriate animation state
        AnimationState newState = _currentState;
        
        if (!isGrounded)
        {
            if (velocity.Y > 0)
            {
                newState = AnimationState.JumpUp;
            }
            else
            {
                newState = AnimationState.JumpDown;
            }
        }
        else if (horizontalSpeed > RUN_THRESHOLD)
        {
            newState = AnimationState.Run;
        }
        else if (horizontalSpeed > WALK_THRESHOLD)
        {
            newState = AnimationState.Walk;
        }
        else
        {
            newState = AnimationState.Idle;
        }
        
        // Only change animation if state has changed
        if (newState != _currentState)
        {
            _currentState = newState;
            PlayAnimationForState(_currentState);
        }
    }

    
    /// Play the appropriate animation for the given state
    
    private void PlayAnimationForState(AnimationState state)
    {
        if (_animationPlayer == null)
        {
            return;
        }
        
        // Get available animations
        string[] availableAnimations = _animationPlayer.GetAnimationList();
        
        // Animation to play
        string animToPlay = "";
        // Whether the animation should loop
        bool shouldLoop = false;
        
        switch (state)
        {
            case AnimationState.Walk:
                animToPlay = Array.Exists(availableAnimations, anim => anim == ANIM_WALK) ? ANIM_WALK : "";
                shouldLoop = true;  // Walk animation should loop
                break;
            case AnimationState.Run:
                animToPlay = Array.Exists(availableAnimations, anim => anim == ANIM_RUN) ? ANIM_RUN : ANIM_WALK;
                shouldLoop = true;  // Run animation should loop
                break;
            case AnimationState.JumpUp:
                animToPlay = Array.Exists(availableAnimations, anim => anim == ANIM_UP) ? ANIM_UP : "";
                shouldLoop = false;  // Jump up is a one-time animation
                break;
            case AnimationState.JumpDown:
                animToPlay = Array.Exists(availableAnimations, anim => anim == ANIM_DOWN) ? ANIM_DOWN : "";
                shouldLoop = false;  // Landing is a one-time animation
                break;
            case AnimationState.Idle:
                // For idle, we'll just stop at the current position or play walk at slow speed
                if (Array.Exists(availableAnimations, anim => anim == ANIM_WALK))
                {
                    _animationPlayer.Play(ANIM_WALK);
                    _animationPlayer.SpeedScale = 0.3f;
                    
                    // Set the idle animation to loop
                    Animation idleAnim = _animationPlayer.GetAnimation(ANIM_WALK);
                    if (idleAnim != null)
                    {
                        idleAnim.LoopMode = Animation.LoopModeEnum.Linear;
                    }
                    return;
                }
                break;
        }
        
        // Only play if we have a valid animation
        if (!string.IsNullOrEmpty(animToPlay))
        {
            _animationPlayer.Play(animToPlay);
            _animationPlayer.SpeedScale = 1.0f;
            
            // Set looping based on animation type
            Animation anim = _animationPlayer.GetAnimation(animToPlay);
            if (anim != null)
            {
                anim.LoopMode = shouldLoop ? Animation.LoopModeEnum.Linear : Animation.LoopModeEnum.None;
            }
            
            GD.Print($"Playing animation: {animToPlay} (Looping: {shouldLoop})");
        }
        else
        {
            // If no animation is available for this state, use a fallback or do nothing
            GD.Print($"No animation available for state: {state}");
        }
    }
}
}