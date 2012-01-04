/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.suites
{
	import org.swiftsuspenders.ApplicationDomainTests;
	import org.swiftsuspenders.ChildInjectorTests;
	import org.swiftsuspenders.DependencyProviderTests;
	import org.swiftsuspenders.DescribeTypeJSONReflectorTests;
	import org.swiftsuspenders.DescribeTypeReflectorTests;
	import org.swiftsuspenders.ReflectorBaseTests;
	import org.swiftsuspenders.InjectionMappingTests;
	import org.swiftsuspenders.InjectorTests;
	import org.swiftsuspenders.typedescriptions.ConstructorInjectionPointTests;
	import org.swiftsuspenders.typedescriptions.MethodInjectionPointTest;
	import org.swiftsuspenders.typedescriptions.NoParamsConstructorInjectionPointTests;
	import org.swiftsuspenders.typedescriptions.PostConstructInjectionPointTests;
	import org.swiftsuspenders.typedescriptions.PropertyInjectionPointTests;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class SwiftSuspendersTestSuite
	{
		public var injectorTests:InjectorTests;
		public var propertyInjectionPointTests:PropertyInjectionPointTests;
		public var describeTypeReflectorTests:DescribeTypeReflectorTests;
		public var describeTypeJSONRTests:DescribeTypeJSONReflectorTests;
		public var methodInjectionPointTests:MethodInjectionPointTest;
		public var postConstructInjectionPointTests:PostConstructInjectionPointTests;
		public var noParamConstructorInjectionPoint:NoParamsConstructorInjectionPointTests;
		public var constructorInjectionPointTests:ConstructorInjectionPointTests;
		public var injectionConfigTests:InjectionMappingTests;
		public var dependencyProviderTests:DependencyProviderTests;
		public var childInjectorTests : ChildInjectorTests;
		public var getConstructorTests : ReflectorBaseTests;
		public var applicationDomainTests : ApplicationDomainTests;
	}
}