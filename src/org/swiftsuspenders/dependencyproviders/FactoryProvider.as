package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.Injector;

	public class FactoryProvider implements DependencyProvider
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _factoryClass : Class;


		//----------------------               Public Methods               ----------------------//
		public function FactoryProvider(factoryClass : Class)
		{
			_factoryClass = factoryClass;
		}

		public function apply(targetType : Class, activeInjector : Injector) : Object
		{
			return DependencyProvider(activeInjector.getInstance(_factoryClass))
					.apply(targetType, activeInjector);
		}
	}
}