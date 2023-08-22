package states;

import backend.WeekData;
import backend.Achievements;

import flixel.FlxObject;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;

import flixel.input.keyboard.FlxKey;
import lime.app.Application;

import objects.AchievementPopup;
import states.editors.MasterEditorMenu;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public static var psychEngineVersion:String = '0.7.1h'; //This is also used for Discord RPC
	public static var curSelected:Int = 0;

	private var camGame:FlxCamera;

	var buttons:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var buttonFG:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();
	var specialLogo:FlxTypedGroup<FlxSprite> = new FlxTypedGroup<FlxSprite>();

	var arrow:FlxSprite;

	var optionsList:Array<String> = [
		'Story',
		'Freeplay',
		'Options',
		'Discord',
		'Extras'
	];

	var mapScale:Array<Array<Float>> = [];
	var logoScale:Array<Array<Float>> = [];

	override function create()
	{
		#if MODS_ALLOWED
		Mods.pushGlobalMods();
		#end
		Mods.loadTopMod();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		camGame = new FlxCamera();

		FlxG.cameras.reset(camGame);
		FlxG.cameras.setDefaultDrawTarget(camGame, true);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		persistentUpdate = persistentDraw = true;

		var blackBG:FlxSprite = new FlxSprite(-80, -40).loadGraphic(Paths.image('MainMenu/Black BG'));
		blackBG.setGraphicSize(FlxG.width, FlxG.height);
		add(blackBG);

		for(i in 0...2)
		{
			var fileList:Array<String> = ['Top Glow', 'Bot Glow'];
		
			var rgb:FlxSprite = new FlxSprite(i == 0? -125 : -80, i == 0? 45 : -40).loadGraphic(Paths.image('MainMenu/' + fileList[i]));
			rgb.antialiasing = true;
			add(rgb);
		} 

		// FlxG.camera.zoom = 0.5;

		var uiArt:FlxSprite = new FlxSprite(-70, -600).loadGraphic(Paths.image('MainMenu/Arts/1'));
		uiArt.scale.set(0.34, 0.34);
		add(uiArt);

		var outline:FlxSprite = new FlxSprite(-80, -40).loadGraphic(Paths.image('MainMenu/Outline'));
		outline.setGraphicSize(FlxG.width, FlxG.height);
		add(outline);

		var topBlack:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 10, 0xff000000);
		add(topBlack);

		var logoBox:FlxSprite = new FlxSprite(-80, -40).loadGraphic(Paths.image('MainMenu/Synth Box'));
		logoBox.setGraphicSize(FlxG.width, FlxG.height);
		add(logoBox);

		var logo:FlxSprite = new FlxSprite(-80, -40).loadGraphic(Paths.image('MainMenu/Synth Text'));
		logo.setGraphicSize(FlxG.width, FlxG.height);
		add(logo);

		var blueBG:FlxSprite = new FlxSprite(-80, -40).loadGraphic(Paths.image('MainMenu/Blue bg', 'preload'));
		blueBG.setGraphicSize(FlxG.width, FlxG.height);
		add(blueBG);

		var blueBGGlow:FlxSprite = new FlxSprite(-80, -40).loadGraphic(Paths.image('MainMenu/Blue glow'));
		blueBGGlow.setGraphicSize(FlxG.width, FlxG.height);
		add(blueBGGlow);

		var blueBGlines:FlxSprite = new FlxSprite(-80, -40).loadGraphic(Paths.image('MainMenu/Lines'));
		blueBGlines.setGraphicSize(FlxG.width, FlxG.height);
		add(blueBGlines);

		add(buttons);
		add(buttonFG);
		add(specialLogo);

		for(i in 0...optionsList.length)
		{
			var buttonBG:FlxSprite = new FlxSprite(0 - (i * 170), -20 + (i * 135)).loadGraphic(Paths.image('MainMenu/Box'));
			buttonBG.scale.x -= i * 0.2;
			buttonBG.scale.y -= i * 0.2;
			buttonBG.ID = i;
			buttons.add(buttonBG);

			var buttonShit:FlxSprite = new FlxSprite(190 - (i * 105), 190 + (i * 165)).loadGraphic(Paths.image(optionsList[i] == 'Discord'? 'MainMenu/Options/Discord text' : optionsList[i] == 'Extras'? 'MainMenu/Options/Extra' : 'MainMenu/Options/' + optionsList[i]));
			buttonShit.ID = i;
			switch(buttonShit.ID)
			{
				case 0, 2:
					buttonShit.scale.set(1, 1);
				case 1:
					buttonShit.scale.set(0.95, 0.95);
				case 3:
					buttonShit.scale.set(0.7, 0.7);
					buttonShit.offset.set(-25);
				case 4:
					buttonShit.scale.set(0.95, 0.95);
					buttonShit.offset.set(0, 5);
			}

			if(optionsList[i] == 'Discord')
			{
				var discord:FlxSprite = new FlxSprite(190 - (i * 105), 190 + (i * 165)).loadGraphic(Paths.image('MainMenu/Options/Discord Logo'));
				discord.ID = i;
				discord.scale.set(0.17, 0.17);
				discord.offset.set(-120, 650);
				specialLogo.add(discord);

				logoScale.push([discord.scale.x, discord.scale.y]);
			}
			buttonFG.add(buttonShit);

			//dumb push to use for math later on lmao
			mapScale.push([buttonShit.scale.x, buttonShit.scale.y]);
		}

		arrow = new FlxSprite(-80, -40).loadGraphic(Paths.image('MainMenu/Arrow'));
		arrow.setGraphicSize(FlxG.width, FlxG.height);
		add(arrow);

		arrow.antialiasing = blueBGlines.antialiasing = blueBGGlow.antialiasing = blueBG.antialiasing = logo.antialiasing = logoBox.antialiasing = topBlack.antialiasing = outline.antialiasing = uiArt.antialiasing = blackBG.antialiasing = ClientPrefs.data.antialiasing;

		for(members in buttons)
			members.antialiasing = ClientPrefs.data.antialiasing;
		for(members in buttonFG)
			members.antialiasing = ClientPrefs.data.antialiasing;
		for(members in specialLogo)
			members.antialiasing = ClientPrefs.data.antialiasing;

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * elapsed;
			// if(FreeplayState.vocals != null) FreeplayState.vocals.volume += 0.5 * elapsed;
		}

		if (!selectedSomethin)
		{
			if(controls.UI_UP_P || controls.UI_DOWN_P)
				changeItem(controls.UI_UP_P? curSelected == 0? 0: -1 : curSelected == optionsList.length - 1? 0 : 1);
			if(controls.BACK)
				MusicBeatState.switchState(new TitleState());
			if(controls.ACCEPT)
			{
				var daChoice:String = optionsList[curSelected].toLowerCase();

				if(daChoice == 'discord')
				{
					CoolUtil.browserLoad("https://discord.gg/rE9nWqHP");
				}
				else
				{
					selectedSomethin = true;

					switch(daChoice)
					{
						case 'story':
							MusicBeatState.switchState(new StoryMenuState());
						case 'freeplay':
							MusicBeatState.switchState(new FreeplayState());
						case 'options':
							LoadingState.loadAndSwitchState(new OptionsState());
						case 'extras':
							MusicBeatState.resetState();
					}
				}
			}

			#if desktop
			if (controls.justPressed('debug_1'))
			{
				selectedSomethin = true;
				MusicBeatState.switchState(new MasterEditorMenu());
			}
			#end

		}

		arrow.visible = curSelected == optionsList.length - 1? false : true;

		super.update(elapsed);
	}

	function changeItem(huh:Int = 0)
	{
		curSelected += huh;

		buttons.forEach(function(spr:FlxSprite)
		{
			var value:Int = 0;
			
			switch(curSelected)
			{
				case 0:
					if(spr.ID >= curSelected && spr.ID < curSelected + 3)
						value = 1;
					else value = 0;
				default:
					if(spr.ID >= curSelected && spr.ID <= curSelected + 2)
						value = 1;
					else 
						value = 0;
			}
			FlxTween.tween(spr, {y: -20 -(curSelected - spr.ID) * 135, x: (curSelected - spr.ID) * 170, alpha: value, "scale.y": ((curSelected - spr.ID) + 5) * 0.2, "scale.x": ((curSelected - spr.ID) + 5) * 0.2}, 0.1);
		});

		buttonFG.forEach(function(spr:FlxSprite)
		{
			var value:Int = 0;
			
			switch(curSelected)
			{
				case 0:
					if(spr.ID >= curSelected && spr.ID < curSelected + 3)
						value = 1;
					else value = 0;
				default:
					if(spr.ID >= curSelected && spr.ID <= curSelected + 2)
						value = 1;
					else 
						value = 0;
			}

			FlxTween.tween(spr, {y: 190 -(curSelected - spr.ID) * 165, x: 190 + (curSelected - spr.ID) * 105, alpha: value, "scale.y": ((curSelected - spr.ID) + 5) * (0.2 * mapScale[spr.ID][1]), "scale.x": ((curSelected - spr.ID) + 5) * (0.2 * mapScale[spr.ID][0])}, 0.1);
		});

		specialLogo.forEach(function(spr:FlxSprite)
		{
			var value:Int = 0;
			
			switch(curSelected)
			{
				case 0:
					if(spr.ID >= curSelected && spr.ID < curSelected + 3)
						value = 1;
					else value = 0;
				default:
					if(spr.ID >= curSelected && spr.ID <= curSelected + 2)
						value = 1;
					else 
						value = 0;
			}

			FlxTween.tween(spr, {y: 685 -(curSelected - spr.ID) * 165, x: -120 + (curSelected - spr.ID) * 105, alpha: value, "scale.y": ((curSelected - spr.ID) + 5) * (0.2 * logoScale[0][1]), "scale.x": ((curSelected - spr.ID) + 5) * (0.2 * logoScale[0][0]), "offset.y": 650 -(curSelected - spr.ID) * -3, "offset.x": -120 -(curSelected - spr.ID) * -35}, 0.1);
		});
	}
}
