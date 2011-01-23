package org.swiftsuspenders
{
	import flexunit.framework.Assert;

	import org.swiftsuspenders.injectionresults.InjectClassResult;
	import org.swiftsuspenders.injectionresults.InjectOtherRuleResult;
	import org.swiftsuspenders.injectionresults.InjectSingletonResult;
	import org.swiftsuspenders.injectionresults.InjectValueResult;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.ClazzExtension;

	public class InjectionConfigTests
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
			var config : InjectionConfig = new InjectionConfig(Clazz, "");
			
			Assert.assertTrue(config is InjectionConfig);
		}
		
		[Test]
		public function injectionTypeValueReturnsRespone():void
		{
			var response:Clazz = new Clazz();
			var config : InjectionConfig = new InjectionConfig(Clazz, "");
			config.setResult(new InjectValueResult(response));
			var returnedResponse:Object = config.getResponse(injector);
			
			Assert.assertStrictlyEquals(response, returnedResponse);
		}
		
		[Test]
		public function injectionTypeClassReturnsRespone():void
		{
			var config : InjectionConfig = new InjectionConfig(Clazz, "");
			config.setResult(new InjectClassResult(Clazz));
			var returnedResponse:Object = config.getResponse(injector);
			
			Assert.assertTrue( returnedResponse is Clazz);
		}
		
		[Test]
		public function injectionTypeSingletonReturnsResponse():void
		{
			var config : InjectionConfig = new InjectionConfig(Clazz, "");
			config.setResult(new InjectSingletonResult(Clazz));
			var returnedResponse:Object = config.getResponse(injector);
			
			Assert.assertTrue( returnedResponse is Clazz);
		}
		
		[Test]
		public function sameSingletonIsReturnedOnSecondResponse():void
		{
			var config : InjectionConfig = new InjectionConfig(Clazz, "");
			config.setResult(new InjectSingletonResult(Clazz));
			var returnedResponse:Object = config.getResponse(injector);
			var secondResponse:Object = config.getResponse(injector);
			
			Assert.assertStrictlyEquals( returnedResponse, secondResponse );
		}

		[Test]
		public function sameNamedSingletonIsReturnedOnSecondResponse():void
		{
			var config : InjectionConfig = new InjectionConfig(Clazz, "named");
			config.setResult(new InjectSingletonResult(Clazz));
			var returnedResponse:Object = config.getResponse(injector);
			var secondResponse:Object = config.getResponse(injector);

			Assert.assertStrictlyEquals( returnedResponse, secondResponse );
		}

		[Test]
		public function callingSetResultBetweenUsagesChangesResponse():void
		{
			var config : InjectionConfig = new InjectionConfig(Clazz, '');
			config.setResult(new InjectSingletonResult(Clazz));
			var returnedResponse:Object = config.getResponse(injector);
			config.setResult(null);
			config.setResult(new InjectClassResult(Clazz));
			var secondResponse:Object = config.getResponse(injector);

			Assert.assertFalse('First result doesn\'t equal second result',
					returnedResponse == secondResponse );
		}

		[Test]
		public function injectionTypeOtherRuleReturnsOtherRulesResponse():void
		{
			var config : InjectionConfig = new InjectionConfig(Clazz, "");
			var otherConfig : InjectionConfig = new InjectionConfig(ClazzExtension, "");
			otherConfig.setResult(new InjectClassResult(ClazzExtension));
			config.setResult(new InjectOtherRuleResult(otherConfig));
			var returnedResponse:Object = config.getResponse(injector);

			Assert.assertTrue( returnedResponse is Clazz);
			Assert.assertTrue( returnedResponse is ClazzExtension);
		}
	}
}