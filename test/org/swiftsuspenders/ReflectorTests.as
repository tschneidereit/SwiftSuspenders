/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import org.flexunit.Assert;
	import org.hamcrest.assertThat;
	import org.hamcrest.core.isA;
	import org.hamcrest.object.hasProperties;
	import org.hamcrest.object.isTrue;
	import org.hamcrest.object.notNullValue;
	import org.swiftsuspenders.support.injectees.PostConstructGetterInjectee;
	import org.swiftsuspenders.support.injectees.PostConstructInjectedVarInjectee;
	import org.swiftsuspenders.support.injectees.PostConstructVarInjectee;
	import org.swiftsuspenders.support.injectees.UnknownInjectParametersInjectee;
	import org.swiftsuspenders.support.injectees.UnknownInjectParametersListInjectee;
	import org.swiftsuspenders.typedescriptions.ConstructorInjectionPoint;
	import org.swiftsuspenders.typedescriptions.InjectionPoint;
	import org.swiftsuspenders.typedescriptions.NoParamsConstructorInjectionPoint;
	import org.swiftsuspenders.typedescriptions.PostConstructInjectionPoint;
	import org.swiftsuspenders.typedescriptions.PreDestroyInjectionPoint;
	import org.swiftsuspenders.support.injectees.InterfaceInjectee;
	import org.swiftsuspenders.support.injectees.NamedInterfaceInjectee;
	import org.swiftsuspenders.support.injectees.OneNamedParameterConstructorInjectee;
	import org.swiftsuspenders.support.injectees.OneNamedParameterMethodInjectee;
	import org.swiftsuspenders.support.injectees.OneParameterConstructorInjectee;
	import org.swiftsuspenders.support.injectees.OneParameterMethodInjectee;
	import org.swiftsuspenders.support.injectees.OneRequiredOneOptionalPropertyMethodInjectee;
	import org.swiftsuspenders.support.injectees.OptionalClassInjectee;
	import org.swiftsuspenders.support.injectees.OptionalOneRequiredParameterMethodInjectee;
	import org.swiftsuspenders.support.injectees.OrderedPostConstructInjectee;
	import org.swiftsuspenders.support.injectees.OrderedPreDestroyInjectee;
	import org.swiftsuspenders.support.injectees.TwoNamedParametersMethodInjectee;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.ClazzExtension;
	import org.swiftsuspenders.support.types.Interface;
	import org.swiftsuspenders.typedescriptions.PropertyInjectionPoint;
	import org.swiftsuspenders.typedescriptions.TypeDescription;
	import org.swiftsuspenders.utils.SsInternal;

	use namespace SsInternal;

	public class ReflectorTests
	{
		private static const CLAZZ_FQCN_COLON_NOTATION:String = "org.swiftsuspenders.support.types::Clazz";
		private static const CLAZZ_FQCN_DOT_NOTATION:String = "org.swiftsuspenders.support.types.Clazz";
		private static const CLASS_IN_ROOT_PACKAGE:Class = Date;
		private static const CLASS_NAME_IN_ROOT_PACKAGE:String = "Date";
		
		protected var reflector:Reflector;
		protected var injector:Injector;
		
		[After]
		public function teardown():void
		{
			reflector = null;
			Injector.SsInternal::purgeInjectionPointsCache();
			injector = null;
		}
		
		[Test]
		public function classExtendsClass():void
		{
			var isClazz:Boolean = reflector.typeImplements(ClazzExtension, Clazz);
			
			Assert.assertTrue("ClazzExtension should be an extension of Clazz", isClazz);
		}

		[Test]
		public function classImplementsInterface():void
		{
			var implemented:Boolean = reflector.typeImplements(ClazzExtension, Interface);
			
			Assert.assertTrue("ClazzExtension should implement Interface", implemented);
		}
		
		[Test]
		public function getFullyQualifiedClassNameFromClass():void
		{
			var fqcn:String = reflector.getFQCN(Clazz);

			Assert.assertEquals(CLAZZ_FQCN_COLON_NOTATION,fqcn)
		}

		[Test]
		public function getFullyQualifiedClassNameFromClassReplacingColons():void
		{
			var fqcn:String = reflector.getFQCN(Clazz, true);
			
			Assert.assertEquals(CLAZZ_FQCN_DOT_NOTATION,fqcn)
		}
		
		[Test]
		public function getFullyQualifiedClassNameFromClassString():void
		{
			var fqcn:String = reflector.getFQCN(CLAZZ_FQCN_DOT_NOTATION);
			
			Assert.assertEquals(CLAZZ_FQCN_COLON_NOTATION,fqcn)
		}

		[Test]
		public function getFullyQualifiedClassNameFromClassStringReplacingColons():void
		{
			var fqcn:String = reflector.getFQCN(CLAZZ_FQCN_DOT_NOTATION, true);
			
			Assert.assertEquals(CLAZZ_FQCN_DOT_NOTATION,fqcn)
		}
		
		[Test]
		public function getFullyQualifiedClassNameFromClassInRootPackage():void
		{
			var fqcn:String = reflector.getFQCN(CLASS_IN_ROOT_PACKAGE);
			
			Assert.assertEquals(CLASS_NAME_IN_ROOT_PACKAGE,fqcn)
		}
		
		[Test]
		public function getFullyQualifiedClassNameFromClassStringInRootPackage():void
		{
			var fqcn:String = reflector.getFQCN(CLASS_NAME_IN_ROOT_PACKAGE);
			
			Assert.assertEquals(CLASS_NAME_IN_ROOT_PACKAGE,fqcn)
		}
		
		[Test]
		public function getFullyQualifiedClassNameFromClassInRootPackageReplacingColons():void
		{
			var fqcn:String = reflector.getFQCN(CLASS_IN_ROOT_PACKAGE, true);
			
			Assert.assertEquals(CLASS_NAME_IN_ROOT_PACKAGE,fqcn)
		}
		
		[Test]
		public function getFullyQualifiedClassNameFromClassStringInRootPackageReplacingColons():void
		{
			var fqcn:String = reflector.getFQCN(CLASS_NAME_IN_ROOT_PACKAGE, true);
			
			Assert.assertEquals(CLASS_NAME_IN_ROOT_PACKAGE,fqcn)
		}

		[Test]
		public function reflectorReturnsNoParamsCtorInjectionPointForNoParamsCtor() : void
		{
			var injectionPoint : InjectionPoint = reflector.describeInjections(Clazz).ctor;
			Assert.assertTrue('reflector-returned injectionPoint is no-params ctor injectionPoint',
					injectionPoint is NoParamsConstructorInjectionPoint);
		}

		[Test]
		public function reflectorReturnsCorrectCtorInjectionPointForParamsCtor() : void
		{
			var injectionPoint : InjectionPoint = 
				reflector.describeInjections(OneParameterConstructorInjectee).ctor;
			Assert.assertTrue('reflector-returned injectionPoint is ctor injectionPoint',
					injectionPoint is ConstructorInjectionPoint);
		}

		[Test]
		public function reflectorReturnsCorrectCtorInjectionPointForNamedParamsCtor() : void
		{
			var injectionPoint : ConstructorInjectionPoint = 
				reflector.describeInjections(OneNamedParameterConstructorInjectee).ctor;
			Assert.assertTrue('reflector-returned injectionPoint is ctor injectionPoint',
					injectionPoint is ConstructorInjectionPoint);
			injector.map(Clazz, 'namedDependency').toType(Clazz);
			var injectee:OneNamedParameterConstructorInjectee =
					OneNamedParameterConstructorInjectee(injectionPoint
							.createInstance(OneNamedParameterConstructorInjectee, injector));
			Assert.assertNotNull(
					"Instance of Clazz should have been injected for named Clazz parameter",
					injectee.getDependency());
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForUnnamedPropertyInjection() : void
		{
			const description : TypeDescription = reflector.describeInjections(InterfaceInjectee);
			assertThat(description.injectionPoints, isA(PropertyInjectionPoint));
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForNamedPropertyInjection() : void
		{
			const description : TypeDescription =
				reflector.describeInjections(NamedInterfaceInjectee);
			assertThat(description.injectionPoints, isA(PropertyInjectionPoint));
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForOptionalPropertyInjection() : void
		{
			const description : TypeDescription =
				reflector.describeInjections(OptionalClassInjectee);
			var injectee : OptionalClassInjectee = new OptionalClassInjectee();
			description.injectionPoints.applyInjection(injectee, OptionalClassInjectee, injector);
			Assert.assertNull("Instance of Clazz should not have been injected for Clazz property",
					injectee.property);
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForOneParamMethodInjection() : void
		{
			const description : TypeDescription =
				reflector.describeInjections(OneParameterMethodInjectee);
			var injectee : OneParameterMethodInjectee = new OneParameterMethodInjectee();
			injector.map(Clazz);
			description.injectionPoints.applyInjection(
				injectee, OneParameterMethodInjectee, injector);
			Assert.assertNotNull("Instance of Clazz should have been injected for Clazz dependency",
					injectee.getDependency());
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForOneNamedParamMethodInjection() : void
		{
			const description : TypeDescription =
				reflector.describeInjections(OneNamedParameterMethodInjectee);
			var injectee : OneNamedParameterMethodInjectee = new OneNamedParameterMethodInjectee();
			injector.map(Clazz, 'namedDep');
			description.injectionPoints.applyInjection(
				injectee, OneNamedParameterMethodInjectee, injector);
			Assert.assertNotNull("Instance of Clazz should have been injected for Clazz dependency",
					injectee.getDependency());
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForTwoNamedParamsMethodInjection() : void
		{
			const description : TypeDescription =
				reflector.describeInjections(TwoNamedParametersMethodInjectee);
			var injectee : TwoNamedParametersMethodInjectee = new TwoNamedParametersMethodInjectee();
			injector.map(Clazz, 'namedDep');
			injector.map(Interface, 'namedDep2').toType(Clazz);
			description.injectionPoints.applyInjection(
				injectee, TwoNamedParametersMethodInjectee, injector);
			Assert.assertNotNull("Instance of Clazz should have been injected for Clazz dependency",
					injectee.getDependency());
			Assert.assertNotNull("Instance of Clazz should have been injected for Interface dependency",
					injectee.getDependency2());
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForOneRequiredOneOptionalParamsMethodInjection() : void
		{
			const description : TypeDescription =
				reflector.describeInjections(OneRequiredOneOptionalPropertyMethodInjectee);
			var injectee : OneRequiredOneOptionalPropertyMethodInjectee =
				new OneRequiredOneOptionalPropertyMethodInjectee();
			injector.map(Clazz);
			description.injectionPoints.applyInjection(
				injectee, OneRequiredOneOptionalPropertyMethodInjectee, injector);
			Assert.assertNotNull("Instance of Clazz should have been injected for Clazz dependency",
					injectee.getDependency());
			Assert.assertNull("Instance of Clazz should not have been injected for Interface dependency",
					injectee.getDependency2());
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForOptionalOneRequiredParamMethodInjection() : void
		{
			const description : TypeDescription =
				reflector.describeInjections(OptionalOneRequiredParameterMethodInjectee);
			var injectee : OptionalOneRequiredParameterMethodInjectee = new OptionalOneRequiredParameterMethodInjectee();
			description.injectionPoints.applyInjection(
				injectee, OptionalOneRequiredParameterMethodInjectee, injector);
			Assert.assertNull("Instance of Clazz should not have been injected for Clazz dependency",
					injectee.getDependency());
		}

		[Test]
		public function reflectorCreatesInjectionPointsForPostConstructMethods() : void
		{
			const first : InjectionPoint =
				reflector.describeInjections(OrderedPostConstructInjectee).injectionPoints;
			Assert.assertTrue('Four injection points have been added',
				first && first.next && first.next.next && first.next.next.next);
		}

		[Test]
		public function reflectorCorrectlySortsInjectionPointsForPostConstructMethods() : void
		{
			const first : InjectionPoint =
				reflector.describeInjections(OrderedPostConstructInjectee).injectionPoints;
			Assert.assertEquals('First injection point has order "1"', 1,
					PostConstructInjectionPoint(first).order);
			Assert.assertEquals('Second injection point has order "2"', 2,
					PostConstructInjectionPoint(first.next).order);
			Assert.assertEquals('Third injection point has order "3"', 3,
					PostConstructInjectionPoint(first.next.next).order);
			Assert.assertEquals('Fourth injection point has no order "int.MAX_VALUE"', int.MAX_VALUE,
					PostConstructInjectionPoint(first.next.next.next).order);
		}

		[Test]
		public function reflectorCreatesInjectionPointsForPreDestroyMethods() : void
		{
			const first : InjectionPoint =
				reflector.describeInjections(OrderedPreDestroyInjectee).preDestroyMethods;
			Assert.assertTrue('Four injection points have been added',
				first && first.next && first.next.next && first.next.next.next);
		}

		[Test]
		public function reflectorCorrectlySortsInjectionPointsForPreDestroyMethods() : void
		{
			const first : InjectionPoint =
				reflector.describeInjections(OrderedPreDestroyInjectee).preDestroyMethods;
			Assert.assertEquals('First injection point has order "1"', 1,
				PreDestroyInjectionPoint(first).order);
			Assert.assertEquals('Second injection point has order "2"', 2,
				PreDestroyInjectionPoint(first.next).order);
			Assert.assertEquals('Third injection point has order "3"', 3,
				PreDestroyInjectionPoint(first.next.next).order);
			Assert.assertEquals('Fourth injection point has no order "int.MAX_VALUE"', int.MAX_VALUE,
				PreDestroyInjectionPoint(first.next.next.next).order);
		}

		[Test]
		public function reflectorStoresUnknownInjectParameters() : void
		{
			const first : InjectionPoint =
				reflector.describeInjections(UnknownInjectParametersInjectee).injectionPoints;
			assertThat(first.injectParameters, hasProperties(
				{optional:"true",name:'test',param1:"true",param2:'str',param3:"123"}));
		}

		[Test]
		public function reflectorStoresUnknownInjectParametersListAsCSV() : void
		{
			const first : InjectionPoint =
				reflector.describeInjections(UnknownInjectParametersListInjectee).injectionPoints;
			assertThat(first.injectParameters, hasProperties({param:"true,str,123"}));
		}

		[Test]
		public function reflectorFindsPostConstructMethodVars() : void
		{
			const first : PostConstructInjectionPoint = PostConstructInjectionPoint(
				reflector.describeInjections(PostConstructVarInjectee).injectionPoints);
			assertThat(first, notNullValue());
		}

		[Test]
		public function reflectorFindsPostConstructMethodGetters() : void
		{
			const first : PostConstructInjectionPoint = PostConstructInjectionPoint(
				reflector.describeInjections(PostConstructGetterInjectee).injectionPoints);
			assertThat(first, notNullValue());
		}
	}
}
