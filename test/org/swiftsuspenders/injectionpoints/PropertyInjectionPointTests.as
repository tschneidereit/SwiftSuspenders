package org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.flexunit.Assert;
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.injectionpoints.PropertyInjectionPoint;
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.nodes.InjectionNodes;
	import org.swiftsuspenders.support.types.Clazz;

	public class PropertyInjectionPointTests
	{
		[Test]
		public function injectionOfSinglePropertyIsApplied():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var injector:Injector = new Injector();
			var injectionPoint:PropertyInjectionPoint = createSingleProertySingletonClazzVariableInjectionPoint();
			var singletons:Dictionary = new Dictionary();
			
			injectionPoint.applyInjection(injectee, injector, singletons);
			
			Assert.assertTrue("injectee should contain Clazz instance", injectee.property is Clazz);
		}
		
		private function createSingleProertySingletonClazzVariableInjectionPoint():PropertyInjectionPoint
		{
			var node:XML = XML(InjectionNodes.PROPERTY_INJECTION_NODE.metadata);
			var mappings:Dictionary = createUnamedSinglePropertySingletonInjectionConfigDictionary();
			var injectionPoint:PropertyInjectionPoint = new PropertyInjectionPoint(node, mappings);
			return injectionPoint;
		}
		
		private function createUnamedSinglePropertySingletonInjectionConfigDictionary():Dictionary
		{
			var classConfigDisctionary:Dictionary = new Dictionary();
			var config : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionConfig.INJECTION_TYPE_SINGLETON, "");
			var fqcn:String = getQualifiedClassName(Clazz);
			classConfigDisctionary[fqcn] = config;
			return classConfigDisctionary;
		}
		
		//TODO: Add multiple injection point tests
	}
}