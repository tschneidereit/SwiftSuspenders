/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flexunit.framework.Assert;

	import org.swiftsuspenders.injectionresults.InjectClassResult;
	import org.swiftsuspenders.injectionresults.InjectOtherRuleResult;
	import org.swiftsuspenders.injectionresults.InjectSingletonResult;
	import org.swiftsuspenders.injectionresults.InjectValueResult;
	import org.swiftsuspenders.injectionresults.InjectionResult;
	import org.swiftsuspenders.support.types.Clazz;

	public class InjectionResultTests
	{
		[Test]
		public function equalsReturnsTrueForInstanceIdentity() : void
		{
			var result : InjectionResult = new InjectClassResult(Clazz);
			var assertDesc : String = '#equals returns true for instance identity';
			Assert.assertTrue('InjectClassResult' + assertDesc, result.equals(result));
			result = new InjectOtherRuleResult(new InjectionConfig(Clazz, 'foo'));
			Assert.assertTrue('InjectOtherRuleResult' + assertDesc, result.equals(result));
			result = new InjectSingletonResult(Clazz);
			Assert.assertTrue('InjectSingletonResult' + assertDesc, result.equals(result));
			result = new InjectValueResult(Clazz);
			Assert.assertTrue('InjectValueResult' + assertDesc, result.equals(result));
		}
		[Test]
		public function equalsReturnsTrueForTwoInstancesWithSameResult() : void
		{
			var result : InjectionResult = new InjectClassResult(Clazz);
			var otherResult : InjectionResult = new InjectClassResult(Clazz);
			var assertDesc : String = '#equals returns true for other instance with same result';
			Assert.assertTrue('InjectClassResult' + assertDesc,result.equals(otherResult));
			var injectionConfig : InjectionConfig = new InjectionConfig(Clazz, 'foo');
			result = new InjectOtherRuleResult(injectionConfig);
			otherResult = new InjectOtherRuleResult(injectionConfig);
			Assert.assertTrue('InjectOtherRuleResult' + assertDesc, result.equals(otherResult));
			result = new InjectSingletonResult(Clazz);
			otherResult = new InjectSingletonResult(Clazz);
			Assert.assertTrue('InjectSingletonResult' + assertDesc, result.equals(otherResult));
			var clazzInstance : Clazz = new Clazz();
			result = new InjectValueResult(clazzInstance);
			otherResult = new InjectValueResult(clazzInstance);
			Assert.assertTrue('InjectValueResult' + assertDesc, result.equals(otherResult));
		}

		[Test]
		public function equalsReturnsFalseForAlreadyInitializedSingletonResult() : void
		{
			var result : InjectionResult = new InjectSingletonResult(Clazz);
			result.getResponse(new Injector());
			var otherResult : InjectionResult = new InjectSingletonResult(Clazz);
			Assert.assertFalse('InjectSingletonResult#equals returns false when comparing ' +
					'initialized InjectSingletonResult with another instance',
					result.equals(otherResult));
		}
	}
}