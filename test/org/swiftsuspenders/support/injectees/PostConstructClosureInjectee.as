package org.swiftsuspenders.support.injectees
{
	/**
	 * Used in the test that checks if postconstruct works with closures.
	 * 
	 * goAtIt should be called by the injector after construction.
	 * 
	 * @langversion ActionScript 3
	 * @playerversion Flash 9.0.0
	 * 
	 * @author Lars van de Kerkhof
	 * @since  15.04.2011
	 */
	
	public class PostConstructClosureInjectee
	{
		public var someProperty:Boolean;
		
		public function PostConstructClosureInjectee()
		{
			someProperty = false;
		}
		
		[PostConstruct]
		public var goAtIt:Function = function():void
		{
			this.someProperty = true;
		}
	}
}