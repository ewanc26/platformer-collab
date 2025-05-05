using Godot;
using System;

public partial class Button : TextureButton
{
	[Export]
	public String ButtonText {get; set;} = ":3";
	
	public AudioStreamPlayer ClickSound;
	
	public override void _Ready() {
		GetNode<Label>("Label").Text = ButtonText;
		ClickSound = GetNode<AudioStreamPlayer>("ClickSound");
	}
	
	public void _OnPressed() {
		ClickSound.Play();
	}
}
