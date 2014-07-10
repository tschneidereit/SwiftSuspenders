/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package  org.swiftsuspenders.typedescriptions
{
	import org.flexunit.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.isA;
	import org.hamcrest.object.equalTo;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.support.injectees.TwoOptionalParametersConstructorInjectee;
	import org.swiftsuspenders.support.injectees.TwoParametersConstructorInjectee;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.Interface;
	import org.swiftsuspenders.utils.SsInternal;

	use namespace SsInternal;

	public class ConstructorInjectionPointTests
	{
		public static const STRING_REFERENCE:String = "stringReference";

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
		public function injectionOfTwoUnnamedPropertiesIntoConstructor():void
		{
			injector.map(Clazz).toSingleton(Clazz);
			injector.map(String).toValue(STRING_REFERENCE);
			
			var parameters : Array = ["org.swiftsuspenders.support.types::Clazz|","String|"];
			var injectionPoint:ConstructorInjectionPoint =
					new ConstructorInjectionPoint(parameters, 2, null);

			var injectee:TwoParametersConstructorInjectee = injectionPoint.createInstance(
					TwoParametersConstructorInjectee, injector) as TwoParametersConstructorInjectee;
			
			Assert.assertTrue("dependency 1 should be Clazz instance", injectee.getDependency() is Clazz);		
			Assert.assertTrue("dependency 2 should be 'stringReference'", injectee.getDependency2() == STRING_REFERENCE);	
		}
		
		[Test]
		public function injectionOfFirstOptionalPropertyIntoTwoOptionalParametersConstructor():void
		{
			injector.map(Interface).toSingleton(Clazz);
			
			var parameters : Array = ["org.swiftsuspenders.support.types::Interface|", "String|"];
			var injectionPoint:ConstructorInjectionPoint =
					new ConstructorInjectionPoint(parameters, 0, null);

			var injectee:TwoOptionalParametersConstructorInjectee = injectionPoint.createInstance(
					TwoOptionalParametersConstructorInjectee, injector) as TwoOptionalParametersConstructorInjectee;


			assertThat(injectee.getDependency(), isA(Clazz));
			assertThat(injectee.getDependency2(), equalTo(null));
		}
		
		[Test]
		public function injectionOfSecondOptionalPropertyIntoTwoOptionalParametersConstructor():void
		{
			injector.map(String).toValue(STRING_REFERENCE);
			
			var parameters : Array = ["org.swiftsuspenders.support.types::Interface|", "String|"];
			var injectionPoint:ConstructorInjectionPoint =
					new ConstructorInjectionPoint(parameters, 0, null);
			
			var injectee:TwoOptionalParametersConstructorInjectee = injectionPoint.createInstance(
					TwoOptionalParametersConstructorInjectee, injector) as TwoOptionalParametersConstructorInjectee;
			
			
			assertThat(injectee.getDependency(), equalTo(null));
			assertThat(injectee.getDependency2(), equalTo(null));
		}
	}
}
