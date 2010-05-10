package  org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.flexunit.Assert;
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.InjectionType;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.injectionresults.InjectSingletonResult;
	import org.swiftsuspenders.support.injectees.OneRequiredOneOptionalPropertyMethodInjectee;
	import org.swiftsuspenders.support.injectees.TwoParametersMethodInjectee;
	import org.swiftsuspenders.support.nodes.InjectionNodes;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.Interface;

	public class MethodInjectionPointTest
	{
		[Test]
		public function injectionOfTwoUnnamedPropertiesIntoMethod():void
		{
			var injectee:TwoParametersMethodInjectee = applyMethodInjectionToUnnamedTwoParameterInjectee();
			
			Assert.assertTrue("dependency 1 should be Clazz instance", injectee.getDependency() is Clazz);		
			Assert.assertTrue("dependency 2 should be Interface", injectee.getDependency2() is Interface);	
		}
		[Test]
		public function injectionOfOneRequiredOneOptionalPropertyIntoMethod():void
		{
			var injectee:OneRequiredOneOptionalPropertyMethodInjectee = applyMethodInjectionToOneRequiredOneOptionalPropertyIntoMethod();
			
			Assert.assertTrue("dependency 1 should be Clazz instance", injectee.getDependency() is Clazz);		
			Assert.assertTrue("dependency 2 should be null", injectee.getDependency2() == null);	
		}
		
		private function applyMethodInjectionToUnnamedTwoParameterInjectee():TwoParametersMethodInjectee
		{
			var injectee:TwoParametersMethodInjectee = new TwoParametersMethodInjectee();
			var injector:Injector = new Injector();
			var injectionPoint:MethodInjectionPoint = createTwoPropertySingletonClazzAndInterfaceMethodInjectionPoint();
			
			injectionPoint.applyInjection(injectee, injector);
			
			return injectee;
		}

		private function createTwoPropertySingletonClazzAndInterfaceMethodInjectionPoint():MethodInjectionPoint
		{
			var node:XML = XML(InjectionNodes.METHOD_SET_DEPENDENCIES_INJECTION_NODE_TWO_PARAMETER.metadata);
			var injector : Injector = createUnnamedTwoPropertyPropertySingletonInjectionInjector();
			var injectionPoint:MethodInjectionPoint = new MethodInjectionPoint(node, injector);
			return injectionPoint;
		}
		
		private function applyMethodInjectionToOneRequiredOneOptionalPropertyIntoMethod():OneRequiredOneOptionalPropertyMethodInjectee
		{
			var injector:Injector = new Injector();
			var injectee:OneRequiredOneOptionalPropertyMethodInjectee = new OneRequiredOneOptionalPropertyMethodInjectee();
			var injectionPoint:MethodInjectionPoint = createOneRequiredOneOptionalPropertySingletonClazzAndInterfaceMethodInjectionPoint();
			
			injectionPoint.applyInjection(injectee, injector);
			
			return injectee;
		}

		private function createOneRequiredOneOptionalPropertySingletonClazzAndInterfaceMethodInjectionPoint():MethodInjectionPoint
		{
			var node:XML = XML(InjectionNodes.METHOD_SET_DEPENDENCIES_INJECTION_NODE_ONE_REQUIRED_ONE_OPTIONAL_PARAMETER.metadata);
			var injector : Injector = createUnnamedPropertySingletonInjectionInjector();
			var injectionPoint:MethodInjectionPoint = new MethodInjectionPoint(node, injector);
			return injectionPoint;
		}
		
		private function createUnnamedTwoPropertyPropertySingletonInjectionInjector() : Injector
		{
			var injector:Injector = new Injector();
			injector.mapSingleton(Clazz);
			injector.mapSingletonOf(Interface, Clazz);
			
			return injector;
		}
		
		private function createUnnamedPropertySingletonInjectionInjector() : Injector
		{
			var injector:Injector = new Injector();
			injector.mapSingleton(Clazz);
			
			return injector;
		}
	}
}