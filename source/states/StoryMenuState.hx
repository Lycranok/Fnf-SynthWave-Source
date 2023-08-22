package states;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.group.FlxGroup;
import flixel.graphics.FlxGraphic;
import flixel.addons.display.FlxBackdrop;
import flixel.util.FlxGradient;
import flixel.FlxBasic;

import objects.MenuItem;
import objects.MenuCharacter;

import substates.GameplayChangersSubstate;
import substates.ResetScoreSubState;

class StoryMenuState extends MusicBeatState
{
	public static var weekCompleted:Map<String, Bool> = new Map<String, Bool>();

	var gradientGrp:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	var boxGrp:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();
	var nameGrp:FlxTypedGroup<FlxSprite> = new FlxTypedGroup();

	var gradient:FlxSprite = new FlxSprite(0, 0).makeGraphic(FlxG.width, 1, 0xFFAA00AA);
	var lines:FlxBackdrop;
	var storyText:FlxSprite = new FlxSprite(-80, -15).loadGraphic(Paths.image('storymenu/StoryText/Normal'));

	private static var weekSelected:Int = 0;
	var storyList:Array<String> = ['Alisa', 'Question1', 'Question', 'Lord'];

	var storyListColors:Array<String> = ['Blue', 'Red', 'Red', 'Pink'];

	var weekListColors:Array<Array<FlxColor>> = [[0xff000000, 0xff00d6d6], [0xff000000, 0xffc3113e], [0xff000000, 0xffc3113e], [0xff000000, 0xffd4008d]];

	override function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

		PlayState.isStoryMode = true;

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		add(gradientGrp);

		gradient = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, weekListColors[weekSelected], 1, 90, true);
		gradient.y = FlxG.height - gradient.height;
		gradient.updateHitbox();
		gradient.screenCenter();
		gradientGrp.add(gradient);
		gradient.scale.y = 0.001;
		FlxTween.tween(gradient.scale, {y: 1.4}, 2.2, {ease: FlxEase.circOut});

		lines = new FlxBackdrop(Paths.image('storymenu/Lines'), 0, 0, true, true);
		lines.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		lines.alpha = 0.1;
		add(lines);

		var topShit:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('storymenu/Top Box'));
		topShit.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		add(topShit);

		add(storyText);

		var boxBackgrounds:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('storymenu/Boxes'));
		boxBackgrounds.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		add(boxBackgrounds);

		var lockedBoxes:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('storymenu/Black Boxes'));
		lockedBoxes.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		add(lockedBoxes);

		var questionBox:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('storymenu/Questions'));
		questionBox.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		add(questionBox);

		for(i in 0...storyList.length)
		{
			var name:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('storymenu/Names/' + storyList[i] + '/Colored'));
			name.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
			name.antialiasing = true;
			name.ID = i;
			nameGrp.add(name);

			if(i == 1 || i == 2)
				continue;

			var picture:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('storymenu/Portraits/' + storyList[i] + '/Colored'));
			picture.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
			picture.antialiasing = true;
			picture.ID = i;
			boxGrp.add(picture);
		}
		add(boxGrp);
		add(nameGrp);

		var boxOutlines:FlxSprite = new FlxSprite(-80, -47).loadGraphic(Paths.image('storymenu/Box Outlines'));
		boxOutlines.setGraphicSize(Std.int(FlxG.width), Std.int(FlxG.height));
		add(boxOutlines);

		boxOutlines.antialiasing = questionBox.antialiasing = lockedBoxes.antialiasing = boxBackgrounds.antialiasing = storyText.antialiasing = topShit.antialiasing = lines.antialiasing = gradient.antialiasing = ClientPrefs.data.antialiasing;

		for(members in boxGrp)
			members.antialiasing = true;
		for(members in nameGrp)
			members.antialiasing = true;

		changeStory();

		super.create();
	}

	override function closeSubState() {
		persistentUpdate = true;
		super.closeSubState();
	}

	override function update(elapsed:Float)
	{
		lines.x += 0.4;
		lines.y -= 0.4;
		lines.alpha = 0.1;

		gradient.updateHitbox();
		gradient.y = FlxG.height - gradient.height;

		if(controls.BACK)
			MusicBeatState.switchState(new MainMenuState());
		if(controls.UI_RIGHT_P || controls.UI_LEFT_P)
			changeStory(controls.UI_LEFT_P? -1 : 1);

		super.update(elapsed);
	}

	function changeStory(change:Int = 0)
	{
		var pastColor:Array<FlxColor> = weekListColors[weekSelected];

		weekSelected += change;

		if(weekSelected > storyList.length - 1)
			weekSelected = 0;
		if(weekSelected < 0)
			weekSelected = storyList.length - 1;

		boxGrp.forEach(function(spr:FlxSprite)
		{
			var stat:String = storyList[spr.ID];
			var dependency:String = spr.ID == weekSelected? 'Colored' : 'Grey';
			spr.loadGraphic(Paths.image('storymenu/Portraits/' + stat + '/' + dependency));
			// spr.color = spr.ID == weekSelected? 0xffffffff : 0xff43464B;
		});

		nameGrp.forEach(function(spr:FlxSprite)
		{
			var stat:String = storyList[spr.ID];
			var dependency:String = spr.ID == weekSelected? 'Colored' : 'Normal';
			spr.loadGraphic(Paths.image('storymenu/Names/' + stat + '/' + dependency));
		});

		storyText.loadGraphic(Paths.image('storymenu/StoryText/' + storyListColors[weekSelected]));

		if(change != 0)
			moveGradient(pastColor);
	}

	function moveGradient(oldColor:Array<FlxColor>)
	{
		FlxTween.cancelTweensOf(gradient);
		FlxTween.tween(gradient.scale, {y: 0.001}, 1.2, {ease: FlxEase.circIn, onComplete: function(twn:FlxTween)
		{
			if(gradient.scale.y < 0.05) {
				remove(gradient);
				gradient.kill();
				gradient.destroy();

				gradient = FlxGradient.createGradientFlxSprite(Math.round(FlxG.width), 512, weekListColors[weekSelected] != null? weekListColors[weekSelected] : [0xff000000, 0xffffffff], 1, 90, true);
				gradient.y = FlxG.height - gradient.height;
				gradient.updateHitbox();
				gradient.screenCenter();
				addToBack(gradient);
				gradient.scale.y = 0.001;
				new FlxTimer().start(0.5, function(ok:FlxTimer) {
					FlxTween.tween(gradient.scale, {y: 1.4}, 2.2, {ease: FlxEase.circOut});
				});
			}
		}});
	}

	function addToBack(obj:FlxBasic)
	{
		insert(members.indexOf(gradientGrp), obj);
	}
}
