package org.swiftsuspenders.injectionpoints
{
	import org.flexunit.Assert;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.nodes.InjectionNodes;
	import org.swiftsuspenders.support.types.Clazz;

	public class PropertyInjectionPointTests
	{
		protected var injector:Injector;

		[Before]
		public function runBeforeEachTest():void
		{
			injector = new Injector();
		}

		[After]
		public function teardown():void
		{
			Injector.purgeInjectionPointsCache();
			injector = null;
		}
		[Test]
		public function injectionOfSinglePropertyIsApplied():void
		{
			injector.mapSingleton(Clazz);
			var injectee:ClassInjectee = new ClassInjectee();
			var node:XML = XML(InjectionNodes.PROPERTY_INJECTION_NODE.metadata);
			var injectionPoint:PropertyInjectionPoint = new PropertyInjectionPoint(node);
			
			injectionPoint.applyInjection(injectee, injector);
			
			Assert.assertTrue("injectee should contain Clazz instance", injectee.property is Clazz);
		}
		
		//TODO: Add multiple injection point tests
	}
}