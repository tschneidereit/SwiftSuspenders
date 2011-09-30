package org.swiftsuspenders.support.providers
{
	import flash.utils.getQualifiedClassName;

	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;
	import org.swiftsuspenders.support.types.Clazz;

	public class ClassNameStoringProvider implements DependencyProvider
	{
		//----------------------              Public Properties             ----------------------//
		public var lastTargetClassName : String;


		//----------------------               Public Methods               ----------------------//
		public function ClassNameStoringProvider()
		{
		}

		public function apply(targetType : Class, activeInjector : Injector) : Object
		{
			lastTargetClassName = getQualifiedClassName(targetType);
			return new Clazz();
		}
	}
}