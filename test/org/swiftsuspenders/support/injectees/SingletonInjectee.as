package org.swiftsuspenders.support.injectees {

	public class SingletonInjectee {
		public static var hasInitialized : Boolean;
		public static var hasDestroyed : Boolean;

		public static function reset() : void {
			hasInitialized = false;
			hasDestroyed = false;
		}

		[PostConstruct]
		public function initialize() : void {
			hasInitialized = true;
		}

		[PreDestroy]
		public function destroy() : void {
			hasDestroyed = true;
		}
	}
}
