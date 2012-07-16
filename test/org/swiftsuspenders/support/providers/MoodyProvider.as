package org.swiftsuspenders.support.providers
{
	import org.swiftsuspenders.Injector;
	import flash.utils.Dictionary;
	import org.swiftsuspenders.dependencyproviders.FallbackDependencyProvider;
	import org.swiftsuspenders.typedescriptions.TypeDescription;

	public class MoodyProvider implements FallbackDependencyProvider
	{
		private var _satisfies:Boolean
		
		public static const ALLOW_INTERFACES:Boolean = true;
	
		public function MoodyProvider(satisfies:Boolean)
		{
			_satisfies = satisfies;
		}
		
		//---------------------------------------
		// FallbackDependencyProvider Implementation
		//---------------------------------------

		public function satisfies(type : Class, description:TypeDescription):Boolean
		{
			return _satisfies;
		}

		//---------------------------------------
		// DependencyProvider Implementation
		//---------------------------------------

		public function apply(
			targetType : Class, activeInjector : Injector, injectParameters : Dictionary) : Object
		{
			return null;
		}

		public function destroy() : void
		{
			
		}
	}
}