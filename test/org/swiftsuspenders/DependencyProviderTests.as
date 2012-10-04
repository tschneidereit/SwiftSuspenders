/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.utils.getQualifiedClassName;

	import flexunit.framework.Assert;

	import org.hamcrest.assertThat;
	import org.hamcrest.object.hasPropertyWithValue;
	import org.swiftsuspenders.dependencyproviders.ClassProvider;
	import org.swiftsuspenders.dependencyproviders.OtherMappingProvider;
	import org.swiftsuspenders.dependencyproviders.SingletonProvider;
	import org.swiftsuspenders.dependencyproviders.ValueProvider;
	import org.swiftsuspenders.mapping.InjectionMapping;
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.providers.ClassNameStoringProvider;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.ClazzExtension;
	import org.swiftsuspenders.utils.SsInternal;

	use namespace SsInternal;

	public class DependencyProviderTests
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
		public function valueProviderReturnsSetValue():void
		{
			var response:Clazz = new Clazz();
			const provider : ValueProvider = new ValueProvider(response);
			var returnedResponse:Object = provider.apply(null, injector, null);
			
			Assert.assertStrictlyEquals(response, returnedResponse);
		}

		[Test]
		public function classProviderReturnsClassInstance():void
		{
			const classProvider : ClassProvider = new ClassProvider(Clazz);
			var returnedResponse:Object = classProvider.apply(null, injector, null);

			Assert.assertTrue( returnedResponse is Clazz);
		}

		[Test]
		public function classProviderReturnsDifferentInstancesOnEachApply():void
		{
			const classProvider : ClassProvider = new ClassProvider(Clazz);
			var firstResponse:Object = classProvider.apply(null, injector, null);
			var secondResponse:Object = classProvider.apply(null, injector, null);

			Assert.assertFalse(firstResponse == secondResponse);
		}
		
		[Test]
		public function singletonProviderReturnsInstance():void
		{
			const singletonProvider : SingletonProvider = new SingletonProvider(Clazz, injector);
			var returnedResponse:Object = singletonProvider.apply(null, injector, null);
			
			Assert.assertTrue(returnedResponse is Clazz);
		}

		[Test]
		public function sameSingletonIsReturnedOnSecondResponse():void
		{
			const singletonProvider : SingletonProvider = new SingletonProvider(Clazz, injector);
			var returnedResponse:Object = singletonProvider.apply(null, injector, null);
			var secondResponse:Object = singletonProvider.apply(null, injector, null);

			Assert.assertStrictlyEquals(returnedResponse, secondResponse);
		}

		[Test]
		public function destroyingSingletonProviderInvokesPreDestroyMethodsOnSingleton() : void
		{
			const provider : SingletonProvider = new SingletonProvider(Clazz, injector);
			const singleton : Clazz = Clazz(provider.apply(null, injector, null));
			provider.destroy();
			assertThat(singleton, hasPropertyWithValue("preDestroyCalled", true));
		}
		[Test(expects="org.swiftsuspenders.errors.InjectorError")]
		public function usingDestroyedSingletonProviderThrows() : void
		{
			const provider : SingletonProvider = new SingletonProvider(Clazz, injector);
			provider.destroy();
			const singleton : Clazz = Clazz(provider.apply(null, injector, null));
		}

		[Test]
		public function mappingToProviderUsesProvidersResponse():void
		{
			var otherConfig : InjectionMapping = new InjectionMapping(injector, ClazzExtension,
				'', '');
			otherConfig.toProvider(new ClassProvider(ClazzExtension));
			const otherMappingProvider : OtherMappingProvider = new OtherMappingProvider(otherConfig);
			var returnedResponse:Object = otherMappingProvider.apply(null, injector, null);

			Assert.assertTrue( returnedResponse is Clazz);
			Assert.assertTrue( returnedResponse is ClazzExtension);
		}

		[Test]
		public function dependencyProviderHasAccessToTargetType() : void
		{
			const provider : ClassNameStoringProvider = new ClassNameStoringProvider();
			injector.map(Clazz).toProvider(provider);
			injector.instantiateUnmapped(ClassInjectee);
			
			Assert.assertEquals('className stored in provider is fqn of ClassInjectee',
					getQualifiedClassName(ClassInjectee), provider.lastTargetClassName);
		}
	}
}