package de.popforge.audio.processor.fl909.memory
{
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.net.registerClassAlias;
	
	public final class Memory
		implements IExternalizable
	{
		{
			registerClassAlias( 'Memory', Memory );
			registerClassAlias( 'Pattern', Pattern );
			registerClassAlias( 'Trigger', Trigger );
		}
		
		private var patternBank: Array;
		
		private var patternRun: Pattern;
		private var patternNext: Pattern;
		
		private var stepIndex: int;
		
		public function Memory()
		{
			patternBank = [ patternRun = patternNext = new Pattern() ];
			
			stepIndex = 0;
		}
		
		public function writeExternal( output: IDataOutput ): void
		{
			output.writeObject( patternBank );
		}
		
		public function readExternal( input: IDataInput ): void
		{
			patternBank = input.readObject();
			
			patternRun = patternNext = patternBank[0];
		}
		
		public function changePatternByIndex( index: int ): void
		{
			if( patternBank[ index ] == null )
				patternBank[ index ] = new Pattern();
			
			patternNext = patternBank[ index ];
		}
		
		public function stepComplete(): void
		{
			if( ++stepIndex == patternRun.length )
			{
				patternRun = patternNext;
				stepIndex = 0;
			}
		}
		
		public function getTriggers(): Array
		{
			return patternRun.steps[ stepIndex ];
		}
		
		public function getPatternRun(): Pattern
		{
			return patternRun;
		}
		
		public function getPatternNext(): Pattern
		{
			return patternNext;
		}
		
		public function createTriggerAt( stepIndex: int, voiceIndex: int, accent: Boolean ): void
		{
			if( patternNext.steps[ stepIndex ] == null )
				patternNext.steps[ stepIndex ] = new Array();

			var triggers: Array = patternNext.steps[ stepIndex ];
			triggers.push( new Trigger( voiceIndex, accent ) );
		}
		
		public function removeTriggerAt( stepIndex: int, voiceIndex: int ): void
		{
			var triggers: Array = patternNext.steps[ stepIndex ];
			
			if( triggers == null ) return;
			
			var i: int = triggers.length;
			
			while( --i > -1 )
			{
				if( Trigger( triggers[i] ).voiceIndex == voiceIndex )
				{
					triggers.splice( i, 1 );
					return;
				}
			}
		}
		
		public function copyPattern( sourceIndex: int, targetIndex: int ): void
		{
			if( sourceIndex == targetIndex ) return;
			
			patternBank[ targetIndex ] = Pattern( patternBank[ sourceIndex ] ).clone();
		}
	}
}