/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flash.events.Event;

	import flexunit.framework.Assert;

	import mx.collections.ArrayCollection;

	import org.flexunit.asserts.fail;

	import org.hamcrest.assertThat;
	import org.hamcrest.collection.array;
	import org.hamcrest.core.isA;
	import org.hamcrest.core.not;
	import org.hamcrest.object.equalTo;
	import org.hamcrest.object.hasPropertyWithValue;
	import org.hamcrest.object.instanceOf;
	import org.hamcrest.object.isFalse;
	import org.hamcrest.object.isTrue;
	import org.swiftsuspenders.dependencyproviders.ClassProvider;
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;
	import org.swiftsuspenders.dependencyproviders.FactoryProvider;
	import org.swiftsuspenders.dependencyproviders.OtherMappingProvider;
	import org.swiftsuspenders.errors.InjectorError;
	import org.swiftsuspenders.errors.InjectorInterfaceConstructionError;
	import org.swiftsuspenders.errors.InjectorMissingMappingError;
	import org.swiftsuspenders.mapping.InjectionMapping;
	import org.swiftsuspenders.mapping.MappingEvent;
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
	import org.swiftsuspenders.support.injectees.OptionalClassInjectee;
	import org.swiftsuspenders.support.injectees.OptionalOneRequiredParameterMethodInjectee;
	import org.swiftsuspenders.support.injectees.OrderedPostConstructInjectee;
	import org.swiftsuspenders.support.injectees.PostConstructInjectedVarInjectee;
	import org.swiftsuspenders.support.injectees.PostConstructWithArgInjectee;
	import org.swiftsuspenders.support.injectees.RecursiveInterfaceInjectee;
	import org.swiftsuspenders.support.injectees.SetterInjectee;
	import org.swiftsuspenders.support.injectees.SingletonInjectee;
	import org.swiftsuspenders.support.injectees.StringInjectee;
	import org.swiftsuspenders.support.injectees.TwoNamedInterfaceFieldsInjectee;
	import org.swiftsuspenders.support.injectees.TwoNamedParametersConstructorInjectee;
	import org.swiftsuspenders.support.injectees.TwoNamedParametersMethodInjectee;
	import org.swiftsuspenders.support.injectees.TwoParametersConstructorInjectee;
	import org.swiftsuspenders.support.injectees.TwoParametersConstructorInjecteeWithConstructorInjectedDependencies;
	import org.swiftsuspenders.support.injectees.TwoParametersMethodInjectee;
	import org.swiftsuspenders.support.injectees.UnknownInjectParametersListInjectee;
	import org.swiftsuspenders.support.injectees.XMLInjectee;
	import org.swiftsuspenders.support.providers.MoodyProvider;
	import org.swiftsuspenders.support.providers.ProviderThatCanDoInterfaces;
	import org.swiftsuspenders.support.providers.UnknownParametersUsingProvider;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.Clazz2;
	import org.swiftsuspenders.support.types.ComplexClazz;
	import org.swiftsuspenders.support.types.Interface;
	import org.swiftsuspenders.support.types.Interface2;
	import org.swiftsuspenders.support.types.ObjectToDestroy;
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
		public function unmap_removes_mapping():void
		{
			var injectee:InterfaceInjectee = new InterfaceInjectee();
			var value:Clazz = new Clazz();
			injector.map(Interface).toValue(value);
			Assert.assertTrue(injector.satisfies(Interface));
			injector.unmap(Interface);
			Assert.assertFalse(injector.satisfies(Interface));
		}

		[Test]
		public function injector_injects_bound_value_into_all_injectees():void
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
		public function map_value_by_interface():void
		{
			var injectee:InterfaceInjectee = new InterfaceInjectee();
			var value:Interface = new Clazz();
			injector.map(Interface).toValue(value);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Value should have been injected", value, injectee.property );
		}

		[Test]
		public function map_named_value_by_class():void
		{
			var injectee:NamedClassInjectee = new NamedClassInjectee();
			var value:Clazz = new Clazz();
			injector.map(Clazz, NamedClassInjectee.NAME).toValue(value);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Named value should have been injected", value, injectee.property );
		}

		[Test]
		public function map_named_value_by_interface():void
		{
			var injectee:NamedInterfaceInjectee = new NamedInterfaceInjectee();
			var value:Interface = new Clazz();
			injector.map(Interface, NamedClassInjectee.NAME).toValue(value);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Named value should have been injected", value, injectee.property );
		}

		[Test]
		public function map_falsy_value():void
		{
			var injectee:StringInjectee = new StringInjectee();
			var value:String = '';
			injector.map(String).toValue(value);
			injector.injectInto(injectee);
			Assert.assertStrictlyEquals("Value should have been injected", value, injectee.property );
		}

		[Test]
		public function mapped_value_is_not_injected_into() : void
		{
			var injectee:RecursiveInterfaceInjectee = new RecursiveInterfaceInjectee();
			var value:InterfaceInjectee = new InterfaceInjectee();
			injector.map(InterfaceInjectee).toValue(value);
			injector.injectInto(injectee);
			Assert.assertNull('value shouldn\'t have been injected into', value.property);
		}

		[Test]
		public function map_multiple_interfaces_to_one_singleton_class():void
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
		public function map_class_to_type_creates_new_instances():void
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
		public function map_class_to_type_results_in_new_instances_being_injected_into():void
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
		public function map_interface_to_type():void
		{
			var injectee:InterfaceInjectee = new InterfaceInjectee();
			injector.map(Interface).toType(Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of Class should have been injected", injectee.property );
		}

		[Test]
		public function map_class_to_type_by_name():void
		{
			var injectee:NamedClassInjectee = new NamedClassInjectee();
			injector.map(Clazz, NamedClassInjectee.NAME).toType(Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of named Class should have been injected", injectee.property );
		}

		[Test]
		public function map_interface_to_type_by_name():void
		{
			var injectee:NamedInterfaceInjectee = new NamedInterfaceInjectee();
			injector.map(Interface, NamedClassInjectee.NAME).toType(Clazz);
			injector.injectInto(injectee);
			Assert.assertNotNull("Instance of named Class should have been injected", injectee.property );
		}

		[Test]
		public function map_class_to_singleton_provides_single_instance():void
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
		public function map_interface_to_singleton_provides_single_instance():void
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
		public function map_same_interface_with_different_names_to_different_singletons_provides_different_instances():void
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
		public function setter_injection_fulfills_dependency():void
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
		public function one_parameter_method_injection_receives_dependency():void
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
		public function one_named_parameter_method_injection_receives_dependency():void
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
		public function two_parameter_method_injection_receives_both_dependencies():void
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
		public function two_named_parameter_method_injection_receives_both_dependencies():void
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
		public function mixed_named_and_unnamed_parameters_in_method_injection_fulfilled():void
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
		public function one_parameter_constructor_injection_fulfilled():void
		{
			injector.map(Clazz);
			var injectee:OneParameterConstructorInjectee = injector.instantiateUnmapped(OneParameterConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for Clazz parameter", injectee.getDependency() );
		}

		[Test]
		public function two_parameter_constructor_injection_fulfilled():void
		{
			injector.map(Clazz);
			injector.map(String).toValue('stringDependency');
			var injectee:TwoParametersConstructorInjectee = injector.instantiateUnmapped(TwoParametersConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency());
			Assert.assertEquals("The String 'stringDependency' should have been injected for String parameter", injectee.getDependency2(), 'stringDependency');
		}

		[Test]
		public function one_named_parameter_constructor_injection_fulfilled():void
		{
			injector.map(Clazz, 'namedDependency').toType(Clazz);
			var injectee:OneNamedParameterConstructorInjectee = injector.instantiateUnmapped(OneNamedParameterConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
		}

		[Test]
		public function two_named_parameters_constructor_injection_fulfilled():void
		{
			injector.map(Clazz, 'namedDependency').toType(Clazz);
			injector.map(String, 'namedDependency2').toValue('stringDependency');
			var injectee:TwoNamedParametersConstructorInjectee = injector.instantiateUnmapped(TwoNamedParametersConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency());
			Assert.assertEquals("The String 'stringDependency' should have been injected for named String parameter", injectee.getDependency2(), 'stringDependency');
		}

		[Test]
		public function mixed_named_and_unnamed_parameters_in_constructor_injection_fulfilled():void
		{
			injector.map(Clazz, 'namedDep').toType(Clazz);
			injector.map(Clazz).toType(Clazz);
			injector.map(Interface, 'namedDep2').toType(Clazz);
			var injectee:MixedParametersConstructorInjectee = injector.instantiateUnmapped(MixedParametersConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
			Assert.assertNotNull("Instance of Class should have been injected for unnamed Clazz parameter", injectee.getDependency2() );
			Assert.assertNotNull("Instance of Class should have been injected for Interface", injectee.getDependency3() );
		}

		[Test]
		public function named_array_injection_fulfilled():void
		{
			var ac : ArrayCollection = new ArrayCollection();
			injector.map(ArrayCollection, "namedCollection").toValue(ac);
			var injectee:NamedArrayCollectionInjectee = injector.instantiateUnmapped(NamedArrayCollectionInjectee);
			Assert.assertNotNull("Instance 'ac' should have been injected for named ArrayCollection parameter", injectee.ac );
			Assert.assertEquals("Instance field 'ac' should be identical to local variable 'ac'", ac, injectee.ac);
		}

		[Test]
		public function inject_xml_value() : void
		{
			var injectee : XMLInjectee = new XMLInjectee();
			var value : XML = <test/>;
			injector.map(XML).toValue(value);
			injector.injectInto(injectee);
			Assert.assertEquals('injected value should be indentical to mapped value',
				injectee.property, value);
		}

		[Test(expects="org.swiftsuspenders.errors.InjectorMissingMappingError")]
		public function halt_on_missing_interface_dependency():void
		{
			injector.injectInto(new InterfaceInjectee());
		}

		[Test]
		public function use_fallbackProvider_for_unmapped_dependency_if_given():void
		{
			injector.fallbackProvider = new ProviderThatCanDoInterfaces(Clazz);
			const injectee : ClassInjectee = new ClassInjectee();
			injector.injectInto(injectee);
			assertThat(injectee.property, isA(Clazz));
		}

		[Test(expects="org.swiftsuspenders.errors.InjectorMissingMappingError")]
		public function halt_on_missing_class_dependency_without_fallbackProvider():void
		{
			const injectee : ClassInjectee = new ClassInjectee();
			injector.injectInto(injectee);
		}

		[Test(expects="org.swiftsuspenders.errors.InjectorMissingMappingError")]
		public function halt_on_missing_named_dependency():void
		{
			var injectee:NamedClassInjectee = new NamedClassInjectee();
			injector.injectInto(injectee);
		}

		[Test]
		public function postConstruct_method_is_called():void
		{
			var injectee:ClassInjectee = new ClassInjectee();
			var value:Clazz = new Clazz();
			injector.map(Clazz).toValue(value);
			injector.injectInto(injectee);

			Assert.assertTrue(injectee.someProperty);
		}

		[Test]
		public function postConstruct_method_with_arg_is_called_correctly():void
		{
			injector.map(Clazz);
			var injectee:PostConstructWithArgInjectee =
				injector.instantiateUnmapped(PostConstructWithArgInjectee);
			assertThat(injectee.property, isA(Clazz));
		}

		[Test]
		public function postConstruct_methods_called_as_ordered():void
		{
			var injectee:OrderedPostConstructInjectee = new OrderedPostConstructInjectee();
			injector.injectInto(injectee);

			assertThat(injectee.loadOrder, array(1,2,3,4));
		}

		[Test]
		public function satisfies_is_false_for_unmapped_unnamed_interface():void
		{
			Assert.assertFalse(injector.satisfies(Interface));
		}

		[Test]
		public function satisfies_is_false_for_unmapped_unnamed_class():void
		{
			Assert.assertFalse(injector.satisfies(Clazz));
		}

		[Test]
		public function satisfies_is_false_for_unmapped_named_class():void
		{
			Assert.assertFalse(injector.satisfies(Clazz, 'namedClass'));
		}

		[Test]
		public function satisfies_is_true_for_mapped_unnamed_class():void
		{
			injector.map(Clazz).toType(Clazz);
			Assert.assertTrue(injector.satisfies(Clazz));
		}

		[Test]
		public function satisfies_is_true_for_mapped_named_class():void
		{
			injector.map(Clazz, 'namedClass').toType(Clazz);
			Assert.assertTrue(injector.satisfies(Clazz, 'namedClass'));
		}

		[Test(expects="org.swiftsuspenders.errors.InjectorMissingMappingError")]
		public function get_instance_errors_for_unmapped_class():void
		{
			injector.getInstance(Clazz);
		}

		[Test]
		public function instantiateUnmapped_works_for_unmapped_class():void
		{
			assertThat(injector.instantiateUnmapped(Clazz), instanceOf(Clazz));
		}

		[Test(expects="org.swiftsuspenders.errors.InjectorMissingMappingError")]
		public function get_instance_errors_for_unmapped_named_class():void
		{
			injector.getInstance(Clazz, 'namedClass');
		}

		[Test]
		public function getInstance_returns_mapped_value_for_mapped_unnamed_class():void
		{
			var clazz : Clazz = new Clazz();
			injector.map(Clazz).toValue(clazz);
			Assert.assertObjectEquals(injector.getInstance(Clazz), clazz);
		}

		[Test]
		public function getInstance_returns_mapped_value_for_mapped_named_class():void
		{
			var clazz : Clazz = new Clazz();
			injector.map(Clazz, 'namedClass').toValue(clazz);
			Assert.assertObjectEquals(injector.getInstance(Clazz, 'namedClass'), clazz);
		}

		[Test]
		public function unmapping_singleton_instance_removes_the_singleton() : void
		{
			injector.map(Clazz).toSingleton(Clazz);
			var injectee1 : ClassInjectee = injector.instantiateUnmapped(ClassInjectee);
			injector.unmap(Clazz);
			injector.map(Clazz).toSingleton(Clazz);
			var injectee2 : ClassInjectee = injector.instantiateUnmapped(ClassInjectee);
			Assert.assertFalse('injectee1.property is not the same instance as injectee2.property',
				injectee1.property == injectee2.property);
		}

		[Test(expects="org.swiftsuspenders.errors.InjectorInterfaceConstructionError")]
		public function instantiateUnmapped_on_interface_throws_InjectorInterfaceConstructionError() : void
		{
			injector.fallbackProvider = new ProviderThatCanDoInterfaces(Clazz);
			injector.instantiateUnmapped(Interface);
		}

		[Test(expects="org.swiftsuspenders.errors.InjectorMissingMappingError")]
		public function getInstance_on_unmapped_interface_with_no_fallback_throws_InjectorMissingMappingError() : void
		{
			injector.getInstance(Interface);
		}

		[Test(expects="org.swiftsuspenders.errors.InjectorMissingMappingError")]
		public function getInstance_on_unmapped_class_with_fallback_provider_that_doesnt_satisfy_throws_InjectorMissingMappingError() : void
		{
			injector.fallbackProvider = new MoodyProvider(false);
			injector.getInstance(Clazz)
		}

		[Test]
		public function instantiateUnmapped_doesnt_throw_when_attempting_unmapped_optional_property_injection() : void
		{
			var injectee : OptionalClassInjectee = injector.instantiateUnmapped(OptionalClassInjectee);
			Assert.assertNull("injectee mustn\'t contain Clazz instance", injectee.property);
		}

		[Test]
		public function getInstance_doesnt_throw_when_attempting_unmapped_optional_method_injection() : void
		{
			var injectee : OptionalOneRequiredParameterMethodInjectee =
					injector.instantiateUnmapped(OptionalOneRequiredParameterMethodInjectee);
			Assert.assertNull("injectee mustn\'t contain Interface instance", injectee.getDependency());
		}

		[Test]
		public function soft_mapping_is_used_if_no_parent_injector_available() : void
		{
			injector.map(Interface).softly().toType(Clazz);
			Assert.assertNotNull(injector.getInstance(Interface));
		}

		[Test]
		public function parent_mapping_is_used_instead_of_soft_child_mapping() : void
		{
			const childInjector : Injector = injector.createChildInjector();
			injector.map(Interface).toType(Clazz);
			childInjector.map(Interface).softly().toType(Clazz2);
			Assert.assertEquals(Clazz, childInjector.getInstance(Interface)['constructor']);
		}

		[Test]
		public function local_mappings_are_used_in_own_injector() : void
		{
			injector.map(Interface).locally().toType(Clazz);
			Assert.assertNotNull(injector.getInstance(Interface));
		}

		[Test(expects="org.swiftsuspenders.errors.InjectorError")]
		public function local_mappings_arent_shared_with_child_injectors() : void
		{
			const childInjector : Injector = injector.createChildInjector();
			injector.map(Interface).locally().toType(Clazz);
			childInjector.getInstance(Interface);
		}

		[Test]
		public function injector_dispatches_POST_INSTANTIATE_event_during_instance_construction() : void
		{
			assertThat(constructMappedTypeAndListenForEvent(InjectionEvent.POST_INSTANTIATE), isTrue());
		}

		[Test]
		public function injector_dispatches_PRE_CONSTRUCT_event_during_instance_construction() : void
		{
			assertThat(constructMappedTypeAndListenForEvent(InjectionEvent.PRE_CONSTRUCT), isTrue());
		}

		[Test]
		public function injector_dispatches_POST_CONSTRUCT_event_after_instance_construction() : void
		{
			assertThat(constructMappedTypeAndListenForEvent(InjectionEvent.POST_CONSTRUCT), isTrue());
		}

		[Test]
		public function injector_events_after_instantiate_contain_created_instance() : void
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
		public function injectInto_dispatches_PRE_CONSTRUCT_event_during_object_construction() : void
		{
			assertThat(injectIntoInstanceAndListenForEvent(InjectionEvent.PRE_CONSTRUCT), isTrue());
		}

		[Test]
		public function injectInto_dispatches_POST_CONSTRUCT_event_during_object_construction() : void
		{
			assertThat(injectIntoInstanceAndListenForEvent(InjectionEvent.POST_CONSTRUCT), isTrue());
		}

		[Test]
		public function injector_dispatches_PRE_MAPPING_CREATE_event_before_creating_new_mapping() : void
		{
			assertThat(createMappingAndListenForEvent(MappingEvent.PRE_MAPPING_CREATE));
		}

		[Test]
		public function injector_dispatches_POST_MAPPING_CREATE_event_after_creating_new_mapping() : void
		{
			assertThat(createMappingAndListenForEvent(MappingEvent.POST_MAPPING_CREATE));
		}

		[Test]
		public function injector_dispatches_PRE_MAPPING_CHANGE_event_before_changing_mapping_provider() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.PRE_MAPPING_CHANGE);
			injector.map(Clazz).asSingleton();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.PRE_MAPPING_CHANGE));
		}

		[Test]
		public function injector_dispatches_POST_MAPPING_CHANGE_event_after_changing_mapping_provider() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.POST_MAPPING_CHANGE);
			injector.map(Clazz).asSingleton();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.POST_MAPPING_CHANGE));
		}

		[Test]
		public function injector_dispatches_PRE_MAPPING_CHANGE_event_before_changing_mapping_strength() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.PRE_MAPPING_CHANGE);
			injector.map(Clazz).softly();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.PRE_MAPPING_CHANGE));
		}

		[Test]
		public function injector_dispatches_POST_MAPPING_CHANGE_event_after_changing_mapping_strength() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.POST_MAPPING_CHANGE);
			injector.map(Clazz).softly();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.POST_MAPPING_CHANGE));
		}

		[Test]
		public function injector_dispatches_PRE_MAPPING_CHANGE_event_before_changing_mapping_scope() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.PRE_MAPPING_CHANGE);
			injector.map(Clazz).locally();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.PRE_MAPPING_CHANGE));
		}

		[Test]
		public function injector_dispatches_POST_MAPPING_CHANGE_event_after_changing_mapping_scope() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.POST_MAPPING_CHANGE);
			injector.map(Clazz).locally();
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.POST_MAPPING_CHANGE));
		}

		[Test]
		public function injector_dispatches_POST_MAPPING_REMOVE_event_after_removing_mapping() : void
		{
			injector.map(Clazz);
			listenToInjectorEvent(MappingEvent.POST_MAPPING_REMOVE);
			injector.unmap(Clazz);
			assertThat(receivedInjectorEvents.pop(), equalTo(MappingEvent.POST_MAPPING_REMOVE));
		}

		[Test]
		public function injector_throws_when_trying_to_create_mapping_for_same_type_from_pre_mapping_create_handler() : void
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
		public function injector_throws_when_trying_to_create_mapping_for_same_type_from_post_mapping_create_handler() : void
		{
			var errorThrown : Boolean;
			injector.addEventListener(MappingEvent.POST_MAPPING_CREATE,
				function(event : MappingEvent) : void
				{
					try
					{
						injector.map(Clazz).locally();
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
		public function injector_makes_inject_parameters_available_to_providers() : void
		{
			const provider : UnknownParametersUsingProvider = new UnknownParametersUsingProvider();
			injector.map(Clazz).toProvider(provider);
			injector.instantiateUnmapped(UnknownInjectParametersListInjectee);
			assertThat(provider.parameterValue, equalTo('true,str,123'));
		}

		[Test]
		public function injector_uses_manually_supplied_type_description_for_field() : void
		{
			const description : TypeDescription = new TypeDescription();
			description.addFieldInjection('property', Clazz);
			injector.addTypeDescription(NamedClassInjectee, description);
			injector.map(Clazz);
			const injectee : NamedClassInjectee = injector.instantiateUnmapped(NamedClassInjectee);
			assertThat(injectee.property, isA(Clazz));
		}

		[Test]
		public function injector_uses_manually_supplied_type_description_for_method() : void
		{
			const description : TypeDescription = new TypeDescription();
			description.addMethodInjection('setDependency', [Clazz]);
			injector.addTypeDescription(OneNamedParameterMethodInjectee, description);
			injector.map(Clazz);
			const injectee : OneNamedParameterMethodInjectee =
				injector.instantiateUnmapped(OneNamedParameterMethodInjectee);
			assertThat(injectee.getDependency(), isA(Clazz));
		}

		[Test]
		public function injector_uses_manually_supplied_type_description_for_ctor() : void
		{
			const description : TypeDescription = new TypeDescription(false);
			description.setConstructor([Clazz]);
			injector.addTypeDescription(OneNamedParameterConstructorInjectee, description);
			injector.map(Clazz);
			const injectee : OneNamedParameterConstructorInjectee =
				injector.instantiateUnmapped(OneNamedParameterConstructorInjectee);
			assertThat(injectee.getDependency(), isA(Clazz));
		}

		[Test]
		public function injector_uses_manually_supplied_type_description_for_PostConstruct_method() : void
		{
			const description : TypeDescription = new TypeDescription();
			description.addPostConstructMethod('doSomeStuff', [Clazz]);
			injector.addTypeDescription(PostConstructWithArgInjectee, description);
			injector.map(Clazz);
			const injectee : PostConstructWithArgInjectee =
				injector.instantiateUnmapped(PostConstructWithArgInjectee);
			assertThat(injectee.property, isA(Clazz));
		}

		[Test]
		public function injector_executes_injected_PostConstruct_method_vars() : void
		{
			var callbackInvoked : Boolean;
			injector.map(Function).toValue(function () : void {
				callbackInvoked = true;
			});
			injector.instantiateUnmapped(PostConstructInjectedVarInjectee);
			assertThat(callbackInvoked, isTrue());
		}

		[Test]
		public function injector_executes_injected_PostConstruct_method_vars_in_injectee_scope() : void
		{
			injector.map(Function).toValue(function () : void {
				this.property = new Clazz();
			});
			const injectee : PostConstructInjectedVarInjectee =
				injector.instantiateUnmapped(PostConstructInjectedVarInjectee);
			assertThat(injectee.property, isA(Clazz));
		}

		[Test]
		public function unmapping_singleton_provider_invokes_PreDestroy_methods_on_singleton() : void
		{
			injector.map(Clazz).asSingleton();
			const singleton : Clazz = injector.getInstance(Clazz);
			assertThat(singleton, hasPropertyWithValue("preDestroyCalled", false));
			injector.unmap(Clazz);
			assertThat(singleton, hasPropertyWithValue("preDestroyCalled", true));
		}

		[Test]
		public function destroyInstance_invokes_PreDestroy_methods_on_managed_instance() : void
		{
			const target : Clazz = new Clazz();
			assertThat(target, hasPropertyWithValue("preDestroyCalled", false));
			injector.injectInto(target);
			injector.destroyInstance(target);
			assertThat(target, hasPropertyWithValue("preDestroyCalled", true));
		}

		[Test]
		public function destroyInstance_invokes_PreDestroy_methods_on_unmanaged_instance() : void
		{
			const target : Clazz = new Clazz();
			assertThat(target, hasPropertyWithValue("preDestroyCalled", false));
			injector.destroyInstance(target);
			assertThat(target, hasPropertyWithValue("preDestroyCalled", true));
		}

		[Test]
		public function teardown_destroys_all_singletons() : void
		{
			injector.map(Clazz).asSingleton();
			injector.map(Interface).toSingleton(Clazz);
			const singleton1 : Clazz = injector.getInstance(Clazz);
			const singleton2 : Clazz = injector.getInstance(Interface);
			assertThat(singleton1, hasPropertyWithValue("preDestroyCalled", false));
			assertThat(singleton2, hasPropertyWithValue("preDestroyCalled", false));
			injector.teardown();
			assertThat(singleton1, hasPropertyWithValue("preDestroyCalled", true));
			assertThat(singleton2, hasPropertyWithValue("preDestroyCalled", true));
		}

		[Test]
		public function teardown_does_not_destroy_what_is_already_destroyed() : void
		{
			injector.map(ObjectToDestroy).asSingleton();
			const singleton : ObjectToDestroy = injector.getInstance(ObjectToDestroy);
			injector.destroyInstance(singleton);
			injector.teardown();
			assertThat(singleton, hasPropertyWithValue("destroyCounter", 1));
		}

		[Test]
		public function injectInto_removes_object_from_deleted_objects() : void
		{
			injector.map(ObjectToDestroy).asSingleton();
			const singleton : ObjectToDestroy = injector.getInstance(ObjectToDestroy);
			injector.destroyInstance(singleton);
			injector.injectInto(singleton);
			injector.teardown();
			assertThat(singleton, hasPropertyWithValue("destroyCounter", 2));
		}

		[Test]
		public function teardown_clears_provider_mappings():void
		{
			injector.map(Clazz);
			injector.map(Interface);
			injector.map(ObjectToDestroy).asSingleton();
			injector.teardown();
			for each(var o:Object in injector.SsInternal::providerMappings)
			{
				fail("providerMappings should be empty");
			}
		}

		[Test]
		public function teardown_destroys_all_instances_it_injected_into() : void
		{
			const target1 : Clazz = new Clazz();
			injector.injectInto(target1);
			injector.map(Clazz);
			const target2 : Clazz = injector.getInstance(Clazz);
			assertThat(target1, hasPropertyWithValue("preDestroyCalled", false));
			assertThat(target2, hasPropertyWithValue("preDestroyCalled", false));
			injector.teardown();
			assertThat(target1, hasPropertyWithValue("preDestroyCalled", true));
			assertThat(target2, hasPropertyWithValue("preDestroyCalled", true));
		}

		[Test]
		public function managed_instance_test() : void
		{
			const target1 : Clazz = new Clazz();
			injector.injectInto(target1);
			const target2 : Clazz = new Clazz();
			injector.injectInto(target2);
			Assert.assertTrue(injector.hasManagedInstance(target1));
			Assert.assertTrue(injector.hasManagedInstance(target2));
			injector.teardown();
			Assert.assertFalse(injector.hasManagedInstance(target1));
			Assert.assertFalse(injector.hasManagedInstance(target2));
		}

		[Test]
		public function fallbackProvider_is_null_by_default() : void
		{
			assertThat(injector.fallbackProvider, equalTo(null));
		}

		[Test]
		public function satisfies_isTrue_if_fallbackProvider_satisifies() : void
		{
			injector.fallbackProvider = new MoodyProvider(true);
			assertThat(injector.satisfies(Clazz), isTrue());
		}

		[Test]
		public function satisfies_isFalse_if_fallbackProvider_doesnt_satisfy() : void
		{
			injector.fallbackProvider = new MoodyProvider(false);
			assertThat(injector.satisfies(Clazz), isFalse());
		}

		[Test]
		public function satisfies_returns_false_without_error_if_fallback_provider_cannot_satisfy_request() : void
		{
			injector.fallbackProvider = new MoodyProvider(false);
			assertThat(injector.satisfies(Interface), isFalse());
		}

		[Test]
		public function satisfies_returns_true_without_error_if_interface_requested_from_ProviderThatCanDoInterfaces() : void
		{
			injector.fallbackProvider = new ProviderThatCanDoInterfaces(Clazz);
			assertThat(injector.satisfies(Interface), isTrue());
		}

		[Test]
		public function satisfies_returns_false_for_unmapped_common_base_types() : void
		{
			injector.fallbackProvider = new MoodyProvider(true);
			const baseTypes:Array = [Array, Boolean, Class, Function, int, Number, Object, String, uint];
			// yes, loops in tests are bad, but this test case is already 1000 lines long!
			const iLength:uint = baseTypes.length;
			for (var i:uint = 0; i < iLength; i++)
			{
				assertThat(injector.satisfies(baseTypes[i]), isFalse());
			}
		}

		[Test]
		public function satisfiesDirectly_isTrue_if_fallbackProvider_satisifies() : void
		{
			injector.fallbackProvider = new MoodyProvider(true);
			assertThat(injector.satisfiesDirectly(Clazz), isTrue());
		}

		[Test]
		public function satisfiesDirectly_isFalse_if_no_local_fallbackProvider() : void
		{
			injector.fallbackProvider = new MoodyProvider(true);
			const childInjector:Injector = injector.createChildInjector();
			assertThat(childInjector.satisfiesDirectly(Clazz), isFalse());
		}

		[Test]
		public function instantiateUnmapped_returns_new_instance_even_if_mapped_instance_exists() : void
		{
			const mappedValue:Clazz = new Clazz();
			injector.map(Clazz).toValue(mappedValue);
			const instance:Clazz = injector.instantiateUnmapped(Clazz);
			assertThat(instance, not(equalTo(mappedValue)));
		}

		[Test]
		public function hasMapping_returns_true_for_parent_mappings() : void
		{
			injector.map(Clazz).toValue(new Clazz());
			const childInjector:Injector = injector.createChildInjector();
			assertThat(childInjector.hasMapping(Clazz), isTrue());
		}

		[Test]
		public function hasMapping_returns_true_for_local_mappings() : void
		{
			injector.map(Clazz).toValue(new Clazz());
			assertThat(injector.hasMapping(Clazz), isTrue());
		}

		[Test]
		public function hasMapping_returns_false_where_mapping_doesnt_exist() : void
		{
			assertThat(injector.hasMapping(Clazz), isFalse());
		}

		[Test]
		public function hasDirectMapping_returns_false_for_parent_mappings() : void
		{
			injector.map(Clazz).toValue(new Clazz());
			const childInjector:Injector = injector.createChildInjector();
			assertThat(childInjector.hasDirectMapping(Clazz), isFalse());
		}

		[Test]
		public function hasDirectMapping_returns_true_for_local_mappings() : void
		{
			injector.map(Clazz).toValue(new Clazz());
			assertThat(injector.hasDirectMapping(Clazz), isTrue());
		}

		[Test]
		public function getOrCreateNewInstance_provides_mapped_value_where_mapping_exists() : void
		{
			injector.map(Clazz).asSingleton();
			const instance1:Clazz = injector.getOrCreateNewInstance(Clazz);
			const instance2:Clazz = injector.getOrCreateNewInstance(Clazz);
			assertThat(instance1, equalTo(instance2));
		}

		[Test]
		public function getOrCreateNewInstance_instantiates_new_instance_where_no_mapping_exists() : void
		{
			const instance1:Clazz = injector.getOrCreateNewInstance(Clazz);
			assertThat(instance1, isA(Clazz));
		}

		[Test]
		public function getOrCreateNewInstance_instantiates_new_instances_each_time_where_no_mapping_exists() : void
		{
			const instance1:Clazz = injector.getOrCreateNewInstance(Clazz);
			const instance2:Clazz = injector.getOrCreateNewInstance(Clazz);
			assertThat(instance1, not(equalTo(instance2)));
		}

		[Test]
		public function satisfies_doesnt_use_fallbackProvider_from_ancestors_if_blockParentFallbackProvider_is_set() : void
		{
			injector.fallbackProvider = new ProviderThatCanDoInterfaces(Clazz);
			const childInjector:Injector = injector.createChildInjector();
			childInjector.blockParentFallbackProvider = true;
			assertThat(childInjector.satisfies(Clazz), isFalse());
		}

		[Test(expects="org.swiftsuspenders.errors.InjectorMissingMappingError")]
		public function getInstance_doesnt_use_fallbackProvider_from_ancestors_if_blockParentFallbackProvider_is_set() : void
		{
			injector.fallbackProvider = new ProviderThatCanDoInterfaces(Clazz);
			const childInjector:Injector = injector.createChildInjector();
			childInjector.blockParentFallbackProvider = true;
			childInjector.getInstance(Clazz);
		}

		// QUERY : This doesn't look like it's doing XML stuff??

		[Test]
		public function performXMLConfiguredConstructorInjectionWithOneNamedParameter():void
		{
			injector = new Injector();
			injector.map(Clazz, 'namedDependency').toType(Clazz);
			var injectee:OneNamedParameterConstructorInjectee = injector.instantiateUnmapped(OneNamedParameterConstructorInjectee);
			Assert.assertNotNull("Instance of Class should have been injected for named Clazz parameter", injectee.getDependency() );
		}

		// Not sure what this test is doing

		[Test]
		public function performMappedMappingInjection():void
		{
			var mapping : InjectionMapping = injector.map(Interface);
			mapping.toSingleton(Clazz);
			injector.map(Interface2).toProvider(new OtherMappingProvider(mapping));
			var injectee:MultipleSingletonsOfSameClassInjectee = injector.instantiateUnmapped(MultipleSingletonsOfSameClassInjectee);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'property2'", injectee.property1, injectee.property2);
		}

		// Not sure what this test is doing

		[Test]
		public function performMappedNamedMappingInjection():void
		{
			var mapping : InjectionMapping = injector.map(Interface);
			mapping.toSingleton(Clazz);
			injector.map(Interface2).toProvider(new OtherMappingProvider(mapping));
			injector.map(Interface, 'name1').toProvider(new OtherMappingProvider(mapping));
			injector.map(Interface2, 'name2').toProvider(new OtherMappingProvider(mapping));
			var injectee:MultipleNamedSingletonsOfSameClassInjectee = injector.instantiateUnmapped(MultipleNamedSingletonsOfSameClassInjectee);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'property2'", injectee.property1, injectee.property2);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'namedProperty1'", injectee.property1, injectee.namedProperty1);
			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'namedProperty2'", injectee.property1, injectee.namedProperty2);
		}

		[Test]
		public function two_parameters_constructor_injection_with_constructor_injected_dependencies_fulfilled():void
		{
			injector.map(Clazz);
			injector.map(OneParameterConstructorInjectee);
			injector.map(TwoParametersConstructorInjectee);
			injector.map(String).toValue('stringDependency');

			var injectee:TwoParametersConstructorInjecteeWithConstructorInjectedDependencies =
				injector.instantiateUnmapped(TwoParametersConstructorInjecteeWithConstructorInjectedDependencies);
			Assert.assertNotNull("Instance of Class should have been injected for OneParameterConstructorInjectee parameter", injectee.getDependency1() );
			Assert.assertNotNull("Instance of Class should have been injected for TwoParametersConstructorInjectee parameter", injectee.getDependency2() );
		}

		[Test]
		public function toProviderOf_reuses_provider_of_requested_mapping() : void{
			injector.map(String, 'first').toValue('first');
			injector.map(String, 'second').toProviderOf(String, 'first');
			const expected : DependencyProvider = injector.getMapping(String, 'first').getProvider();
			const actual : DependencyProvider = injector.getMapping(String, 'second').getProvider();
			assertThat(actual, equalTo(expected));
		}

		[Test]
		public function map_value_with_automatic_injected_values():void
		{
			var injectee : ClassInjectee = new ClassInjectee();
			injector.map(Clazz).asSingleton();
			injector.map(ClassInjectee).toValue(injectee, true);
			Assert.assertStrictlyEquals("Value should have been injected", injectee.property, injector.getInstance(Clazz));
		}

		[Test]
		public function map_value_without_automatic_injected_values():void
		{
			var injectee : ClassInjectee = new ClassInjectee();
			injector.map(Clazz).asSingleton();
			injector.map(ClassInjectee).toValue(injectee);
			Assert.assertNull("Value shouldn't been injected", injectee.property);
		}

		[Test]
		public function map_value_with_automatic_destroy_on_unmap() : void {
			var value : Clazz = new Clazz();
			injector.map(Clazz).toValue(value, true, true);
			injector.unmap(Clazz);
			Assert.assertTrue("Instance should be destroyed", value.preDestroyCalled);
		}

		[Test]
		public function map_value_without_automatic_destroy_on_unmap() : void {
			var value : Clazz = new Clazz();
			injector.map(Clazz).toValue(value);
			injector.unmap(Clazz);
			Assert.assertFalse("Instance shouldn't be destroyed", value.preDestroyCalled);
		}

		//		[Test]
		//		public function performInjectionIntoValueWithRecursiveSingletonDependency():void
		//		{
		//			var valueInjectee : InterfaceInjectee = new InterfaceInjectee();
		//			injector.map(InterfaceInjectee).toValue(valueInjectee);
		//			injector.map(Interface).toSingleton(RecursiveInterfaceInjectee);
		//
		//			injector.injectInto(valueInjectee);
		//			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'property2'", injectee.property1, injectee.property2);
		//			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'namedProperty1'", injectee.property1, injectee.namedProperty1);
		//			Assert.assertEquals("Instance field 'property1' should be identical to Instance field 'namedProperty2'", injectee.property1, injectee.namedProperty2);
		//		}

		[Test]
		public function immediately_initialize_singleton_provider_asSingleton():void
		{
			SingletonInjectee.reset();
			Assert.assertFalse("SingletonInjectee#hasInitialized", SingletonInjectee.hasInitialized);

			injector.map(SingletonInjectee).asSingleton(true);
			Assert.assertTrue("SingletonInjectee#hasInitialized", SingletonInjectee.hasInitialized);
		}

		[Test]
		public function immediately_initialize_singleton_provider_toSingleton():void
		{
			SingletonInjectee.reset();
			Assert.assertFalse("SingletonInjectee#hasInitialized", SingletonInjectee.hasInitialized);

			injector.map(SingletonInjectee).toSingleton(SingletonInjectee, true);
			Assert.assertTrue("SingletonInjectee#hasInitialized", SingletonInjectee.hasInitialized);
		}
	}
}
