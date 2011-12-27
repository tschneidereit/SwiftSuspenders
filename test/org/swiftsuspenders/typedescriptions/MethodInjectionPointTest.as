/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package  org.swiftsuspenders.typedescriptions
{
	import org.flexunit.Assert;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.support.injectees.OneRequiredOneOptionalPropertyMethodInjectee;
	import org.swiftsuspenders.support.injectees.OptionalOneRequiredParameterMethodInjectee;
	import org.swiftsuspenders.support.injectees.TwoParametersMethodInjectee;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.Interface;
	import org.swiftsuspenders.utils.SsInternal;

	use namespace SsInternal;

	public class MethodInjectionPointTest
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
		public function injectionOfTwoUnnamedPropertiesIntoMethod():void
		{
			var injectee:TwoParametersMethodInjectee = new TwoParametersMethodInjectee();
			injector.map(Clazz).toSingleton(Clazz);
			injector.map(Interface).toSingleton(Clazz);
			var parameters : Array = [
				"org.swiftsuspenders.support.types::Clazz|",
				"org.swiftsuspenders.support.types::Interface|"
			];
			var injectionPoint:MethodInjectionPoint =
					new MethodInjectionPoint("setDependencies", parameters, 2, false, null);

			injectionPoint.applyInjection(injectee, TwoParametersMethodInjectee, injector);

			Assert.assertTrue("dependency 1 should be Clazz instance", injectee.getDependency() is Clazz);		
			Assert.assertTrue("dependency 2 should be Interface", injectee.getDependency2() is Interface);	
		}
		[Test]
		public function injectionOfOneRequiredOneOptionalPropertyIntoMethod():void
		{
			var injectee:OneRequiredOneOptionalPropertyMethodInjectee = new OneRequiredOneOptionalPropertyMethodInjectee();
			injector.map(Clazz).toSingleton(Clazz);
			var parameters : Array = [
				"org.swiftsuspenders.support.types::Clazz|",
				"org.swiftsuspenders.support.types::Interface|"
			];
			var injectionPoint:MethodInjectionPoint =
					new MethodInjectionPoint("setDependencies", parameters, 1, false, null);

			injectionPoint.applyInjection(injectee, OneRequiredOneOptionalPropertyMethodInjectee, injector);
			
			Assert.assertTrue("dependency 1 should be Clazz instance", injectee.getDependency() is Clazz);		
			Assert.assertTrue("dependency 2 should be null", injectee.getDependency2() == null);	
		}

		[Test]
		public function injectionAttemptWithUnmappedOptionalMethodInjectionDoesntThrow():void
		{
			var injectee:OptionalOneRequiredParameterMethodInjectee =
					new OptionalOneRequiredParameterMethodInjectee();
			var parameters : Array = ["org.swiftsuspenders.support.types::Clazz|"];
			var injectionPoint:MethodInjectionPoint =
					new MethodInjectionPoint("setDependency", parameters, 1, true, null);

			injectionPoint.applyInjection(injectee, OptionalOneRequiredParameterMethodInjectee, injector);

			Assert.assertNull("dependency must be null", injectee.getDependency());
		}
	}
}