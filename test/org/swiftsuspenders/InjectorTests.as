/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.events.Event;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import flexunit.framework.Assert;

	import mx.collections.ArrayCollection;

	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.core.isA;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasPropertyWithValue;
	import org.hamcrest.object.isTrue;
	import org.swiftsuspenders.dependencyproviders.OtherMappingProvider;
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.injectees.ComplexClassInjectee;
	import org.swiftsuspenders.support.injectees.InterfaceInjectee;
	import org.swiftsuspenders.support.injectees.MixedParametersConstructorInjectee;
	import org.swiftsuspenders.support.injectees.MixedParametersMethodInjectee;
	import org.swiftsuspenders.support.injectees.MultipleNamedSingletonsOfSameClassInjectee;
	import org.swiftsuspenders.support.injectees.MultipleSingletonsOfSameClassInjectee;
	import org.swiftsuspenders.support.injectees.NamedArrayCollectionInjectee;
	import org.swiftsuspenders.support.injectees.NamedClassInjectee;
	import org.swiftsuspenders.support.injectees.NamedClassInjectee;
	import org.swiftsuspenders.support.injectees.NamedInterfaceInjectee;
	import org.swiftsuspenders.support.injectees.OneNamedParameterConstructorInjectee;
	import org.swiftsuspenders.support.injectees.OneNamedParameterMethodInjectee;
	import org.swiftsuspenders.support.injectees.OneParameterConstructorInjectee;
	import org.swiftsuspenders.support.injectees.OneParameterMethodInjectee;
	import org.swiftsuspenders.support.injectees.OptionalClassInjectee;
	import org.swiftsuspenders.support.injectees.OptionalOneRequiredParameterMethodInjectee;
	import org.swiftsuspenders.support.injectees.OrderedPostConstructInjectee;
	import org.swiftsuspenders.support.injectees.PostConstructInjectedVarInjectee;
	import org.swiftsuspenders.support.injectees.PostConstructWithArgInjectee;
	import org.swiftsuspenders.support.injectees.RecursiveInterfaceInjectee;
	import org.swiftsuspenders.support.injectees.SetterInjectee;
	import org.swiftsuspenders.support.injectees.StringInjectee;
	import org.swiftsuspenders.support.injectees.TwoNamedInterfaceFieldsInjectee;
	import org.swiftsuspenders.support.injectees.TwoNamedParametersConstructorInjectee;
	import org.swiftsuspenders.support.injectees.TwoNamedParametersMethodInjectee;
	import org.swiftsuspenders.support.injectees.TwoParametersConstructorInjectee;
	import org.swiftsuspenders.support.injectees.TwoParametersMethodInjectee;
	import org.swiftsuspenders.support.injectees.UnknownInjectParametersListInjectee;
	import org.swiftsuspenders.support.injectees.XMLInjectee;
	import org.swiftsuspenders.support.providers.UnknownParametersUsingProvider;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.Clazz2;
	import org.swiftsuspenders.support.types.ComplexClazz;
	import org.swiftsuspenders.support.types.Interface;
	import org.swiftsuspenders.support.types.Interface2;
	import org.swiftsuspenders.typedescriptions.NoParamsConstructorInjectionPoint;
	import org.swiftsuspenders.typedescriptions.PropertyInjectionPoint;
	import org.swiftsuspenders.typedescriptions.TypeDescription;
	import org.swiftsuspenders.utils.SsInternal;

	use namespace SsInternal;

	public class InjectorTests
	{
		protected var injector:Injector;
		protected var receivedInjectorEvents : Array;
		
		[Before]
		public function runBeforeEachTest():void
		{
			injector = new Injector();
			receivedInjectorEvents = [];
		}

		[After]
		public function teardown():void
		{
			Injector.SsInternal::purgeInjectionPointsCache();
			injector = null;
			receivedInjectorEvents = null;
		}
		
		[Test]
		public function unbind():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var value:Clazz = new Clazz();
			injector.map(Clazz).toValue(value);
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
		public function injectorInjectsBoundValueIntoAllInjectees():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var injectee2:ClassInjectee = new ClassInjectee();
			var value:Clazz = new Clazz();
			injector.map(Clazz).toValue(value);
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
			injector.map(Interface).toValue(value);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Value should have been injected", value, injectee.property );
		}
		
		[Test]
		public function bindNamedValue():void
		{
			var injectee:NamedClassInjectee = new NamedClassInjectee();
			var value:Clazz = new Clazz();
			injector.map(Clazz, NamedClassInjectee.NAME).toValue(value);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Named value should have been injected", value, injectee.property );
		}

		[Test]
		public function bindNamedValueByInterface():void
		{
			var injectee:NamedInterfaceInjectee = new NamedInterfaceInjectee();
			var value:Interface = new Clazz();
			injector.map(Interface, NamedClassInjectee.NAME).toValue(value);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Named value should have been injected", value, injectee.property );
		}

		[Test]
		public function bindFalsyValue():void
		{
			var injectee:StringInjectee = new StringInjectee();
			var value:String = '';
			injector.map(String).toValue(value);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Value should have been injected", value, injectee.property );
		}

		[Test]
		public function boundValueIsNotInjectedInto() : void
		{
			var injectee:RecursiveInterfaceInjectee = new RecursiveInterfaceInjectee();
			var value:InterfaceInjectee = new InterfaceInjectee();
			injector.map(InterfaceInjectee).toValue(value);
			injector.injectInto(injectee);
			Assert.assertNull('value shouldn\'t have been injected into', value.property);
		}
		
		[Test]
		public function bindMultipleInterfacesToOneSingletonClass():void
		{
			var injectee:MultipleSingletonsOfSameClassInjectee = new MultipleSingletonsOfSameClassInjectee();
			injector.map(Interface).toSingleton(Clazz);
			injector.map(Interface2).toSingleton(Clazz);
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
			injector.map(Clazz).toType(Clazz);
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
			injector.map(Clazz).toValue(value);
			injector.map(ComplexClazz).toType(ComplexClazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Complex Value should have been injected", injectee.property  );
			Assert.assertStrictlyEquals("Nested value should have been injected", value, injectee.property.value );
		}
		
		[Test]
		public function bindClassByInterface():void
		{
			var injectee:InterfaceInjectee = new InterfaceInjectee();
			injector.map(Interface).toType(Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected", injectee.property );
		}
		
		[Test]
		public function bindNamedClass():void
		{
			var injectee:NamedClassInjectee = new NamedClassInjectee();
			injector.map(Clazz, NamedClassInjectee.NAME).toType(Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of named Class should have been injected", injectee.property );
		}
		
		[Test]
		public function bindNamedClassByInterface():void
		{
			var injectee:NamedInterfaceInjectee = new NamedInterfaceInjectee();
			injector.map(Interface, NamedClassInjectee.NAME).toType(Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of named Class should have been injected", injectee.property );
		}
		
		[Test]
		public function bindSingleton():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var injectee2:ClassInjectee = new ClassInjectee();
			injector.map(Clazz).toSingleton(Clazz);
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
			injector.map(Interface).toSingleton(Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected", injectee.property );
			injector.injectInto(injectee2);
			Assert.assertStrictlyEquals("Injected values should be equal", injectee.property, injectee2.property );
		}
		
		[Test]
		public function bindDifferentlyNamedSingletonsBySameInterface():void
		{
			var injectee:TwoNamedInterfaceFieldsInjectee = new TwoNamedInterfaceFieldsInjectee();
			injector.map(Interface, 'Name1').toSingleton(Clazz);
			injector.map(Interface, 'Name2').toSingleton(Clazz2);
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
			injector.map(Clazz).toType(Clazz);
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
			injector.map(Clazz).toType(Clazz);
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
			injector.map(Clazz, 'namedDep').toType(Clazz);
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
			injector.map(Clazz).toType(Clazz);
			injector.map(Interface).toType(Clazz);
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
			injector.map(Clazz, 'namedDep').toType(Clazz);
			injector.map(Interface, 'namedDep2').toType(Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
			Assert.assertNotNull("Instance of Class should have been injected for named Interface parameter", injectee.getDependency2() );
			injector.injectInto(injectee2);
			Assert.assertFalse("Injected values should be different", injectee.getDependency() == injectee2.getDependency() );
			Assert.assertFalse("Injected values for Interface should be different", injectee.getDependency2() == injectee2.getDependency2() );
		}
		
		[Test]
		public function performMethodInjectionWithMixedParameters():void
		{
			var injectee:MixedParametersMethodInjectee = new MixedParametersMethodInjectee();
			var injectee2:MixedParametersMethodInjectee = new MixedParametersMethodInjectee();
			injector.map(Clazz, 'namedDep').toType(Clazz);
			injector.map(Clazz).toType(Clazz);
			injector.map(Interface, 'namedDep2').toType(Clazz);
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
			injector.map(Clazz);
			var injectee:OneParameterConstructorInjectee = injector.getInstance(OneParameterConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for Clazz parameter", injectee.getDependency() );
		}
		
		[Test]
		public function performConstructorInjectionWithTwoParameters():void
		{
			injector.map(Clazz);
			injector.map(String).toValue('stringDependency');
			var injectee:TwoParametersConstructorInjectee = injector.getInstance(TwoParametersConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency());
			Assert.assertEquals("The String 'stringDependency' should have been injected for String parameter", injectee.getDependency2(), 'stringDependency');
		}
		
		[Test]
		public function performConstructorInjectionWithOneNamedParameter():void
		{
			injector.map(Clazz, 'namedDependency').toType(Clazz);
			var injectee:OneNamedParameterConstructorInjectee = injector.getInstance(OneNamedParameterConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
		}
		
		[Test]
		public function performXMLConfiguredConstructorInjectionWithOneNamedParameter():void
		{
			injector = new Injector();
			injector.map(Clazz, 'namedDependency').toType(Clazz);
			var injectee:OneNamedParameterConstructorInjectee = injector.getInstance(OneNamedParameterConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
		}
		
		[Test]
		public function performConstructorInjectionWithTwoNamedParameter():void
		{
			injector.map(Clazz, 'namedDependency').toType(Clazz);
			injector.map(String, 'namedDependency2').toValue('stringDependency');
			var injectee:TwoNamedParametersConstructorInjectee = injector.getInstance(TwoNamedParametersConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency());
			Assert.assertEquals("The String 'stringDependency' should have been injected for named String parameter", injectee.getDependency2(), 'stringDependency');
		}
		
		[Test]
		public function performConstructorInjectionWithMixedParameters():void
		{
			injector.map(Clazz, 'namedDep').toType(Clazz);
			injector.map(Clazz).toType(Clazz);
			injector.map(Interface, 'namedDep2').toType(Clazz);
			var injectee:MixedParametersConstructorInjectee = injector.getInstance(MixedParametersConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
			Assert.assertNotNull("Instance of Class should have been injected for unnamed Clazz parameter", injectee.getDependency2() );
			Assert.assertNotNull("Instance of Class should have been injected for Interface", injectee.getDependency3() );
		}
		
		[Test]
		public function performNamedArrayInjection():void
		{
			var ac : ArrayCollection = new ArrayCollection();
			injector.map(ArrayCollection, "namedCollection").toValue(ac);
			var injectee:NamedArrayCollectionInjectee = injector.getInstance(NamedArrayCollectionInjectee);
			Assert.assertNotNull("Instance 'ac' should have been injected for named ArrayCollection parameter", injectee.ac );
			Assert.assertEquals("Instance field 'ac' should be identical to local variable 'ac'", ac, injectee.ac);
		}
		
		[Test]
		public function performMappedMappingInjection():void
		{
			var mapping : InjectionMapping = injector.map(Interface);
			mapping.toSingleton(Clazz);
			injector.map(Interface2).toProvider(new OtherMappingProvider(mapping));
			var injectee:MultipleSingletonsOfSameClassInjectee = injector.getInstance(MultipleSingletonsOfSameClassInjectee);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'property2'", injectee.property1, injectee.property2);
		}
		
		[Test]
		public function performMappedNamedMappingInjection():void
		{
			var mapping : InjectionMapping = injector.map(Interface);
			mapping.toSingleton(Clazz);
			injector.map(Interface2).toProvider(new OtherMappingProvider(mapping));
			injector.map(Interface, 'name1').toProvider(new OtherMappingProvider(mapping));
			injector.map(Interface2, 'name2').toProvider(new OtherMappingProvider(mapping));
			var injectee:MultipleNamedSingletonsOfSameClassInjectee = injector.getInstance(MultipleNamedSingletonsOfSameClassInjectee);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'property2'", injectee.property1, injectee.property2);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'namedProperty1'", injectee.property1, injectee.namedProperty1);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'namedProperty2'", injectee.property1, injectee.namedProperty2);
		}
		
		[Test]
		public function performInjectionIntoValueWithRecursiveSingeltonDependency():void
		{
			var valueInjectee : InterfaceInjectee = new InterfaceInjectee();
			injector.map(InterfaceInjectee).toValue(valueInjectee);
			injector.map(Interface).toSingleton(RecursiveInterfaceInjectee);
			
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
			injector.map(XML).toValue(value);
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
			injector.map(Clazz).toValue(value);
			injector.injectInto(injectee);
				
			Assert.assertTrue(injectee.someProperty);
		}

		[Test]
		public function postConstructWithArgIsCalledCorrectly():void
		{
			injector.map(Clazz);
			var injectee:PostConstructWithArgInjectee =
				injector.getInstance(PostConstructWithArgInjectee);
			assertThat(injectee.property, isA(Clazz));
		}

		[Test]
		public function postConstructMethodsCalledAsOrdered():void
		{
			var injectee:OrderedPostConstructInjectee = new OrderedPostConstructInjectee();
			injector.injectInto(injectee);

			assertThat(injectee.loadOrder, array(1,2,3,4));
		}

		[Test]
		public function hasMappingFailsForUnmappedUnnamedClass():void
		{
			Assert.assertFalse(injector.satisfies(Clazz));
		}

		[Test]
		public function hasMappingFailsForUnmappedNamedClass():void
		{
			Assert.assertFalse(injector.satisfies(Clazz, 'namedClass'));
		}

		[Test]
		public function hasMappingSucceedsForMappedUnnamedClass():void
		{
			injector.map(Clazz).toType(Clazz);
			Assert.assertTrue(injector.satisfies(Clazz));
		}

		[Test]
		public function hasMappingSucceedsForMappedNamedClass():void
		{
			injector.map(Clazz, 'namedClass').toType(Clazz);
			Assert.assertTrue(injector.satisfies(Clazz, 'namedClass'));
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
			injector.map(Clazz).toValue(clazz);
			Assert.assertObjectEquals(injector.getInstance(Clazz), clazz);
		}

		[Test]
		public function getMappingResponseSucceedsForMappedNamedClass():void
		{
			var clazz : Clazz = new Clazz();
			injector.map(Clazz, 'namedClass').toValue(clazz);
			Assert.assertObjectEquals(injector.getInstance(Clazz, 'namedClass'), clazz);
		}

		[Test]
		public function injectorRemovesSingletonInstanceOnMappingRemoval() : void
		{
			injector.map(Clazz).toSingleton(Clazz);
			var injectee1 : ClassInjectee = injector.getInstance(ClassInjectee);
			injector.unmap(Clazz);
			injector.map(Clazz).toSingleton(Clazz);
			var injectee2 : ClassInjectee = injector.getInstance(ClassInjectee);
			Assert.assertFalse('injectee1.property is not the same instance as injectee2.property',
				injectee1.property == injectee2.property);
		}

		[Test(expects="org.swiftsuspenders.InjectorError")]
		public function instantiateThrowsMeaningfulErrorOnInterfaceInstantiation() : void
		{
			injector.getInstance(Interface);
		}

		[Test]
		public function injectorDoesntThrowWhenAttemptingUnmappedOptionalPropertyInjection() : void
		{
			var injectee : OptionalClassInjectee = injector.getInstance(OptionalClassInjectee);
			Assert.assertNull("injectee mustn\'t contain Clazz instance", injectee.property);
		}

		[Test]
		public function injectorDoesntThrowWhenAttemptingUnmappedOptionalMethodInjection() : void
		{
			var injectee : OptionalOneRequiredParameterMethodInjectee =
					injector.getInstance(OptionalOneRequiredParameterMethodInjectee);
			Assert.assertNull("injectee mustn\'t contain Clazz instance", injectee.getDependency());
		}

		[Test]
		public function softMappingIsUsedIfNoParentInjectorAvailable() : void
		{
			injector.map(Interface).toType(Clazz).soft();
			Assert.assertNotNull(injector.getInstance(Interface));
		}

		[Test]
		public function parentMappingIsUsedInsteadOfSoftChildMapping() : void
		{
			const childInjector : Injector = injector.createChildInjector();
			injector.map(Interface).toType(Clazz);
			childInjector.map(Interface).toType(Clazz2).soft();
			Assert.assertEquals(Clazz, childInjector.getInstance(Interface)['constructor']);
		}

		[Test]
		public function callingStrongTurnsSoftMappingsIntoStrongOnes() : void
		{
			const childInjector : Injector = injector.createChildInjector();
			injector.map(Interface).toType(Clazz);
			childInjector.map(Interface).toType(Clazz2).soft();
			Assert.assertEquals(Clazz, childInjector.getInstance(Interface)['constructor']);
			childInjector.map(Interface).toType(Clazz2).strong();
			Assert.assertEquals(Clazz2, childInjector.getInstance(Interface)['constructor']);
		}

		[Test]
		public function localMappingsAreUsedInOwnInjector() : void
		{
			injector.map(Interface).toType(Clazz).local();
			Assert.assertNotNull(injector.getInstance(Interface));
		}

		[Test(expects="org.swiftsuspenders.InjectorError")]
		public function localMappingsArentSharedWithChildInjectors() : void
		{
			const childInjector : Injector = injector.createChildInjector();
			injector.map(Interface).toType(Clazz).local();
			childInjector.getInstance(Interface);
		}

		[Test]
		public function callingSharedTurnsLocalMappingsIntoSharedOnes() : void
		{
			const childInjector : Injector = injector.createChildInjector();
			injector.map(Interface).toType(Clazz).local();
			injector.map(Interface).toType(Clazz).shared();
			Assert.assertNotNull(childInjector.getInstance(Interface));
		}

		[Test]
		public function injectorDispatchesPostInstantiateEventDuringInstanceConstruction() : void
		{
			assertThat(constructMappedTypeAndListenForEvent(InjectionEvent.POST_INSTANTIATE), isTrue());
		}

		[Test]
		public function injectorDispatchesPreConstructEventDuringInstanceConstruction() : void
		{
			assertThat(constructMappedTypeAndListenForEvent(InjectionEvent.PRE_CONSTRUCT), isTrue());
		}

		[Test]
		public function injectorDispatchesPostConstructEventAfterInstanceConstruction() : void
		{
			assertThat(constructMappedTypeAndListenForEvent(InjectionEvent.POST_CONSTRUCT), isTrue());
		}

		[Test]
		public function injectorEventsAfterInstantiateContainCreatedInstance() : void
		{
			function listener(event : InjectionEvent) : void
			{
				assertThat(event, hasPropertyWithValue('instance', isA(Clazz)));
			}
			injector.map(Clazz);
			injector.addEventListener(InjectionEvent.POST_INSTANTIATE, listener);
			injector.addEventListener(InjectionEvent.PRE_CONSTRUCT, listener);
			injector.addEventListener(InjectionEvent.POST_CONSTRUCT, listener);
			const instance : Clazz = injector.getInstance(Clazz);
		}

		[Test]
		public function injectIntoDispatchesPreConstructEventDuringObjectConstruction() : void
		{
			assertThat(injectIntoInstanceAndListenForEvent(InjectionEvent.PRE_CONSTRUCT), isTrue());
		}

		[Test]
		public function injectIntoDispatchesPostConstructEventDuringObjectConstruction() : void
		{
			assertThat(injectIntoInstanceAndListenForEvent(InjectionEvent.POST_CONSTRUCT), isTrue());
		}

		[Test]
		public function injectorDispatchesEventBeforeCreatingNewMapping() : void
		{
			assertThat(createMappingAndListenForEvent(MappingEvent.PRE_MAPPING_CREATE));
		}

		[Test]
		public function injectorDispatchesEventAfterCreatingNewMapping() : void
		{
			assertThat(createMappingAndListenForEvent(MappingEvent.POST_MAPPING_CREATE));
		}

		[Test]
		public function injectorDispatchesEventBeforeChangingMappingProvider() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.PRE_MAPPING_CHANGE);
			injector.map(Clazz).asSingleton();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.PRE_MAPPING_CHANGE));
		}

		[Test]
		public function injectorDispatchesEventAfterChangingMappingProvider() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.POST_MAPPING_CHANGE);
			injector.map(Clazz).asSingleton();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.POST_MAPPING_CHANGE));
		}

		[Test]
		public function injectorDispatchesEventBeforeChangingMappingStrength() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.PRE_MAPPING_CHANGE);
			injector.map(Clazz).soft();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.PRE_MAPPING_CHANGE));
		}

		[Test]
		public function injectorDispatchesEventAfterChangingMappingStrength() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.POST_MAPPING_CHANGE);
			injector.map(Clazz).soft();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.POST_MAPPING_CHANGE));
		}

		[Test]
		public function injectorDispatchesEventBeforeChangingMappingScope() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.PRE_MAPPING_CHANGE);
			injector.map(Clazz).local();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.PRE_MAPPING_CHANGE));
		}

		[Test]
		public function injectorDispatchesEventAfterChangingMappingScope() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.POST_MAPPING_CHANGE);
			injector.map(Clazz).local();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.POST_MAPPING_CHANGE));
		}

		[Test]
		public function injectorDispatchesEventAfterRemovingMapping() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.POST_MAPPING_REMOVE);
			injector.unmap(Clazz);
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.POST_MAPPING_REMOVE));
		}

		[Test]
		public function injectorThrowsWhenTryingToCreateMappingForSameTypeFromPreMappingCreateHandler() : void
		{
			var errorThrown : Boolean;
			injector.addEventListener(MappingEvent.PRE_MAPPING_CREATE,
				function(event : MappingEvent) : void
			{
				try
				{
					injector.map(Clazz);
				}
				catch (error : InjectorError)
				{
					errorThrown = true;
				}
			});
			injector.map(Clazz);
			assertThat(errorThrown, isTrue());
		}

		[Test]
		public function injectorThrowsWhenTryingToCreateMappingForSameTypeFromPostMappingCreateHandler() : void
		{
			var errorThrown : Boolean;
			injector.addEventListener(MappingEvent.POST_MAPPING_CREATE,
				function(event : MappingEvent) : void
				{
					try
					{
						injector.map(Clazz).local();
					}
					catch (error : InjectorError)
					{
						errorThrown = true;
					}
				});
			injector.map(Clazz);
			assertThat(errorThrown, isTrue());
		}

		private function constructMappedTypeAndListenForEvent(eventType : String) : Boolean
		{
			injector.map(Clazz);
			listenToInjectorEvent(eventType);
			injector.getInstance(Clazz);
			return receivedInjectorEvents.pop() == eventType;
		}

		private function injectIntoInstanceAndListenForEvent(eventType : String) : Boolean
		{
			const injectee : ClassInjectee = new ClassInjectee();
			injector.map(Clazz).toValue(new Clazz());
			listenToInjectorEvent(eventType);
			injector.injectInto(injectee);
			return receivedInjectorEvents.pop() == eventType;
		}

		private function createMappingAndListenForEvent(eventType : String) : Boolean
		{
			listenToInjectorEvent(eventType);
			injector.map(Clazz);
			return receivedInjectorEvents.pop() == eventType;
		}

		private function listenToInjectorEvent(eventType : String) : void
		{
			injector.addEventListener(eventType, function(event : Event) : void
			{
				receivedInjectorEvents.push(event.type);
			});
		}

		[Test]
		public function injectorMakesInjectParametersAvailableToProviders() : void
		{
			const provider : UnknownParametersUsingProvider = new UnknownParametersUsingProvider();
			injector.map(Clazz).toProvider(provider);
			injector.getInstance(UnknownInjectParametersListInjectee);
			assertThat(provider.parameterValue, equalTo('true,str,123'));
		}

		[Test]
		public function injectorUsesManuallySuppliedTypeDescriptionForField() : void
		{
			const description : TypeDescription = new TypeDescription();
			description.addFieldInjection('property', Clazz);
			injector.addTypeDescription(NamedClassInjectee, description);
			injector.map(Clazz);
			const injectee : NamedClassInjectee = injector.getInstance(NamedClassInjectee);
			assertThat(injectee.property, isA(Clazz));
		}

		[Test]
		public function injectorUsesManuallySuppliedTypeDescriptionForMethod() : void
		{
			const description : TypeDescription = new TypeDescription();
			description.addMethodInjection('setDependency', [Clazz]);
			injector.addTypeDescription(OneNamedParameterMethodInjectee, description);
			injector.map(Clazz);
			const injectee : OneNamedParameterMethodInjectee =
				injector.getInstance(OneNamedParameterMethodInjectee);
			assertThat(injectee.getDependency(), isA(Clazz));
		}

		[Test]
		public function injectorUsesManuallySuppliedTypeDescriptionForCtor() : void
		{
			const description : TypeDescription = new TypeDescription(false);
			description.setConstructor([Clazz]);
			injector.addTypeDescription(OneNamedParameterConstructorInjectee, description);
			injector.map(Clazz);
			const injectee : OneNamedParameterConstructorInjectee =
				injector.getInstance(OneNamedParameterConstructorInjectee);
			assertThat(injectee.getDependency(), isA(Clazz));
		}

		[Test]
		public function injectorUsesManuallySuppliedTypeDescriptionForPostConstructMethod() : void
		{
			const description : TypeDescription = new TypeDescription();
			description.addPostConstructMethod('doSomeStuff', [Clazz]);
			injector.addTypeDescription(PostConstructWithArgInjectee, description);
			injector.map(Clazz);
			const injectee : PostConstructWithArgInjectee =
				injector.getInstance(PostConstructWithArgInjectee);
			assertThat(injectee.property, isA(Clazz));
		}

		[Test]
		public function injectorExecutesInjectedPostConstructMethodVars() : void
		{
			var callbackInvoked : Boolean;
			injector.map(Function).toValue(function() : void {callbackInvoked = true});
			injector.getInstance(PostConstructInjectedVarInjectee);
			assertThat(callbackInvoked, isTrue());
		}

		[Test]
		public function injectorExecutesInjectedPostConstructMethodVarsInInjecteeScope() : void
		{
			injector.map(Function).toValue(function() : void {this.property = new Clazz();});
			const injectee : PostConstructInjectedVarInjectee =
				injector.getInstance(PostConstructInjectedVarInjectee);
			assertThat(injectee.property, isA(Clazz));
		}
	}
}