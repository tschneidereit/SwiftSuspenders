package org.swiftsuspenders.support.injectees
{
	public class OrderedPostConstructInjectee
	{
		public var loadedAsOrdered:Boolean;
		
		private var one:Boolean;
		private var two:Boolean;
		private var three:Boolean;
		private var four:Boolean;
		
		public function OrderedPostConstructInjectee()
		{
		}
		
		[PostConstruct(order=2)]
		public function methodTwo():void
		{
			two = true;
			loadedAsOrdered = one && two && !three && !four;
		}
		
		[PostConstruct(order=4)]
		public function methodFour():void
		{
			four = true;
			loadedAsOrdered = one && two && three && four;
		}
		
		[PostConstruct(order=3)]
		public function methodThree():void
		{
			three = true;
			loadedAsOrdered = one && two && three && !four;
		}
		
		[PostConstruct(order=1)]
		public function methodOne():void
		{
			one = true;
			loadedAsOrdered = one && !two && !three && !four;
		}
	}
}