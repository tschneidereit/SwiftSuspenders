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
	import org.swiftsuspenders.dependencyproviders.SingletonProvider;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.utils.SsInternal;

	use namespace SsInternal;

	public class InjectionMappingTests
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
			var config : InjectionMapping = new InjectionMapping(injector, Clazz, '');
			
			Assert.assertTrue(config is InjectionMapping);
		}

		[Test]
		public function mappingWithoutProviderEverSetUsesClassProvider() : void
		{
			var config : InjectionMapping = new InjectionMapping(injector, Clazz, '');
			var returnedResponse:Object = config.apply(null, injector);

			Assert.assertTrue(returnedResponse is Clazz);
		}

		[Test]
		public function injectionMappingAsSingletonMethodCreatesSingletonProvider():void
		{
			var config : InjectionMapping = new InjectionMapping(injector, Clazz, '');
			config.asSingleton();
			var returnedResponse:Object = config.apply(null, injector);
			var secondResponse:Object = config.apply(null, injector);

			Assert.assertStrictlyEquals( returnedResponse, secondResponse );
		}

		[Test]
		public function sameNamedSingletonIsReturnedOnSecondResponse():void
		{
			var config : InjectionMapping = new InjectionMapping(injector, Clazz, "named");
			config.toProvider(new SingletonProvider(Clazz, injector));
			var returnedResponse:Object = config.apply(null, injector);
			var secondResponse:Object = config.apply(null, injector);

			Assert.assertStrictlyEquals( returnedResponse, secondResponse );
		}

		[Test]
		public function callingSetProviderBetweenUsagesChangesResponse():void
		{
			var config : InjectionMapping = new InjectionMapping(injector, Clazz, '');
			config.toProvider(new SingletonProvider(Clazz, injector));
			var returnedResponse:Object = config.apply(null, injector);
			config.toProvider(null);
			config.toProvider(new ClassProvider(Clazz));
			var secondResponse:Object = config.apply(null, injector);

			Assert.assertFalse('First result doesn\'t equal second result',
					returnedResponse == secondResponse );
		}
	}
}