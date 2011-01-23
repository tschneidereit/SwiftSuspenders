package org.swiftsuspenders.injectionpoints
{
	import org.flexunit.Assert;

	public class NoParamsConstructorInjectionPointTests
	{
		[Test]
		public function noParamsConstructorInjectionPointIsConstructed():void
		{
			var injectionPoint:NoParamsConstructorInjectionPoint = new NoParamsConstructorInjectionPoint();
			
			Assert.assertTrue("Class doesn't do anything except get constructed", injectionPoint is NoParamsConstructorInjectionPoint);
		}
	}
}