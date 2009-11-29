package org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.flexunit.Assert;
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.InjectionType;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.nodes.InjectionNodes;
	import org.swiftsuspenders.support.types.Clazz;

	public class PropertyInjectionPointTests
	{
		[Test]
		public function injectionOfSinglePropertyIsApplied():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var injectionPoint:PropertyInjectionPoint = createSingleProertySingletonClazzVariableInjectionPoint();
			
			injectionPoint.applyInjection(injectee);
			
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
			var injector:Injector = new Injector();
			var singletons:Dictionary = new Dictionary();
			var classConfigDisctionary:Dictionary = new Dictionary();
			var config : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionType.SINGLETON, "", injector, singletons);
			var fqcn:String = getQualifiedClassName(Clazz);
			classConfigDisctionary[fqcn] = config;
			return classConfigDisctionary;
		}
		
		//TODO: Add multiple injection point tests
	}
}