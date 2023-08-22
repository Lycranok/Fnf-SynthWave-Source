package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import lime.utils.Assets;
import openfl.utils.Assets as OpenFlAssets;

import objects.HealthIcon;
import states.editors.ChartingState;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

#if MODS_ALLOWED
import sys.FileSystem;
#end

class FreeplayState extends MusicBeatState
{
	private static var curSelected:Int = 0;

	var diff:FlxSprite;
	var songText:FlxSprite;

	var upArrow:FlxSprite;
	var downArrow:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	private static var curDifficulty:Int = -1;

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();
		
		persistentUpdate = true;
		PlayState.isStoryMode = false;
		WeekData.reloadWeekFiles(false);

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		var bg:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Pic Bg'));
		bg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		bg.antialiasing = true;
		add(bg);

		var freeplaybutton:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Button'));
		freeplaybutton.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		freeplaybutton.antialiasing = true;
		add(freeplaybutton);

		var freeplayglow:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Button Glow'));
		freeplayglow.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		freeplayglow.antialiasing = true;
		add(freeplayglow);

		var freeplaytext:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Freeplay Text'));
		freeplaytext.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		freeplaytext.antialiasing = true;
		add(freeplaytext);

		var redbg:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Red bg'));
		redbg.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		redbg.antialiasing = true;
		add(redbg);

		var topglow:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Top Glow'));
		topglow.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		topglow.antialiasing = true;
		add(topglow);

		var botglow:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Bot Glow'));
		botglow.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		botglow.antialiasing = true;
		add(botglow);

		var lines:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/lines'));
		lines.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		lines.antialiasing = true;
		add(lines);

		var outline:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/outline'));
		outline.setGraphicSize(FlxG.width, FlxG.height);
		outline.antialiasing = true;
		add(outline);

		var songblock:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Block'));
		songblock.setGraphicSize(FlxG.width, FlxG.height);
		songblock.antialiasing = true;
		add(songblock);

		var question:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Question'));
		question.setGraphicSize(FlxG.width, FlxG.height);
		question.antialiasing = true;
		add(question);

		songText = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/SongNames/Entropy'));
		songText.setGraphicSize(FlxG.width, FlxG.height);
		songText.antialiasing = true;
		add(songText);

		var diffbox:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Diff Box'));
		diffbox.setGraphicSize(FlxG.width, FlxG.height);
		diffbox.antialiasing = true;
		add(diffbox);

		diff = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Difficulties/Normal'));
		diff.setGraphicSize(FlxG.width, FlxG.height);
		diff.antialiasing = true;
		add(diff);

		upArrow = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Arrows/Arrow Up'));
		upArrow.setGraphicSize(FlxG.width, FlxG.height);
		upArrow.antialiasing = true;
		add(upArrow);

		downArrow = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Arrows/Arrow Down'));
		downArrow.setGraphicSize(FlxG.width, FlxG.height);
		downArrow.antialiasing = true;
		add(downArrow);

		leftArrow = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Arrows/Arrow Left'));
		leftArrow.setGraphicSize(FlxG.width, FlxG.height);
		leftArrow.antialiasing = true;
		add(leftArrow);

		rightArrow = new FlxSprite(-80, -47).loadGraphic(Paths.image('FreeplayMenu/Arrows/Arrow Right'));
		rightArrow.setGraphicSize(FlxG.width, FlxG.height);
		rightArrow.antialiasing = true;
		add(rightArrow);

		rightArrow.antialiasing = leftArrow.antialiasing = downArrow.antialiasing = upArrow.antialiasing = diff.antialiasing = diffbox.antialiasing = songText.antialiasing = question.antialiasing = songblock.antialiasing = outline.antialiasing = lines.antialiasing = botglow.antialiasing = topglow.antialiasing = redbg.antialiasing = freeplayglow.antialiasing = freeplaytext.antialiasing = freeplaybutton.antialiasing = bg.antialiasing = ClientPrefs.data.antialiasing;

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if(controls.BACK)
			MusicBeatState.switchState(new MainMenuState());

		super.update(elapsed);
	}
}