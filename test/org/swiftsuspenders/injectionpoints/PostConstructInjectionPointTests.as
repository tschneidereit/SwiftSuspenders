package  org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.flexunit.Assert;
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.InjectionType;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.nodes.InjectionNodes;
	import org.swiftsuspenders.support.types.Clazz;
	
	public class PostConstructInjectionPointTests
	{
		[Test]
		public function invokeXMLConfiguredPostConstructMethod():void
		{
			var injectee:ClassInjectee = applyPostConstructToClassInjectee();
			
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