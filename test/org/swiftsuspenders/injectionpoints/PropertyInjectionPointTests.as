package org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.flexunit.Assert;
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.injectionresults.InjectSingletonResult;
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.nodes.InjectionNodes;
	import org.swiftsuspenders.support.types.Clazz;

	public class PropertyInjectionPointTests
	{
		[Test]
		public function injectionOfSinglePropertyIsApplied():void
		{
			var injector:Injector = new Injector();
			var injectee:ClassInjectee = new ClassInjectee();
			var injectionPoint:PropertyInjectionPoint = createSingleProertySingletonClazzVariableInjectionPoint();
			
			injectionPoint.applyInjection(injectee, injector);
			
			Assert.assertTrue("injectee should contain Clazz instance", injectee.property is Clazz);
		}
		
		private function createSingleProertySingletonClazzVariableInjectionPoint():PropertyInjectionPoint
		{
			var node:XML = XML(InjectionNodes.PROPERTY_INJECTION_NODE.metadata);
			var injector : Injector = createUnnamedSinglePropertySingletonInjectionInjector();
			var injectionPoint:PropertyInjectionPoint = new PropertyInjectionPoint(node, injector);
			return injectionPoint;
		}
		
		private function createUnnamedSinglePropertySingletonInjectionInjector() : Injector
		{
			var injector:Injector = new Injector();
			injector.mapSingleton(Clazz);
			
			return injector;
		}
		
		//TODO: Add multiple injection point tests
	}
}