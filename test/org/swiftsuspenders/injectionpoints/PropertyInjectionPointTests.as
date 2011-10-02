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
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.utils.SsInternal;

	use namespace SsInternal;

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
			Injector.SsInternal::purgeInjectionPointsCache();
			injector = null;
		}

		[Test]
		public function injectionOfSinglePropertyIsApplied():void
		{
			injector.map(Clazz).toSingleton(Clazz);
			var injectee:ClassInjectee = new ClassInjectee();
			var config : InjectionPointConfig = new InjectionPointConfig('org.swiftsuspenders.support.types::Clazz|');
			var injectionPoint:PropertyInjectionPoint =
					new PropertyInjectionPoint(config, 'property', false);
			
			injectionPoint.applyInjection(injectee, ClassInjectee, injector);
			
			Assert.assertTrue("injectee should contain Clazz instance", injectee.property is Clazz);
		}

		[Test]
		public function injectionAttemptWithUnmappedOptionalPropertyDoesntThrow():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var config : InjectionPointConfig = new InjectionPointConfig('org.swiftsuspenders.support.types::Clazz|');
			var injectionPoint:PropertyInjectionPoint =
					new PropertyInjectionPoint(config, 'property', true);

			injectionPoint.applyInjection(injectee, ClassInjectee, injector);

			Assert.assertNull("injectee mustn\'t contain Clazz instance", injectee.property);
		}
	}
}