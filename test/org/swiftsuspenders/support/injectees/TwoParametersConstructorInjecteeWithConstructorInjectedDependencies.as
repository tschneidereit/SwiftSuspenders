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

package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Clazz;

	public class TwoParametersConstructorInjecteeWithConstructorInjectedDependencies
	{
		private var m_dependency1 : OneParameterConstructorInjectee;
		private var m_dependency2 : TwoParametersConstructorInjectee;
		
		public function getDependency1() : OneParameterConstructorInjectee
		{
			return m_dependency1;
		}
		
		
		public function getDependency2():TwoParametersConstructorInjectee
		{
			return m_dependency2;
		}

		
		public function TwoParametersConstructorInjecteeWithConstructorInjectedDependencies(dependency1:OneParameterConstructorInjectee,
			dependency2:TwoParametersConstructorInjectee)
		{
			m_dependency1 = dependency1;
			m_dependency2 = dependency2;
		}
	}
}