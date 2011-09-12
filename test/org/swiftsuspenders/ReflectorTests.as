/*
 * Copyright (c) 2009 - 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import org.flexunit.Assert;
	import org.swiftsuspenders.injectionpoints.ConstructorInjectionPoint;
	import org.swiftsuspenders.injectionpoints.InjectionPoint;
	import org.swiftsuspenders.injectionpoints.NoParamsConstructorInjectionPoint;
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
	import org.swiftsuspenders.support.injectees.TwoNamedParametersMethodInjectee;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.ClazzExtension;
	import org.swiftsuspenders.support.types.Interface;
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
			var isClazz:Boolean = reflector.classExtendsOrImplements(ClazzExtension, Clazz);
			
			Assert.assertTrue("ClazzExtension should be an extension of Clazz", isClazz);
		}

		[Test]
		public function classExtendsClassFromClassNameWithDotNotation():void
		{
			var isClazz:Boolean = reflector.classExtendsOrImplements(
					"org.swiftsuspenders.support.types.ClazzExtension", Clazz);
			
			Assert.assertTrue("ClazzExtension should be an extension of Clazz", isClazz);
		}

		[Test]
		public function classExtendsClassFromClassNameWithDoubleColonNotation():void
		{
			var isClazz:Boolean = reflector.classExtendsOrImplements(
					"org.swiftsuspenders.support.types::ClazzExtension", Clazz);
			
			Assert.assertTrue("ClazzExtension should be an extension of Clazz", isClazz);
		}

		[Test]
		public function classImplementsInterface():void
		{
			var implemented:Boolean = reflector.classExtendsOrImplements(Clazz, Interface);
			
			Assert.assertTrue("ClazzExtension should implement Interface", implemented);
		}

		[Test]
		public function classImplementsInterfaceFromClassNameWithDotNotation():void
		{
			var implemented:Boolean = reflector.classExtendsOrImplements(
					"org.swiftsuspenders.support.types.Clazz", Interface);
			
			Assert.assertTrue("ClazzExtension should implement Interface", implemented);
		}

		[Test]
		public function classImplementsInterfaceFromClassNameWithDoubleColonNotation():void
		{
			var implemented:Boolean = reflector.classExtendsOrImplements(
					"org.swiftsuspenders.support.types::Clazz", Interface);
			
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
			reflector.startReflection(Clazz);
			var injectionPoint : InjectionPoint = reflector.getCtorInjectionPoint();
			Assert.assertTrue('reflector-returned injectionPoint is no-params ctor injectionPoint',
					injectionPoint is NoParamsConstructorInjectionPoint);
		}

		[Test]
		public function reflectorReturnsCorrectCtorInjectionPointForParamsCtor() : void
		{
			reflector.startReflection(OneParameterConstructorInjectee);
			var injectionPoint : InjectionPoint = reflector.getCtorInjectionPoint();
			Assert.assertTrue('reflector-returned injectionPoint is ctor injectionPoint',
					injectionPoint is ConstructorInjectionPoint);
		}

		[Test]
		public function reflectorReturnsCorrectCtorInjectionPointForNamedParamsCtor() : void
		{
			reflector.startReflection(OneNamedParameterConstructorInjectee);
			var injectionPoint : InjectionPoint = reflector.getCtorInjectionPoint();
			Assert.assertTrue('reflector-returned injectionPoint is ctor injectionPoint',
					injectionPoint is ConstructorInjectionPoint);
			injector.usingName('namedDependency').map(Clazz).toType(Clazz);
			var injectee:OneNamedParameterConstructorInjectee =
					OneNamedParameterConstructorInjectee(injectionPoint
							.applyInjection(OneNamedParameterConstructorInjectee, injector));
			Assert.assertNotNull(
					"Instance of Clazz should have been injected for named Clazz parameter",
					injectee.getDependency());
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForUnnamedPropertyInjection() : void
		{
			reflector.startReflection(InterfaceInjectee);
			const injectionPoints : Array = [];
			reflector.addFieldInjectionPointsToList(injectionPoints);
			Assert.assertEquals('One injection point has been added', 1, injectionPoints.length);
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForNamedPropertyInjection() : void
		{
			reflector.startReflection(NamedInterfaceInjectee);
			const injectionPoints : Array = [];
			reflector.addFieldInjectionPointsToList(injectionPoints);
			Assert.assertEquals('One injection point has been added', 1, injectionPoints.length);
			injector.usingName('Name').map(Interface).toType(Clazz);
			var injectee : NamedInterfaceInjectee = new NamedInterfaceInjectee();
			InjectionPoint(injectionPoints[0]).applyInjection(injectee, injector);
			Assert.assertNotNull(
					"Instance of Clazz should have been injected for Interface property",
					injectee.property);
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForOptionalPropertyInjection() : void
		{
			reflector.startReflection(OptionalClassInjectee);
			const injectionPoints : Array = [];
			reflector.addFieldInjectionPointsToList(injectionPoints);
			Assert.assertEquals('One injection point has been added', 1, injectionPoints.length);
			var injectee : OptionalClassInjectee = new OptionalClassInjectee();
			InjectionPoint(injectionPoints[0]).applyInjection(injectee, injector);
			Assert.assertNull("Instance of Clazz should not have been injected for Clazz property",
					injectee.property);
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForOneParamMethodInjection() : void
		{
			reflector.startReflection(OneParameterMethodInjectee);
			const injectionPoints : Array = [];
			reflector.addMethodInjectionPointsToList(injectionPoints);
			Assert.assertEquals('One injection point has been added', 1, injectionPoints.length);
			var injectee : OneParameterMethodInjectee = new OneParameterMethodInjectee();
			injector.map(Clazz);
			InjectionPoint(injectionPoints[0]).applyInjection(injectee, injector);
			Assert.assertNotNull("Instance of Clazz should have been injected for Clazz dependency",
					injectee.getDependency());
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForOneNamedParamMethodInjection() : void
		{
			reflector.startReflection(OneNamedParameterMethodInjectee);
			const injectionPoints : Array = [];
			reflector.addMethodInjectionPointsToList(injectionPoints);
			Assert.assertEquals('One injection point has been added', 1, injectionPoints.length);
			var injectee : OneNamedParameterMethodInjectee = new OneNamedParameterMethodInjectee();
			injector.usingName('namedDep').map(Clazz);
			InjectionPoint(injectionPoints[0]).applyInjection(injectee, injector);
			Assert.assertNotNull("Instance of Clazz should have been injected for Clazz dependency",
					injectee.getDependency());
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForTwoNamedParamsMethodInjection() : void
		{
			reflector.startReflection(TwoNamedParametersMethodInjectee);
			const injectionPoints : Array = [];
			reflector.addMethodInjectionPointsToList(injectionPoints);
			Assert.assertEquals('One injection point has been added', 1, injectionPoints.length);
			var injectee : TwoNamedParametersMethodInjectee = new TwoNamedParametersMethodInjectee();
			injector.usingName('namedDep').map(Clazz);
			injector.usingName('namedDep2').map(Interface).toType(Clazz);
			InjectionPoint(injectionPoints[0]).applyInjection(injectee, injector);
			Assert.assertNotNull("Instance of Clazz should have been injected for Clazz dependency",
					injectee.getDependency());
			Assert.assertNotNull("Instance of Clazz should have been injected for Interface dependency",
					injectee.getDependency2());
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForOneRequiredOneOptionalParamsMethodInjection() : void
		{
			reflector.startReflection(OneRequiredOneOptionalPropertyMethodInjectee);
			const injectionPoints : Array = [];
			reflector.addMethodInjectionPointsToList(injectionPoints);
			Assert.assertEquals('One injection point has been added', 1, injectionPoints.length);
			var injectee : OneRequiredOneOptionalPropertyMethodInjectee = new OneRequiredOneOptionalPropertyMethodInjectee();
			injector.map(Clazz);
			InjectionPoint(injectionPoints[0]).applyInjection(injectee, injector);
			Assert.assertNotNull("Instance of Clazz should have been injected for Clazz dependency",
					injectee.getDependency());
			Assert.assertNull("Instance of Clazz should not have been injected for Interface dependency",
					injectee.getDependency2());
		}

		[Test]
		public function reflectorCorrectlyCreatesInjectionPointForOptionalOneRequiredParamMethodInjection() : void
		{
			reflector.startReflection(OptionalOneRequiredParameterMethodInjectee);
			const injectionPoints : Array = [];
			reflector.addMethodInjectionPointsToList(injectionPoints);
			Assert.assertEquals('One injection point has been added', 1, injectionPoints.length);
			var injectee : OptionalOneRequiredParameterMethodInjectee = new OptionalOneRequiredParameterMethodInjectee();
			InjectionPoint(injectionPoints[0]).applyInjection(injectee, injector);
			Assert.assertNull("Instance of Clazz should not have been injected for Clazz dependency",
					injectee.getDependency());
		}

		[Test]
		public function reflectorCreatesInjectionPointsForPostConstructMethods() : void
		{
			reflector.startReflection(OrderedPostConstructInjectee);
			const injectionPoints : Array = [];
			reflector.addPostConstructMethodPointsToList(injectionPoints);
			Assert.assertEquals('Four injection points has been added', 4, injectionPoints.length);
		}

		[Test]
		public function reflectorCorrectlySortsInjectionPointsForPostConstructMethods() : void
		{
			reflector.startReflection(OrderedPostConstructInjectee);
			const injectionPoints : Array = [];
			reflector.addPostConstructMethodPointsToList(injectionPoints);
			Assert.assertEquals('First injection point has order "1"', 1, injectionPoints[0].order);
			Assert.assertEquals('Second injection point has order "2"', 2, injectionPoints[1].order);
			Assert.assertEquals('Third injection point has order "3"', 3, injectionPoints[2].order);
			Assert.assertEquals('Fourth injection point has no order "int.MAX_VALUE"',
					int.MAX_VALUE, injectionPoints[3].order);
		}
	}
}
