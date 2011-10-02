package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;

	public class InjectorUsingProvider implements DependencyProvider
	{
		//----------------------              Public Properties             ----------------------//
		public var injector : Injector;
		public var provider : DependencyProvider;


		//----------------------       Private / Protected Properties       ----------------------//


		//----------------------               Public Methods               ----------------------//
		public function InjectorUsingProvider(injector : Injector, provider : DependencyProvider)
		{
			this.injector = injector;
			this.provider = provider;
		}

		public function apply(targetType : Class, activeInjector : Injector) : Object
		{
			return provider.apply(targetType, injector);
		}
	}
}