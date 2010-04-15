/*
* Copyright (c) 2009 the original author or authors
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

package org.swiftsuspenders.suites
{
	import org.swiftsuspenders.ChildInjectorTests;
	import org.swiftsuspenders.GetConstructorTests;
	import org.swiftsuspenders.InjectionConfigTests;
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
	}
}