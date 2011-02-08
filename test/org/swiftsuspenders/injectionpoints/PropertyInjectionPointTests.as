/*
 * Copyright (c) 2009-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

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
			injector.map(Clazz).toSingleton(Clazz);
			var injectee:ClassInjectee = new ClassInjectee();
			var node:XML = XML(InjectionNodes.PROPERTY_INJECTION_NODE.metadata);
			var injectionPoint:PropertyInjectionPoint = new PropertyInjectionPoint(node);
			
			injectionPoint.applyInjection(injectee, injector);
			
			Assert.assertTrue("injectee should contain Clazz instance", injectee.property is Clazz);
		}

		[Test]
		public function injectionAttemptWithUnmappedOptionalPropertyDoesntThrow():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var node:XML = XML(InjectionNodes.OPTIONAL_PROPERTY_INJECTION_NODE.metadata);
			var injectionPoint:PropertyInjectionPoint = new PropertyInjectionPoint(node);

			injectionPoint.applyInjection(injectee, injector);

			Assert.assertNull("injectee mustn\'t contain Clazz instance", injectee.property);
		}
	}
}