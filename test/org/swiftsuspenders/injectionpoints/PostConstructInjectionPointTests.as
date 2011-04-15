package  org.swiftsuspenders.injectionpoints
{
	import org.flexunit.Assert;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.injectees.PostConstructClosureInjectee;
	import org.swiftsuspenders.support.injectees.InjectedPostConstructClosureInjectee;

	public class PostConstructInjectionPointTests
	{
		[After]
		public function teardown():void
		{
			Injector.purgeInjectionPointsCache();
		}
		
		[Test]
		public function invokeXMLConfiguredPostConstructMethod():void
		{
			var injectee:ClassInjectee = applyPostConstructToClassInjectee();
			
			Assert.assertTrue(injectee.someProperty);
		}

		[Test]
		public function invokePostConstructClosure():void
		{
			var injectee:PostConstructClosureInjectee = new PostConstructClosureInjectee();
			var injector:Injector = new Injector();
			injector.injectInto(injectee);
			Assert.assertTrue(injectee.someProperty);
		}	

		[Test]
		public function postConstructCanBeInjected():void
		{
			var postConstruct:Function = function():void
			{
				this.someProperty = true;
			}
			var injectee:InjectedPostConstructClosureInjectee = new InjectedPostConstructClosureInjectee();
			var injector:Injector = new Injector();
			injector.mapValue(Function, postConstruct);
			injector.injectInto(injectee);
			Assert.assertTrue(injectee.someProperty);
			
		}
		private function applyPostConstructToClassInjectee():ClassInjectee
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var injector:Injector = new Injector(
				<types>
					<type name='org.swiftsuspenders.support.injectees::ClassInjectee'>
						<postconstruct name='doSomeStuff' order='1'/>
					</type>
				</types>);
			injector.injectInto(injectee);
			
			return injectee;
		}
	}
}