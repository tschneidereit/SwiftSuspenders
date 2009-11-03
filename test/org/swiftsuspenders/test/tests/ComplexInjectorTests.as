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

package org.swiftsuspenders.test.tests
{
	import org.flexunit.Assert;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.test.support.injectees.ComplexClassInjectee;
	import org.swiftsuspenders.test.support.injectees.MultipleSingletonsOfSameClassInjectee;
	import org.swiftsuspenders.test.support.types.Clazz;
	import org.swiftsuspenders.test.support.types.ComplexClazz;
	import org.swiftsuspenders.test.support.types.Interface;
	import org.swiftsuspenders.test.support.types.Interface2;
	
	public class ComplexInjectorTests
	{
		protected var injector:Injector;
		
		[Before]
		public function runBeforeEachTest():void
		{
			injector = new Injector();
		}
		
		[Test]
		public function bindValueNested():void
		{
			var injectee:ComplexClassInjectee = new ComplexClassInjectee();
			var value:Clazz = new Clazz();
			var complexValue:ComplexClazz = new ComplexClazz();
			injector.mapValue(Clazz, value);
			injector.mapValue(ComplexClazz, complexValue);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Complex Value should have been injected", complexValue, injectee.property  );
			Assert.assertStrictlyEquals("Nested value should have been injected", value, injectee.property.value );
		}
		
		[Test]
		public function bindMultipleInterfacesToOneSingletonClass():void
		{
			var injectee:MultipleSingletonsOfSameClassInjectee = new MultipleSingletonsOfSameClassInjectee();
			injector.mapSingletonOf(Interface, Clazz);
			injector.mapSingletonOf(Interface2, Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Singleton Value for 'property1' should have been injected", injectee.property1 );
			Assert.assertNotNull("Singleton Value for 'property2' should have been injected", injectee.property2 );
			Assert.assertFalse("Singleton Values 'property1' and 'property2' should not be identical", injectee.property1 == injectee.property2 );
		}
		
	}
}