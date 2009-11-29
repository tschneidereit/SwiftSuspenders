package org.swiftsuspenders
{
	import flash.utils.Dictionary;
	
	import org.flexunit.Assert;
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
			var config : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionType.SINGLETON, "", null, null);	
			
			Assert.assertTrue(config is InjectionConfig);
		}
		
		[Test]
		public function injectionTypeValueReturnsRespone():void
		{
			var response:Clazz = new Clazz();
			var config : InjectionConfig = new InjectionConfig(
				Clazz, response, InjectionType.VALUE, "", injector, null);	
			var returnedResponse:Object = config.getResponse();
			
			Assert.assertStrictlyEquals(response, returnedResponse);
		}
		
		[Test]
		public function injectionTypeClassReturnsRespone():void
		{
			var config : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionType.CLASS, "", injector, null);
			var returnedResponse:Object = config.getResponse();
			
			Assert.assertTrue( returnedResponse is Clazz);
		}
		
		[Test]
		public function injectionTypeSingletonReturnsResponse():void
		{
			var singletons:Dictionary = new Dictionary();
			var config : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionType.SINGLETON, "", injector, singletons);
			var returnedResponse:Object = config.getResponse();	
			
			Assert.assertTrue( returnedResponse is Clazz);
		}
		
		[Test]
		public function singletonIsAddedToUsedDictionaryOnFirstResponse():void
		{
			var singletons:Dictionary = new Dictionary();
			var config : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionType.SINGLETON, "", injector, singletons);
			var returnedResponse:Object = config.getResponse();
			
			Assert.assertTrue( singletons[Clazz] == returnedResponse );			
		}
		
		[Test]
		public function namedSingletonIsAddedToUsedDictionaryOnFirstResponse():void
		{
			var singletons:Dictionary = new Dictionary();
			var config : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionType.SINGLETON, "named", injector, singletons);	
			var returnedResponse:Object = config.getResponse();
			
			Assert.assertTrue( singletons["named"][Clazz] == returnedResponse );			
		}
		
		[Test]
		public function sameSingletonIsReturnedOnSecondResponse():void
		{
			var singletons:Dictionary = new Dictionary();
			var config : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionType.SINGLETON, "", injector, singletons);
			var returnedResponse:Object = config.getResponse();	
			var secondResponse:Object = config.getResponse();
			
			Assert.assertStrictlyEquals( returnedResponse, secondResponse )
		}
		
		[Test]
		public function sameNamedSingletonIsReturnedOnSecondResponse():void
		{
			var singletons:Dictionary = new Dictionary();
			var config : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionType.SINGLETON, "named", injector, singletons);	
			var returnedResponse:Object = config.getResponse();
			var secondResponse:Object = config.getResponse();
			
			Assert.assertStrictlyEquals( returnedResponse, secondResponse )
		}
	}
}