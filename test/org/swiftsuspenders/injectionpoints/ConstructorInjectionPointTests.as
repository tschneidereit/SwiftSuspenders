package  org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.flexunit.Assert;
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.injectionresults.InjectSingletonResult;
	import org.swiftsuspenders.injectionresults.InjectValueResult;
	import org.swiftsuspenders.support.injectees.TwoOptionalParametersConstructorInjectee;
	import org.swiftsuspenders.support.injectees.TwoParametersConstructorInjectee;
	import org.swiftsuspenders.support.nodes.InjectionNodes;
	import org.swiftsuspenders.support.types.Clazz;
	
	public class ConstructorInjectionPointTests
	{
		public static const STRING_REFERENCE:String = "stringReference";
		
		[Test]
		public function injectionOfTwoUnnamedPropertiesIntoConstructor():void
		{
			var injector:Injector = new Injector();
			injector.mapSingleton(Clazz);
			injector.mapValue(String, STRING_REFERENCE);
			
			var node : XML = XML(InjectionNodes.CONSTRUCTOR_INJECTION_NODE_TWO_ARGUMENT.constructor);
			var injectionPoint:ConstructorInjectionPoint = 
				new ConstructorInjectionPoint(node, TwoParametersConstructorInjectee, injector);
			
			var injectee:TwoParametersConstructorInjectee = 
				injectionPoint.applyInjection(TwoParametersConstructorInjectee, injector) as TwoParametersConstructorInjectee;
			
			Assert.assertTrue("dependency 1 should be Clazz instance", injectee.getDependency() is Clazz);		
			Assert.assertTrue("dependency 2 should be 'stringReference'", injectee.getDependency2() == STRING_REFERENCE);	
		}
		
		[Test]
		public function injectionOfFirstOptionalPropertyIntoTwoOptionalParametersConstructor():void
		{
			var injector:Injector = new Injector();
			injector.mapSingleton(Clazz);
			
			var node:XML = XML(InjectionNodes.CONSTRUCTOR_INJECTION_NODE_TWO_OPTIONAL_PARAMETERS.constructor);
			var injectionPoint:ConstructorInjectionPoint = new ConstructorInjectionPoint(node, TwoParametersConstructorInjectee, injector);
			
			var injectee:TwoOptionalParametersConstructorInjectee = 
				injectionPoint.applyInjection(TwoOptionalParametersConstructorInjectee, injector) as TwoOptionalParametersConstructorInjectee;
			
			
			Assert.assertTrue("dependency 1 should be Clazz instance", injectee.getDependency() is Clazz);		
			Assert.assertTrue("dependency 2 should be null", injectee.getDependency2() == null);	
		}
		
		[Test]
		public function injectionOfSecondOptionalPropertyIntoTwoOptionalParametersConstructor():void
		{
			var injector:Injector = new Injector();
			injector.mapValue(String, STRING_REFERENCE);
			
			var node:XML = XML(InjectionNodes.CONSTRUCTOR_INJECTION_NODE_TWO_OPTIONAL_PARAMETERS.constructor);
			var injectionPoint:ConstructorInjectionPoint = new ConstructorInjectionPoint(node, TwoParametersConstructorInjectee, injector);
			
			var injectee:TwoOptionalParametersConstructorInjectee = 
				injectionPoint.applyInjection(TwoOptionalParametersConstructorInjectee, injector) as TwoOptionalParametersConstructorInjectee;
			
			
			Assert.assertTrue("dependency 1 should be Clazz null", injectee.getDependency() == null);		
			Assert.assertTrue("dependency 2 should be null", injectee.getDependency2() == null);	
		}
	}
}