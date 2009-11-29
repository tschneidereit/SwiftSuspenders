package  org.swiftsuspenders.injectionpoints
{
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;
	
	import org.flexunit.Assert;
	import org.swiftsuspenders.InjectionConfig;
	import org.swiftsuspenders.InjectionType;
	import org.swiftsuspenders.Injector;
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
			var injectee:TwoParametersMethodInjectee = new TwoParametersMethodInjectee()
			var injector:Injector = new Injector();
			var injectionPoint:MethodInjectionPoint = createTwoPropertySingletonClazzAndInterfaceMethodInjectionPoint();
			
			injectionPoint.applyInjection(injectee);
			
			return injectee;
		}

		private function createTwoPropertySingletonClazzAndInterfaceMethodInjectionPoint():MethodInjectionPoint
		{
			var node:XML = XML(InjectionNodes.METHOD_SET_DEPENDENCIES_INJECTION_NODE_TWO_PARAMETER.metadata);
			var mappings:Dictionary = createUnamedTwoPropertyPropertySingletonInjectionConfigDictionary();
			var injectionPoint:MethodInjectionPoint = new MethodInjectionPoint(node, mappings);
			return injectionPoint;
		}
		
		private function applyMethodInjectionToOneRequiredOneOptionalPropertyIntoMethod():OneRequiredOneOptionalPropertyMethodInjectee
		{
			var injectee:OneRequiredOneOptionalPropertyMethodInjectee = new OneRequiredOneOptionalPropertyMethodInjectee();
			var injectionPoint:MethodInjectionPoint = createOneRequiredOneOptionalPropertySingletonClazzAndInterfaceMethodInjectionPoint();
			
			injectionPoint.applyInjection(injectee);
			
			return injectee;
		}

		private function createOneRequiredOneOptionalPropertySingletonClazzAndInterfaceMethodInjectionPoint():MethodInjectionPoint
		{
			var node:XML = XML(InjectionNodes.METHOD_SET_DEPENDENCIES_INJECTION_NODE_ONE_REQUIRED_ONE_OPTIONAL_PARAMETER.metadata);
			var mappings:Dictionary = createUnnamedPropertySingletonInjectionConfigDictionary();
			var injectionPoint:MethodInjectionPoint = new MethodInjectionPoint(node, mappings);
			return injectionPoint;
		}
		
		private function createUnamedTwoPropertyPropertySingletonInjectionConfigDictionary():Dictionary
		{
			var injector:Injector = new Injector();
			var singletons:Dictionary = new Dictionary();
			var configDictionary:Dictionary = new Dictionary();
			var config_clazz : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionType.SINGLETON, "", injector, singletons);
			var config_interface : InjectionConfig = new InjectionConfig(
				Interface, Clazz, InjectionType.SINGLETON, "", injector, singletons);
			var fqcn_clazz:String = getQualifiedClassName(Clazz);
			var fqcn_interface:String = getQualifiedClassName(Interface);
			
			configDictionary[fqcn_clazz] = config_clazz;
			configDictionary[fqcn_interface] = config_interface;
			
			return configDictionary;
		}
		
		private function createUnnamedPropertySingletonInjectionConfigDictionary():Dictionary
		{
			var injector:Injector = new Injector();
			var singletons:Dictionary = new Dictionary();
			var configDictionary:Dictionary = new Dictionary();
			var config_clazz : InjectionConfig = new InjectionConfig(
				Clazz, Clazz, InjectionType.SINGLETON, "", injector, singletons);
			var fqcn_clazz:String = getQualifiedClassName(Clazz);
			
			configDictionary[fqcn_clazz] = config_clazz;
			
			return configDictionary;
		}
	}
}