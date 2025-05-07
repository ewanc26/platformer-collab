using Godot;
using System;
using PlatformerCollab.Player;


/// Main player controller that coordinates all player components

public partial class PlayerController : RigidBody3D
{
    // Modular components
    private CameraController _cameraController;
    private MovementController _movementController;
    private InputController _inputController;
    private AnimationController _animationController;

    // Node references
    private Node3D _twistPivot;
    private Node3D _pitchPivot;
    private Camera3D _camera;
    private Node3D _model;
    private RayCast3D _grounded;

    public override void _Ready()
    {
        // Get node references
        _twistPivot = GetNode<Node3D>("TwistPivot");
        _pitchPivot = GetNode<Node3D>("TwistPivot/PitchPivot");
        _camera = GetNode<Camera3D>("TwistPivot/PitchPivot/Camera3D");
        _model = GetNode<Node3D>("Model");
        _grounded = GetNode<RayCast3D>("Grounded");

        // Initialize input controller
        _inputController = new InputController();
        AddChild(_inputController);

        // Initialize camera controller with required node references
        _cameraController = new CameraController(_twistPivot, _pitchPivot, _camera, _model);
        AddChild(_cameraController);

        // Initialize movement controller with required node references
        _movementController = new MovementController(this, _model, _grounded);
        AddChild(_movementController);

        // Initialize animation controller with required node references
        _animationController = new AnimationController(_model);
        AddChild(_animationController);

        // Set initial mouse mode
        Input.MouseMode = Input.MouseModeEnum.Captured;
    }

    public override void _Process(double delta)
    {
        // Get movement input
        Vector3 input = _inputController.GetMovementInput();

        // Handle camera coupling based on movement
        _cameraController.HandleCameraCoupling(input.Length());

        // Get camera directions for movement
        Vector3 forwardDir = _cameraController.GetForwardDirection();
        Vector3 rightDir = _cameraController.GetRightDirection();

        // Apply movement forces
        _movementController.ApplyMovement(input, forwardDir, rightDir, (float)delta);

        // Handle jumping
        _movementController.HandleJump();

        // Rotate model based on movement
        _movementController.RotateModel(input.Length(), forwardDir);

        // Update animation based on current state
        _animationController.UpdateAnimation(
            LinearVelocity,
            _grounded.IsColliding(),
            _movementController.IsJumping
        );

        // Handle UI input (like ESC key)
        _inputController.HandleUiInput();

        // Update camera rotation based on mouse input
        _cameraController.UpdateCameraRotation();
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        // Pass mouse input to camera controller
        _cameraController.HandleMouseInput(@event);
    }
}