package de.popforge.widget.fl909
{
	import de.popforge.assets.tr909.Chassis;
	import de.popforge.audio.processor.fl909.FL909;
	import de.popforge.audio.processor.fl909.memory.Pattern;
	import de.popforge.audio.processor.fl909.memory.Trigger;
	import de.popforge.parameter.Parameter;
	
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.SharedObject;
	import flash.utils.ByteArray;

	public class FL909GUI extends Sprite
	{
		static public const WIDTH: int = 580;
		static public const HEIGHT: int = 262;
		
		[Embed(source="firstrun.909", mimeType="application/octet-stream")] static private const FirstRun: Class;
		
		private var player: FL909Player;
		private var fl909: FL909;
		
		private var ram: SharedObject;
		
		private var stepButtons: Array;
		private var patternButtons: Array;
		private var startButton: StartButton;
		private var voiceSwitchBar: VoiceSwitchBar;
		private var bar: LEDBar;
		
		internal var lastPatternButton: PatternButton;
		
		public function FL909GUI( player: FL909Player )
		{
			this.player = player;
			
			fl909 = player.getFL909();
			fl909.readExternal( new FirstRun() );
			
			ram = SharedObject.getLocal( 'FL909.mem', '/' );
			
			build();
		}
		
		/**
		 * BUILD
		 */
		private function build(): void
		{
			addChild( new Bitmap( new Chassis(0,0) ) );
			
			hitArea = new Sprite();
			hitArea.graphics.beginFill( 0, 0 );
			hitArea.graphics.drawRect( 0, 0, FL909GUI.WIDTH, FL909GUI.HEIGHT );
			hitArea.graphics.endFill();
			addChild( hitArea );
			
			addKnobs();
			addVoiceSwitchBar();
			addStepButtons();
			addTempoLCD();
			addPatternButtons();
			addMuteButtons();
			addStartButton();
			addMemoryButtons();
			
			bar = new LEDBar( fl909 );
			addChild( bar );
			
			addEventListener( MouseEvent.CLICK, onMouseClick );
		}
		
		private function addKnobs(): void
		{
			createKnob( 114 + 27 * 0, 102, fl909.toneBassdrum.tune, false );
			createKnob( 114 + 27 * 1, 102, fl909.toneBassdrum.level, false );
			createKnob( 114 + 27 * 0, 129, fl909.toneBassdrum.attack, false );
			createKnob( 114 + 27 * 1, 129, fl909.toneBassdrum.decay, false );
			createKnob( 114 + 27 * 2, 102, fl909.toneSnaredrum.tune, false );
			createKnob( 114 + 27 * 3, 102, fl909.toneSnaredrum.level, false );
			createKnob( 114 + 27 * 2, 129, fl909.toneSnaredrum.tone, false );
			createKnob( 114 + 27 * 3, 129, fl909.toneSnaredrum.snappy, false );
			createKnob( 114 + 27 * 4, 102, fl909.toneTomLow.tune, false );
			createKnob( 114 + 27 * 5, 102, fl909.toneTomLow.level, false );
			createKnob( 114 + 27 * 4, 129, fl909.toneTomLow.decay, false );
			createKnob( 114 + 27 * 6, 102, fl909.toneTomMid.tune, false );
			createKnob( 114 + 27 * 7, 102, fl909.toneTomMid.level, false );
			createKnob( 114 + 27 * 6, 129, fl909.toneTomMid.decay, false );
			createKnob( 114 + 27 * 8, 102, fl909.toneTomHigh.tune, false );
			createKnob( 114 + 27 * 9, 102, fl909.toneTomHigh.level, false );
			createKnob( 114 + 27 * 8, 129, fl909.toneTomHigh.decay, false );
			createKnob( 114 + 27 * 10, 102, fl909.toneRimshot.level, false );
			createKnob( 114 + 27 * 11, 102, fl909.toneClap.level, false );
			//createKnob( 114 + 27 * 12, 102, fl909.toneHighHat.tune, false );
			createKnob( 114 + 27 * 13, 102, fl909.toneHighHat.level, false );
			createKnob( 114 + 27 * 12, 129, fl909.toneHighHat.decayCL, false );
			createKnob( 114 + 27 * 13, 129, fl909.toneHighHat.decayOP, false );
			createKnob( 114 + 27 * 14, 102, fl909.toneCrash.level, false );
			createKnob( 114 + 27 * 15, 102, fl909.toneRide.level, false );
			createKnob( 114 + 27 * 14, 129, fl909.toneCrash.tune, false );
			createKnob( 114 + 27 * 15, 129, fl909.toneRide.tune, false );
			
			createKnob( 73, 170, fl909.tempo, true );
			createKnob( 505, 170, fl909.volume, true );
			createKnob( 73, 129, fl909.accent, false );
			createKnob( 175, 170, fl909.shuffle, false );
		}
		
		private function createKnob( x: int, y: int, parameter: Parameter, large: Boolean ): void
		{
			var knob: Knob = new Knob( parameter, large );
			knob.x = x;
			knob.y = y;
			addChild( knob );
		}
		
		private function addStepButtons(): void
		{
			stepButtons = new Array();
			
			var button: StepButton;
			
			for( var i: int = 0 ; i < 16 ; i++ )
			{
				button = new StepButton( i );
				button.x = 104 + i * 27;
				button.y = 204;
				button.alpha = .75;
				addChild( button );
				
				stepButtons.push( button );
			}
			
			updateStepButtons();
		}
		
		private function addTempoLCD(): void
		{
			var lcd: LCD = new LCD( fl909.tempo );
			lcd.x = 108;
			lcd.y = 160;
			addChild( lcd );
		}
		
		private function addVoiceSwitchBar(): void
		{
			voiceSwitchBar = new VoiceSwitchBar( updateStepButtons );
			addChild( voiceSwitchBar );
		}
		
		private function addStartButton(): void
		{
			startButton = new StartButton( player );
			startButton.x = 64;
			startButton.y = 204;
			addChild( startButton );
		}
		
		/**
		 * UPDATES / INTERACTION
		 */
		internal function startCopyPattern( button: PatternButton ): void
		{
			new CopyPatternHandler( button, fl909.memory, this );
		}
		
		private function onMouseClick( event: MouseEvent ): void
		{
			var target: Object = event.target;
			
			if( target is StepButton )
			{
				proceedStepButtonClick( target as StepButton );
			}
			else if( target is PatternButton )
			{
				proceedPatternButtonClick( target as PatternButton );
			}
			else if( target is MemoryButton )
			{
				proceedMemoryButton( target as MemoryButton );
			}
		}
		
		private function proceedStepButtonClick( button: StepButton ): void
		{
			var stepIndex: int = button.getIndex();
			var state: int = button.getState();
			
			var voiceIndex: int = voiceSwitchBar.getIndex();
			
			fl909.memory.removeTriggerAt( stepIndex, voiceIndex );
			
			if( state > 0 )
				fl909.memory.createTriggerAt( stepIndex, voiceIndex, state == 1 ? false : true );
		}
		
		private function updateStepButtons(): void
		{
			var button: StepButton;
			
			var voiceIndex: int = voiceSwitchBar.getIndex();
			
			var pattern: Pattern = fl909.memory.getPatternNext();
			var triggers: Array;
			var trigger: Trigger;
			
			for( var i: int = 0 ; i < 16 ; i++ )
			{
				triggers = pattern.steps[i];
				
				button = stepButtons[i];
				button.setState( 0 );
				
				if( triggers != null )
				{
					for each( trigger in triggers )
					{
						if( trigger.voiceIndex == voiceIndex )
						{
							button.setState( trigger.accent ? 2 : 1 );
						}
					}
				}
			}
		}
		
		private function addPatternButtons(): void
		{
			patternButtons = new Array();
			
			var button: PatternButton;
			
			var i: int = 8;
			
			while( --i > -1 )
			{
				button = new PatternButton( this, i );
				
				button.setValue( i == 0 );
				button.x = 392 + ( i & 3 ) * 19;
				button.y = 158 + int( i / 4 ) * 16;
				addChild( button );
				patternButtons.push( button );
			}
			
			lastPatternButton = button;
		}
		
		private function proceedPatternButtonClick( button: PatternButton ): void
		{
			var index: int = button.getIndex();
			
			lastPatternButton.setValue( false );
			
			fl909.memory.changePatternByIndex( index );
			
			updateStepButtons();
			
			lastPatternButton = button;
			
			button.setValue( true );
		}
		
		private function addMuteButtons(): void
		{
			createMuteButton( 101, 77, fl909.toneBassdrum.mute );
			createMuteButton( 155, 77, fl909.toneSnaredrum.mute );
			createMuteButton( 209, 77, fl909.toneTomLow.mute );
			createMuteButton( 263, 77, fl909.toneTomMid.mute );
			createMuteButton( 317, 77, fl909.toneTomHigh.mute );
			createMuteButton( 371, 77, fl909.toneRimshot.mute );
			createMuteButton( 398, 77, fl909.toneClap.mute );
			createMuteButton( 425, 77, fl909.toneHighHat.mute );
			createMuteButton( 452, 77, fl909.toneHighHat.mute );
			createMuteButton( 479, 77, fl909.toneCrash.mute );
			createMuteButton( 506, 77, fl909.toneRide.mute );
		}
		
		private function createMuteButton( x: int, y: int, parameter: Parameter ): void
		{
			var button: MuteButton = new MuteButton( parameter );
			button.x = x;
			button.y = y;
			addChild( button );
		}
		
		private function addMemoryButtons(): void
		{
			var button: MemoryButton;
			
			//-- SAVE
			button = new MemoryButton();
			button.name = 'save';
			button.x = 239;
			button.y = 167;
			addChild( button );
			
			//-- LOAD
			button = new MemoryButton();
			button.name = 'load';
			button.x = 258;
			button.y = 167;
			addChild( button );
			
			//-- CLEAR
			button = new MemoryButton();
			button.name = 'clear';
			button.x = 277;
			button.y = 167;
			addChild( button );
		}
		
		private function proceedMemoryButton( button: MemoryButton ): void
		{
			switch( button.name )
			{
				case 'save':
				
					ram.data.all = new ByteArray();
					fl909.writeExternal( ram.data.all );
					ram.flush();
					break;
				
				case 'load':
				
					if( ram.data.all )
					{
						fl909.readExternal( ram.data.all );
						ram.data.all.position = 0;
						updateStepButtons();
					}
					break;
				
				case 'clear':
				
					fl909.clear();
					updateStepButtons();
					break;
			}
		}
	}
}