package org.swiftsuspenders.support.types {
	public class ObjectToDestroy {

		public var destroyCounter:int;

		[PreDestroy]
		public function onDestroy() : void {
			destroyCounter++;
		}
	}
}
