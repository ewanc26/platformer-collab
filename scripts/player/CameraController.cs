using Godot;
using System;

namespace PlatformerCollab.Player
{
    
    /// Handles camera movement, rotation and coupling with player movement
    
    public partial class CameraController : Node
{
    // Camera parameters
    private float _cameraDistance = 2.5f;
    private float _cameraHeight = 1.0f;
    private float _mouseSensitivity = 0.001f;

    // Camera state variables
    private bool _isCameraCoupled = false;
    private float _lastMovementTime = 0.0f;
    private float _cameraDecouplingDelay = 0.5f;  // Time in seconds before decoupling after stopping

    // Input variables
    private float _twistInput = 0.0f;
    private float _pitchInput = 0.0f;

    // Node references
    private Node3D _twistPivot;
    private Node3D _pitchPivot;
    private Camera3D _camera;
    private Node3D _model;

    
    /// Constructor that initializes the controller with required references
    
    public CameraController(Node3D playerTwistPivot, Node3D playerPitchPivot, Camera3D playerCamera, Node3D playerModel)
    {
        _twistPivot = playerTwistPivot;
        _pitchPivot = playerPitchPivot;
        _camera = playerCamera;
        _model = playerModel;
        
        // Set initial camera position
        _camera.Position = new Vector3(0, _cameraHeight, _cameraDistance);
        // Start with decoupled camera
        _isCameraCoupled = false;
    }

    
    /// Handle camera coupling based on movement
    
    public void HandleCameraCoupling(float inputLength)
    {
        if (inputLength > 0.1f)
        {
            // Player is moving, reset timer and ensure camera is coupled
            _lastMovementTime = Time.GetTicksMsec() / 1000.0f;
            
            if (!_isCameraCoupled)
            {
                // Player started moving, couple the camera
                _isCameraCoupled = true;
                
                // Store current camera global transform before coupling
                Transform3D cameraGlobalTransform = _twistPivot.GlobalTransform;
                
                // Align twist pivot with model direction
                _twistPivot.GlobalTransform = new Transform3D(_model.GlobalTransform.Basis, _twistPivot.GlobalTransform.Origin);
                
                // We need to preserve the camera's pitch while updating its yaw
                float currentPitch = _pitchPivot.Rotation.X;
                _pitchPivot.Rotation = new Vector3(currentPitch, _pitchPivot.Rotation.Y, _pitchPivot.Rotation.Z);
            }
        }
        else
        {
            // Player not moving, check if we should decouple
            float currentTime = Time.GetTicksMsec() / 1000.0f;
            if (_isCameraCoupled && (currentTime - _lastMovementTime) > _cameraDecouplingDelay)
            {
                _isCameraCoupled = false;
            }
        }
    }

    
    /// Update camera rotation based on mouse input
    
    public void UpdateCameraRotation()
    {
        _twistPivot.RotateY(_twistInput);
        _pitchPivot.RotateX(_pitchInput);
        _pitchPivot.Rotation = new Vector3(
            Mathf.Clamp(_pitchPivot.Rotation.X, Mathf.DegToRad(-30), Mathf.DegToRad(30)),
            _pitchPivot.Rotation.Y,
            _pitchPivot.Rotation.Z
        );
        
        // Reset inputs
        _twistInput = 0.0f;
        _pitchInput = 0.0f;
    }

    
    /// Handle mouse input for camera control
    
    public void HandleMouseInput(InputEvent @event)
    {
        if (@event is InputEventMouseMotion mouseMotion)
        {
            if (Input.MouseMode == Input.MouseModeEnum.Captured)
            {
                _twistInput = -mouseMotion.Relative.X * _mouseSensitivity;
                _pitchInput = -mouseMotion.Relative.Y * _mouseSensitivity;
            }
        }
    }

    
    /// Get camera forward direction for movement
    
    public Vector3 GetForwardDirection()
    {
        return _twistPivot.Basis.Z.Normalized();
    }

    
    /// Get camera right direction for movement
    
    public Vector3 GetRightDirection()
    {
        return _twistPivot.Basis.X.Normalized();
    }
}
}