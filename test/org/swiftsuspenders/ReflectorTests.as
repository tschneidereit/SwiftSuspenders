/*
 * Copyright (c) 2009 - 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import org.flexunit.Assert;
	import org.swiftsuspenders.support.types.Clazz;
	import org.swiftsuspenders.support.types.ClazzExtension;
	import org.swiftsuspenders.support.types.Interface;

	public class ReflectorTests
	{
		private static const CLAZZ_FQCN_COLON_NOTATION:String = "org.swiftsuspenders.support.types::Clazz";
		private static const CLAZZ_FQCN_DOT_NOTATION:String = "org.swiftsuspenders.support.types.Clazz";
		private static const CLASS_IN_ROOT_PACKAGE:Class = Date;
		private static const CLASS_NAME_IN_ROOT_PACKAGE:String = "Date";
		
		private var reflector:Reflector;
		
		[Before]
		public function setup():void
		{
			reflector = new Reflector();
		}
		
		[After]
		public function teardown():void
		{
			reflector = null;
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
			var isClazz:Boolean = reflector.classExtendsOrImplements("org.swiftsuspenders.support.types.ClazzExtension", Clazz);
			
			Assert.assertTrue("ClazzExtension should be an extension of Clazz", isClazz);
		}

		[Test]
		public function classExtendsClassFromClassNameWithDoubleColonNotation():void
		{
			var isClazz:Boolean = reflector.classExtendsOrImplements("org.swiftsuspenders.support.types::ClazzExtension", Clazz);
			
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
			var implemented:Boolean = reflector.classExtendsOrImplements("org.swiftsuspenders.support.types.Clazz", Interface);
			
			Assert.assertTrue("ClazzExtension should implement Interface", implemented);
		}

		[Test]
		public function classImplementsInterfaceFromClassNameWithDoubleColonNotation():void
		{
			var implemented:Boolean = reflector.classExtendsOrImplements("org.swiftsuspenders.support.types::Clazz", Interface);
			
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
	}
}
