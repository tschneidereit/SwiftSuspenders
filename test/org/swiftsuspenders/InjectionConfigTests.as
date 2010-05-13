package org.swiftsuspenders
{
	import flash.utils.Dictionary;
	
	import org.flexunit.Assert;
	import org.swiftsuspenders.injectionresults.InjectClassResult;
	import org.swiftsuspenders.injectionresults.InjectSingletonResult;
	import org.swiftsuspenders.injectionresults.InjectValueResult;
	import org.swiftsuspenders.support.types.Clazz;
	
	public class InjectionConfigTests
	{
		private var injector:Injector;
		
		[Before]
		public function setup():void
		{
			injector = new Injector()
		}
		
		[After]
		public function teardown():void
		{
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
			
			Assert.assertStrictlyEquals( returnedResponse, secondResponse )
		}
		
		[Test]
		public function sameNamedSingletonIsReturnedOnSecondResponse():void
		{
			var config : InjectionConfig = new InjectionConfig(Clazz, "named");
			config.setResult(new InjectSingletonResult(Clazz));
			var returnedResponse:Object = config.getResponse(injector);
			var secondResponse:Object = config.getResponse(injector);
			
			Assert.assertStrictlyEquals( returnedResponse, secondResponse )
		}
	}
}