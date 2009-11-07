package  org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.flexunit.Assert;
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.InjectionType;
	import org.swiftsuspenders.Injector;
	import org.swiftsuspenders.support.injectees.TwoParametersMethodInjectee;
	import org.swiftsuspenders.support.nodes.InjectionNodes;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.Interface;

	public class MethodInjectionPointTest
	{
		[Test]
		public function injectionOfTwoUnnamedPropertiesIntoMethod():void
		{
			var injectee:TwoParametersMethodInjectee = applyMethodInjectionToUnamedTwoParameterInjectee()
			
			Assert.assertTrue("dependency 1 should be Clazz instance", injectee.getDependency() is Clazz);		
			Assert.assertTrue("dependency 2 should be Interface", injectee.getDependency2() is Interface);	
		}
		
		private function applyMethodInjectionToUnamedTwoParameterInjectee():TwoParametersMethodInjectee
		{
			var injectee:TwoParametersMethodInjectee = new TwoParametersMethodInjectee()
			var injector:Injector = new Injector();
			var injectionPoint:MethodInjectionPoint = createTwoPropertySingletonClazzAndInterfaceMethodInjectionPoint();
			var singletons:Dictionary = new Dictionary();
			
			injectionPoint.applyInjection(injectee, injector, singletons);
			
			return injectee;
		}

		private function createTwoPropertySingletonClazzAndInterfaceMethodInjectionPoint():MethodInjectionPoint
		{
			var node:XML = XML(InjectionNodes.METHOD_SET_DEPENDENCIES_INJECTION_NODE_TWO_PARAMETER.metadata);
			var mappings:Dictionary = createUnamedTwoPropertyPropertySingletonInjectionConfigDictionary();
			var injectionPoint:MethodInjectionPoint = new MethodInjectionPoint(node, mappings);
			return injectionPoint;
		}
		
		private function createUnamedTwoPropertyPropertySingletonInjectionConfigDictionary():Dictionary
		{
			var configDictionary:Dictionary = new Dictionary();
			var config_clazz : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionType.SINGLETON, "");
			var config_interface : InjectionConfig = new InjectionConfig(
				Interface, Clazz, InjectionType.SINGLETON, "");
			var fqcn_clazz:String = getQualifiedClassName(Clazz);
			var fqcn_interface:String = getQualifiedClassName(Interface);
			
			configDictionary[fqcn_clazz] = config_clazz;
			configDictionary[fqcn_interface] = config_interface;
			
			return configDictionary;
		}
	}
}