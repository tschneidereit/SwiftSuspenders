package org.swiftsuspenders
{
	import flexunit.framework.Assert;

	import org.swiftsuspenders.dependencyproviders.ClassProvider;
	import org.swiftsuspenders.dependencyproviders.OtherRuleProvider;
	import org.swiftsuspenders.dependencyproviders.SingletonProvider;
	import org.swiftsuspenders.dependencyproviders.ValueProvider;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.ClazzExtension;

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
			Injector.purgeInjectionPointsCache();
			injector = null;
		}
		
		[Test]
		public function configIsInstantiated():void
		{
			var config : InjectionRule = new InjectionRule(Clazz, "");
			
			Assert.assertTrue(config is InjectionRule);
		}
		
		[Test]
		public function injectionTypeValueReturnsRespone():void
		{
			var response:Clazz = new Clazz();
			var config : InjectionRule = new InjectionRule(Clazz, "");
			config.setProvider(new ValueProvider(response));
			var returnedResponse:Object = config.apply(injector);
			
			Assert.assertStrictlyEquals(response, returnedResponse);
		}
		
		[Test]
		public function injectionTypeClassReturnsRespone():void
		{
			var config : InjectionRule = new InjectionRule(Clazz, "");
			config.setProvider(new ClassProvider(Clazz));
			var returnedResponse:Object = config.apply(injector);
			
			Assert.assertTrue( returnedResponse is Clazz);
		}
		
		[Test]
		public function injectionTypeSingletonReturnsResponse():void
		{
			var config : InjectionRule = new InjectionRule(Clazz, "");
			config.setProvider(new SingletonProvider(Clazz));
			var returnedResponse:Object = config.apply(injector);
			
			Assert.assertTrue( returnedResponse is Clazz);
		}
		
		[Test]
		public function sameSingletonIsReturnedOnSecondResponse():void
		{
			var config : InjectionRule = new InjectionRule(Clazz, "");
			config.setProvider(new SingletonProvider(Clazz));
			var returnedResponse:Object = config.apply(injector);
			var secondResponse:Object = config.apply(injector);
			
			Assert.assertStrictlyEquals( returnedResponse, secondResponse );
		}

		[Test]
		public function sameNamedSingletonIsReturnedOnSecondResponse():void
		{
			var config : InjectionRule = new InjectionRule(Clazz, "named");
			config.setProvider(new SingletonProvider(Clazz));
			var returnedResponse:Object = config.apply(injector);
			var secondResponse:Object = config.apply(injector);

			Assert.assertStrictlyEquals( returnedResponse, secondResponse );
		}

		[Test]
		public function callingSetResultBetweenUsagesChangesResponse():void
		{
			var config : InjectionRule = new InjectionRule(Clazz, '');
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
			var config : InjectionRule = new InjectionRule(Clazz, "");
			var otherConfig : InjectionRule = new InjectionRule(ClazzExtension, "");
			otherConfig.setProvider(new ClassProvider(ClazzExtension));
			config.setProvider(new OtherRuleProvider(otherConfig));
			var returnedResponse:Object = config.apply(injector);

			Assert.assertTrue( returnedResponse is Clazz);
			Assert.assertTrue( returnedResponse is ClazzExtension);
		}
	}
}