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

package org.swiftsuspenders
{
	import flexunit.framework.Assert;
	
	import mx.collections.ArrayCollection;
	
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.injectees.ComplexClassInjectee;
	import org.swiftsuspenders.support.injectees.InterfaceInjectee;
	import org.swiftsuspenders.support.injectees.MixedParametersConstructorInjectee;
	import org.swiftsuspenders.support.injectees.MixedParametersMethodInjectee;
	import org.swiftsuspenders.support.injectees.MultipleNamedSingletonsOfSameClassInjectee;
	import org.swiftsuspenders.support.injectees.MultipleSingletonsOfSameClassInjectee;
	import org.swiftsuspenders.support.injectees.NamedArrayCollectionInjectee;
	import org.swiftsuspenders.support.injectees.NamedClassInjectee;
	import org.swiftsuspenders.support.injectees.NamedInterfaceInjectee;
	import org.swiftsuspenders.support.injectees.OneNamedParameterConstructorInjectee;
	import org.swiftsuspenders.support.injectees.OneNamedParameterMethodInjectee;
	import org.swiftsuspenders.support.injectees.OneParameterConstructorInjectee;
	import org.swiftsuspenders.support.injectees.OneParameterMethodInjectee;
	import org.swiftsuspenders.support.injectees.OrderedPostConstructInjectee;
	import org.swiftsuspenders.support.injectees.RecursiveInterfaceInjectee;
	import org.swiftsuspenders.support.injectees.SetterInjectee;
	import org.swiftsuspenders.support.injectees.StringInjectee;
	import org.swiftsuspenders.support.injectees.TwoNamedInterfaceFieldsInjectee;
	import org.swiftsuspenders.support.injectees.TwoNamedParametersConstructorInjectee;
	import org.swiftsuspenders.support.injectees.TwoNamedParametersMethodInjectee;
	import org.swiftsuspenders.support.injectees.TwoParametersConstructorInjectee;
	import org.swiftsuspenders.support.injectees.TwoParametersMethodInjectee;
	import org.swiftsuspenders.support.injectees.XMLInjectee;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.Clazz2;
	import org.swiftsuspenders.support.types.ComplexClazz;
	import org.swiftsuspenders.support.types.Interface;
	import org.swiftsuspenders.support.types.Interface2;
	
	public class InjectorTests
	{
		protected var injector:Injector;
		
		[Before]
		public function runBeforeEachTest():void
		{
			injector = new Injector();
		}
		
		[Test]
		public function unbind():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var value:Clazz = new Clazz();
			injector.mapValue(Clazz, value);
			injector.unmap(Clazz);
			try
			{
				injector.injectInto(injectee);
			}
			catch(e:Error)
			{
			}
			Assert.assertEquals("Property should not be injected", null, injectee.property);
		}
		
		[Test]
		public function bindValue():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var injectee2:ClassInjectee = new ClassInjectee();
			var value:Clazz = new Clazz();
			injector.mapValue(Clazz, value);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Value should have been injected", value, injectee.property );
			injector.injectInto(injectee2);
			Assert.assertStrictlyEquals("Injected values should be equal", injectee.property, injectee2.property );
		}
		
		[Test]
		public function bindValueByInterface():void
		{
			var injectee:InterfaceInjectee = new InterfaceInjectee();
			var value:Interface = new Clazz();
			injector.mapValue(Interface, value);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Value should have been injected", value, injectee.property );
		}
		
		[Test]
		public function bindNamedValue():void
		{
			var injectee:NamedClassInjectee = new NamedClassInjectee();
			var value:Clazz = new Clazz();
			injector.mapValue(Clazz, value, NamedClassInjectee.NAME);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Named value should have been injected", value, injectee.property );
		}

		[Test]
		public function bindNamedValueByInterface():void
		{
			var injectee:NamedInterfaceInjectee = new NamedInterfaceInjectee();
			var value:Interface = new Clazz();
			injector.mapValue(Interface, value, NamedClassInjectee.NAME);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Named value should have been injected", value, injectee.property );
		}

		[Test]
		public function bindFalsyValue():void
		{
			var injectee:StringInjectee = new StringInjectee();
			var value:String = '';
			injector.mapValue(String, value);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Value should have been injected", value, injectee.property );
		}

		[Test]
		public function boundValueIsNotInjectedInto() : void
		{
			var injectee:RecursiveInterfaceInjectee = new RecursiveInterfaceInjectee();
			var value:InterfaceInjectee = new InterfaceInjectee();
			injector.mapValue(InterfaceInjectee, value);
			injector.injectInto(injectee);
			Assert.assertNull('value shouldn\'t have been injected into', value.property);
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
		
		[Test]
		public function bindClass():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var injectee2:ClassInjectee = new ClassInjectee();
			injector.mapClass(Clazz, Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected", injectee.property );
			injector.injectInto(injectee2);
			Assert.assertFalse("Injected values should be different", injectee.property == injectee2.property );
		}

		[Test]
		public function boundClassIsInjectedInto():void
		{
			var injectee:ComplexClassInjectee = new ComplexClassInjectee();
			var value:Clazz = new Clazz();
			injector.mapValue(Clazz, value);
			injector.mapClass(ComplexClazz, ComplexClazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Complex Value should have been injected", injectee.property  );
			Assert.assertStrictlyEquals("Nested value should have been injected", value, injectee.property.value );
		}
		
		[Test]
		public function bindClassByInterface():void
		{
			var injectee:InterfaceInjectee = new InterfaceInjectee();
			injector.mapClass(Interface, Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected", injectee.property );
		}
		
		[Test]
		public function bindNamedClass():void
		{
			var injectee:NamedClassInjectee = new NamedClassInjectee();
			injector.mapClass(Clazz, Clazz, NamedClassInjectee.NAME);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of named Class should have been injected", injectee.property );
		}
		
		[Test]
		public function bindNamedClassByInterface():void
		{
			var injectee:NamedInterfaceInjectee = new NamedInterfaceInjectee();
			injector.mapClass(Interface, Clazz, NamedClassInjectee.NAME);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of named Class should have been injected", injectee.property );
		}
		
		[Test]
		public function bindSingleton():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var injectee2:ClassInjectee = new ClassInjectee();
			injector.mapSingleton(Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected", injectee.property );
			injector.injectInto(injectee2);
			Assert.assertStrictlyEquals("Injected values should be equal", injectee.property, injectee2.property );
		}
		
		[Test]
		public function bindSingletonOf():void
		{
			var injectee:InterfaceInjectee = new InterfaceInjectee();
			var injectee2:InterfaceInjectee = new InterfaceInjectee();
			injector.mapSingletonOf(Interface, Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected", injectee.property );
			injector.injectInto(injectee2);
			Assert.assertStrictlyEquals("Injected values should be equal", injectee.property, injectee2.property );
		}
		
		[Test]
		public function bindDifferentlyNamedSingletonsBySameInterface():void
		{
			var injectee:TwoNamedInterfaceFieldsInjectee = new TwoNamedInterfaceFieldsInjectee();
			injector.mapSingletonOf(Interface, Clazz, 'Name1');
			injector.mapSingletonOf(Interface, Clazz2, 'Name2');
			injector.injectInto(injectee);
			Assert.assertTrue('Property "property1" should be of type "Clazz"', injectee.property1 is Clazz);
			Assert.assertTrue('Property "property2" should be of type "Clazz2"', injectee.property2 is Clazz2);
			Assert.assertFalse('Properties "property1" and "property2" should have received different singletons', injectee.property1 == injectee.property2);
		}
		
		[Test]
		public function performSetterInjection():void
		{
			var injectee:SetterInjectee = new SetterInjectee();
			var injectee2:SetterInjectee = new SetterInjectee();
			injector.mapClass(Clazz, Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected", injectee.property );
			injector.injectInto(injectee2);
			Assert.assertFalse("Injected values should be different", injectee.property == injectee2.property );
		}
		
		[Test]
		public function performMethodInjectionWithOneParameter():void
		{
			var injectee:OneParameterMethodInjectee = new OneParameterMethodInjectee();
			var injectee2:OneParameterMethodInjectee = new OneParameterMethodInjectee();
			injector.mapClass(Clazz, Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected", injectee.getDependency() );
			injector.injectInto(injectee2);
			Assert.assertFalse("Injected values should be different", injectee.getDependency() == injectee2.getDependency() );
		}
		
		[Test]
		public function performMethodInjectionWithOneNamedParameter():void
		{
			var injectee:OneNamedParameterMethodInjectee = new OneNamedParameterMethodInjectee();
			var injectee2:OneNamedParameterMethodInjectee = new OneNamedParameterMethodInjectee();
			injector.mapClass(Clazz, Clazz, 'namedDep');
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
			injector.injectInto(injectee2);
			Assert.assertFalse("Injected values should be different", injectee.getDependency() == injectee2.getDependency() );
		}
		
		[Test]
		public function performMethodInjectionWithTwoParameters():void
		{
			var injectee:TwoParametersMethodInjectee = new TwoParametersMethodInjectee();
			var injectee2:TwoParametersMethodInjectee = new TwoParametersMethodInjectee();
			injector.mapClass(Clazz, Clazz);
			injector.mapClass(Interface, Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected for unnamed Clazz parameter", injectee.getDependency() );
			Assert.assertNotNull("Instance of Class should have been injected for unnamed Interface parameter", injectee.getDependency2() );
			injector.injectInto(injectee2);
			Assert.assertFalse("Injected values should be different", injectee.getDependency() == injectee2.getDependency() );
			Assert.assertFalse("Injected values for Interface should be different", injectee.getDependency2() == injectee2.getDependency2() );
		}
		
		[Test]
		public function performMethodInjectionWithTwoNamedParameters():void
		{
			var injectee:TwoNamedParametersMethodInjectee = new TwoNamedParametersMethodInjectee();
			var injectee2:TwoNamedParametersMethodInjectee = new TwoNamedParametersMethodInjectee();
			injector.mapClass(Clazz, Clazz, 'namedDep');
			injector.mapClass(Interface, Clazz, 'namedDep2');
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
			Assert.assertNotNull("Instance of Class should have been injected for  for named Interface parameter", injectee.getDependency2() );
			injector.injectInto(injectee2);
			Assert.assertFalse("Injected values should be different", injectee.getDependency() == injectee2.getDependency() );
			Assert.assertFalse("Injected values for Interface should be different", injectee.getDependency2() == injectee2.getDependency2() );
		}
		
		[Test]
		public function performMethodInjectionWithMixedParameters():void
		{
			var injectee:MixedParametersMethodInjectee = new MixedParametersMethodInjectee();
			var injectee2:MixedParametersMethodInjectee = new MixedParametersMethodInjectee();
			injector.mapClass(Clazz, Clazz, 'namedDep');
			injector.mapClass(Clazz, Clazz);
			injector.mapClass(Interface, Clazz, 'namedDep2');
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
			Assert.assertNotNull("Instance of Class should have been injected for unnamed Clazz parameter", injectee.getDependency2() );
			Assert.assertNotNull("Instance of Class should have been injected for Interface", injectee.getDependency3() );
			injector.injectInto(injectee2);
			Assert.assertFalse("Injected values for named Clazz should be different", injectee.getDependency() == injectee2.getDependency() );
			Assert.assertFalse("Injected values for unnamed Clazz should be different", injectee.getDependency2() == injectee2.getDependency2() );
			Assert.assertFalse("Injected values for named Interface should be different", injectee.getDependency3() == injectee2.getDependency3() );
		}
		
		[Test]
		public function performConstructorInjectionWithOneParameter():void
		{
			injector.mapClass(Clazz, Clazz);
			var injectee:OneParameterConstructorInjectee = injector.instantiate(OneParameterConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for Clazz parameter", injectee.getDependency() );
		}
		
		[Test]
		public function performConstructorInjectionWithTwoParameters():void
		{
			injector.mapClass(Clazz, Clazz);
			injector.mapValue(String, 'stringDependency');
			var injectee:TwoParametersConstructorInjectee = injector.instantiate(TwoParametersConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency());
			Assert.assertEquals("The String 'stringDependency' should have been injected for String parameter", injectee.getDependency2(), 'stringDependency');
		}
		
		[Test]
		public function performConstructorInjectionWithOneNamedParameter():void
		{
			injector.mapClass(Clazz, Clazz, 'namedDependency');
			var injectee:OneNamedParameterConstructorInjectee = injector.instantiate(OneNamedParameterConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
		}
		
		[Test]
		public function performXMLConfiguredConstructorInjectionWithOneNamedParameter():void
		{
			var diConfig:XML =
				<types>
					<type name='org.swiftsuspenders.support.injectees::OneNamedParameterConstructorInjectee'>
						<constructor>
							<arg injectionname="namedDependency" />
						</constructor>
					</type>
				</types>;
			injector = new Injector(diConfig);
			injector.mapClass(Clazz, Clazz, 'namedDependency');
			var injectee:OneNamedParameterConstructorInjectee = injector.instantiate(OneNamedParameterConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
		}
		
		[Test]
		public function performConstructorInjectionWithTwoNamedParameter():void
		{
			injector.mapClass(Clazz, Clazz, 'namedDependency');
			injector.mapValue(String, 'stringDependency', 'namedDependency2');
			var injectee:TwoNamedParametersConstructorInjectee = injector.instantiate(TwoNamedParametersConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency());
			Assert.assertEquals("The String 'stringDependency' should have been injected for named String parameter", injectee.getDependency2(), 'stringDependency');
		}
		
		[Test]
		public function performConstructorInjectionWithMixedParameters():void
		{
			injector.mapClass(Clazz, Clazz, 'namedDep');
			injector.mapClass(Clazz, Clazz);
			injector.mapClass(Interface, Clazz, 'namedDep2');
			var injectee:MixedParametersConstructorInjectee = injector.instantiate(MixedParametersConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
			Assert.assertNotNull("Instance of Class should have been injected for unnamed Clazz parameter", injectee.getDependency2() );
			Assert.assertNotNull("Instance of Class should have been injected for Interface", injectee.getDependency3() );
		}
		
		[Test]
		public function performNamedArrayInjection():void
		{
			var ac : ArrayCollection = new ArrayCollection();
			injector.mapValue(ArrayCollection, ac, "namedCollection");
			var injectee:NamedArrayCollectionInjectee = injector.instantiate(NamedArrayCollectionInjectee);
			Assert.assertNotNull("Instance 'ac' should have been injected for named ArrayCollection parameter", injectee.ac );
			Assert.assertEquals("Instance field 'ac' should be identical to local variable 'ac'", ac, injectee.ac);
		}
		
		[Test]
		public function performMappedRuleInjection():void
		{
			var rule : InjectionConfig = injector.mapSingletonOf(Interface, Clazz);
			injector.mapRule(Interface2, rule);
			var injectee:MultipleSingletonsOfSameClassInjectee = injector.instantiate(MultipleSingletonsOfSameClassInjectee);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'property2'", injectee.property1, injectee.property2);
		}
		
		[Test]
		public function performMappedNamedRuleInjection():void
		{
			var rule : InjectionConfig = injector.mapSingletonOf(Interface, Clazz);
			injector.mapRule(Interface2, rule);
			injector.mapRule(Interface, rule, 'name1');
			injector.mapRule(Interface2, rule, 'name2');
			var injectee:MultipleNamedSingletonsOfSameClassInjectee = injector.instantiate(MultipleNamedSingletonsOfSameClassInjectee);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'property2'", injectee.property1, injectee.property2);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'namedProperty1'", injectee.property1, injectee.namedProperty1);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'namedProperty2'", injectee.property1, injectee.namedProperty2);
		}
		
		[Test]
		public function performInjectionIntoValueWithRecursiveSingeltonDependency():void
		{
			var valueInjectee : InterfaceInjectee = new InterfaceInjectee();
			injector.mapValue(InterfaceInjectee, valueInjectee);
			injector.mapSingletonOf(Interface, RecursiveInterfaceInjectee);
			
			injector.injectInto(valueInjectee);
//			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'property2'", injectee.property1, injectee.property2);
//			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'namedProperty1'", injectee.property1, injectee.namedProperty1);
//			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'namedProperty2'", injectee.property1, injectee.namedProperty2);
		}

		[Test]
		public function injectXMLValue() : void
		{
			var injectee : XMLInjectee = new XMLInjectee();
			var value : XML = <test/>;
			injector.mapValue(XML, value);
			injector.injectInto(injectee);
			Assert.assertEquals('injected value should be indentical to mapped value', injectee.property, value);
		}
		
		[Test(expects="org.swiftsuspenders.InjectorError")]
		public function haltOnMissingDependency():void
		{
			var injectee:InterfaceInjectee = new InterfaceInjectee();
			injector.injectInto(injectee);
		}
		
		[Test(expects="org.swiftsuspenders.InjectorError")]
		public function haltOnMissingNamedDependency():void
		{
			var injectee:NamedClassInjectee = new NamedClassInjectee();
			injector.injectInto(injectee);
		}
		
		[Test]
		public function postConstructIsCalled():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var value:Clazz = new Clazz();
			injector.mapValue(Clazz, value);
			injector.injectInto(injectee);
				
			Assert.assertTrue(injectee.someProperty);
		}

		[Test]
		public function postConstructMethodsCalledAsOrdered():void
		{
			var injectee:OrderedPostConstructInjectee = new OrderedPostConstructInjectee();
			injector.injectInto(injectee);

			Assert.assertTrue(injectee.loadedAsOrdered);
		}

		[Test]
		public function hasMappingFailsForUnmappedUnnamedClass():void
		{
			Assert.assertFalse(injector.hasMapping(Clazz));
		}

		[Test]
		public function hasMappingFailsForUnmappedNamedClass():void
		{
			Assert.assertFalse(injector.hasMapping(Clazz, 'namedClass'));
		}

		[Test]
		public function hasMappingSucceedsForMappedUnnamedClass():void
		{
			injector.mapClass(Clazz, Clazz);
			Assert.assertTrue(injector.hasMapping(Clazz));
		}

		[Test]
		public function hasMappingSucceedsForMappedNamedClass():void
		{
			injector.mapClass(Clazz, Clazz, 'namedClass');
			Assert.assertTrue(injector.hasMapping(Clazz, 'namedClass'));
		}

		[Test(expects="org.swiftsuspenders.InjectorError")]
		public function getMappingResponseFailsForUnmappedUnnamedClass():void
		{
			Assert.assertNull(injector.getInstance(Clazz));
		}

		[Test(expects="org.swiftsuspenders.InjectorError")]
		public function getMappingResponseFailsForUnmappedNamedClass():void
		{
			Assert.assertNull(injector.getInstance(Clazz, 'namedClass'));
		}

		[Test]
		public function getMappingResponseSucceedsForMappedUnnamedClass():void
		{
			var clazz : Clazz = new Clazz();
			injector.mapValue(Clazz, clazz);
			Assert.assertObjectEquals(injector.getInstance(Clazz), clazz);
		}

		[Test]
		public function getMappingResponseSucceedsForMappedNamedClass():void
		{
			var clazz : Clazz = new Clazz();
			injector.mapValue(Clazz, clazz, 'namedClass');
			Assert.assertObjectEquals(injector.getInstance(Clazz, 'namedClass'), clazz);
		}

		[Test]
		public function injectorRemovesSingletonInstanceOnRuleRemoval() : void
		{
			injector.mapSingleton(Clazz);
			var injectee1 : ClassInjectee = injector.instantiate(ClassInjectee);
			injector.unmap(Clazz);
			injector.mapSingleton(Clazz);
			var injectee2 : ClassInjectee = injector.instantiate(ClassInjectee);
			Assert.assertFalse('injectee1.property is not the same instance as injectee2.property',
				injectee1.property == injectee2.property);
		}
	}
}