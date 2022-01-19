package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxCamera;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";

	public static var crashdeath:Bool = false;

	public function new(x:Float, y:Float)
	{
		var daBf:String = '';
		switch (PlayState.SONG.player1)
		{
			case 'bf-pixel' | 'bf-pixelangry':
				stageSuffix = '-pixel';
				daBf = 'bf-pixel-dead';
			case 'playablesenpai':
				stageSuffix = '-senpai';
				daBf = 'playablesenpai';
			default:
				daBf = 'bf';
		}

		switch (PlayState.SONG.player2)
		{
			case 'bigmonika':
				stageSuffix = '';
				daBf = 'bigmonika-dead';
		}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		trace(bf == null ? "bf if hella dumb" : "bf has a big forehead");
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		if (!crashdeath)
		{
			if (PlayState.SONG.player2 == 'bigmonika')
				FlxG.sound.play(Paths.sound('fnf_loss_sfx-bigmonika'));
			else
				FlxG.sound.play(Paths.sound('fnf_loss_sfx' + stageSuffix));
		}
		Conductor.changeBPM(100);

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		if (daBf == "playablesenpai")
		{
			// FlxG.camera.zoom = FlxG.camera.zoom - 0.25;
			camFollow.setPosition(bf.getGraphicMidpoint().x - 74, bf.getGraphicMidpoint().y - 150);

			FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom - 0.15}, 0.35, {
				ease: FlxEase.quadOut
			});
		}

			
		#if mobileC
		addVirtualPad(NONE, A_B);
		var camcontrol = new FlxCamera();
		FlxG.cameras.add(camcontrol);
		camcontrol.bgColor.alpha = 0;
		_virtualpad.cameras = [camcontrol];
		
		#end

		if (!crashdeath)
			bf.playAnim('firstDeath');
		else
		{
			FlxG.sound.play(Paths.sound('JarringMonikaSound'));
			bf.playAnim('crashDeath');
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT && !crashdeath)
		{
			endBullshit();
		}

		if (controls.BACK && !crashdeath)
		{
			FlxG.sound.music.stop();
			PlayState.practiceMode = false;
			PlayState.showCutscene = true;
			PlayState.deathCounter = 0;
			if (PlayState.loadRep)
			{
				FlxG.save.data.botplay = false;
				PlayState.loadRep = false;
			}
			if (PlayState.isStoryMode)
				FlxG.switchState(new DokiStoryState());
			else
				FlxG.switchState(new DokiFreeplayState());
		}

		if (bf.animation.curAnim.name == 'crashDeath' && bf.animation.finished)
		{
			new FlxTimer().start(.5, function(timer:FlxTimer)
			{
				CoolUtil.crash();
			});
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12 && !crashdeath)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished && !crashdeath)
		{
			FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();

		FlxG.log.add('beat');
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + stageSuffix));

			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
