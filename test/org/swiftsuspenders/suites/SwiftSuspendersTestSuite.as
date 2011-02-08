/*
 * Copyright (c) 2009-2011 the original author or authors
*
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
*/



package org.swiftsuspenders.suites
{
	import org.swiftsuspenders.ApplicationDomainTests;
	import org.swiftsuspenders.ChildInjectorTests;
	import org.swiftsuspenders.GetConstructorTests;
	import org.swiftsuspenders.InjectionConfigTests;
	import org.swiftsuspenders.InjectionResultTests;
	import org.swiftsuspenders.InjectorTests;
	import org.swiftsuspenders.ReflectorTests;
	import org.swiftsuspenders.injectionpoints.ConstructorInjectionPointTests;
	import org.swiftsuspenders.injectionpoints.MethodInjectionPointTest;
	import org.swiftsuspenders.injectionpoints.NoParamsConstructorInjectionPointTests;
	import org.swiftsuspenders.injectionpoints.PostConstructInjectionPointTests;
	import org.swiftsuspenders.injectionpoints.PropertyInjectionPointTests;

	[Suite]
	[RunWith("org.flexunit.runners.Suite")]
	public class SwiftSuspendersTestSuite
	{
		public var injectorTests:InjectorTests;
		public var propertyInjectionPointTests:PropertyInjectionPointTests;
		public var reflectorTests:ReflectorTests;
		public var methodInjectionPointTests:MethodInjectionPointTest;
		public var postConstructInjectionPointTests:PostConstructInjectionPointTests;
		public var noParamConstructorInjectionPoint:NoParamsConstructorInjectionPointTests;
		public var constructorInjectionPointTests:ConstructorInjectionPointTests;
		public var injectionConfigTests:InjectionConfigTests;
		public var childInjectorTests : ChildInjectorTests;
		public var getConstructorTests : GetConstructorTests;
		public var applicationDomainTests : ApplicationDomainTests;
		public var injectionResultTests : InjectionResultTests;
	}
}