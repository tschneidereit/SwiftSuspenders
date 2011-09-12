/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flexunit.framework.Assert;

	import org.swiftsuspenders.dependencyproviders.ClassProvider;
	import org.swiftsuspenders.dependencyproviders.OtherRuleProvider;
	import org.swiftsuspenders.dependencyproviders.SingletonProvider;
	import org.swiftsuspenders.dependencyproviders.ValueProvider;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.ClazzExtension;
	import org.swiftsuspenders.utils.SsInternal;

	use namespace SsInternal;

	public class InjectionRuleTests
	{
		private var injector:Injector;
		
		[Before]
		public function setup():void
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
		public function configIsInstantiated():void
		{
			var config : InjectionRule = new InjectionRule(injector, Clazz);
			
			Assert.assertTrue(config is InjectionRule);
		}

		[Test]
		public function ruleWithoutProviderEverSetUsesClassProvider() : void
		{
			var config : InjectionRule = new InjectionRule(injector, Clazz);
			var returnedResponse:Object = config.apply(injector);

			Assert.assertTrue(returnedResponse is Clazz);
		}
		
		[Test]
		public function injectionTypeValueReturnsRespone():void
		{
			var response:Clazz = new Clazz();
			var config : InjectionRule = new InjectionRule(injector, Clazz);
			config.setProvider(new ValueProvider(response));
			var returnedResponse:Object = config.apply(injector);
			
			Assert.assertStrictlyEquals(response, returnedResponse);
		}

		[Test]
		public function injectionTypeClassReturnsRespone():void
		{
			var config : InjectionRule = new InjectionRule(injector, Clazz);
			config.setProvider(new ClassProvider(Clazz));
			var returnedResponse:Object = config.apply(injector);

			Assert.assertTrue( returnedResponse is Clazz);
		}

		[Test]
		public function injectionTypeClassReturnsDifferentInstancesOnEachRespone():void
		{
			var config : InjectionRule = new InjectionRule(injector, Clazz);
			config.setProvider(new ClassProvider(Clazz));
			var firstResponse:Object = config.apply(injector);
			var secondResponse:Object = config.apply(injector);

			Assert.assertFalse(firstResponse == secondResponse);
		}
		
		[Test]
		public function injectionTypeSingletonReturnsResponse():void
		{
			var config : InjectionRule = new InjectionRule(injector, Clazz);
			config.setProvider(new SingletonProvider(Clazz));
			var returnedResponse:Object = config.apply(injector);
			
			Assert.assertTrue( returnedResponse is Clazz);
		}

		[Test]
		public function sameSingletonIsReturnedOnSecondResponse():void
		{
			var config : InjectionRule = new InjectionRule(injector, Clazz);
			config.setProvider(new SingletonProvider(Clazz));
			var returnedResponse:Object = config.apply(injector);
			var secondResponse:Object = config.apply(injector);

			Assert.assertStrictlyEquals( returnedResponse, secondResponse );
		}

		[Test]
		public function injectionRuleAsSingletonMethodCreatesSingletonProvider():void
		{
			var config : InjectionRule = new InjectionRule(injector, Clazz);
			config.asSingleton();
			var returnedResponse:Object = config.apply(injector);
			var secondResponse:Object = config.apply(injector);

			Assert.assertStrictlyEquals( returnedResponse, secondResponse );
		}

		[Test]
		public function sameNamedSingletonIsReturnedOnSecondResponse():void
		{
			var config : InjectionRule = new NamedInjectionRule(injector, Clazz, "named");
			config.setProvider(new SingletonProvider(Clazz));
			var returnedResponse:Object = config.apply(injector);
			var secondResponse:Object = config.apply(injector);

			Assert.assertStrictlyEquals( returnedResponse, secondResponse );
		}

		[Test]
		public function callingSetProviderBetweenUsagesChangesResponse():void
		{
			var config : InjectionRule = new InjectionRule(injector, Clazz);
			config.setProvider(new SingletonProvider(Clazz));
			var returnedResponse:Object = config.apply(injector);
			config.setProvider(null);
			config.setProvider(new ClassProvider(Clazz));
			var secondResponse:Object = config.apply(injector);

			Assert.assertFalse('First result doesn\'t equal second result',
					returnedResponse == secondResponse );
		}

		[Test]
		public function injectionTypeOtherRuleReturnsOtherRulesResponse():void
		{
			var config : InjectionRule = new InjectionRule(injector, Clazz);
			var otherConfig : InjectionRule = new InjectionRule(injector, ClazzExtension);
			otherConfig.setProvider(new ClassProvider(ClazzExtension));
			config.setProvider(new OtherRuleProvider(otherConfig));
			var returnedResponse:Object = config.apply(injector);

			Assert.assertTrue( returnedResponse is Clazz);
			Assert.assertTrue( returnedResponse is ClazzExtension);
		}
	}
}