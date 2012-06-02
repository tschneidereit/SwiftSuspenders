/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.typedescriptions
{
	import org.flexunit.Assert;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.injectees.InterfaceInjectee;
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
			var injectionPoint:PropertyInjectionPoint = new PropertyInjectionPoint(
				'org.swiftsuspenders.support.types::Clazz|', 'property', false, null);
			
			injectionPoint.applyInjection(injectee, ClassInjectee, injector);
			
			Assert.assertTrue("injectee should contain Clazz instance", injectee.property is Clazz);
		}

		[Test]
		public function injectionAttemptWithUnmappedOptionalPropertyDoesntThrow():void
		{
			var injectee:InterfaceInjectee = new InterfaceInjectee();
			var injectionPoint:PropertyInjectionPoint = new PropertyInjectionPoint(
				'org.swiftsuspenders.support.types::Interface|', 'property', true, null);

			injectionPoint.applyInjection(injectee, InterfaceInjectee, injector);

			Assert.assertNull("injectee mustn\'t contain Clazz instance", injectee.property);
		}
	}
}