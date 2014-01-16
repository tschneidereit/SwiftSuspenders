/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flexunit.framework.Assert;

	import org.swiftsuspenders.reflection.ReflectorBase;

	public class ReflectorBaseTests
	{
		private var _reflector : ReflectorBase;
		[Before]
		public function setup() : void
		{
			_reflector = new ReflectorBase();
		}
		[After]
		public function teardown() : void
		{
			_reflector = null;
		}
		
		[Test]
		public function getClassReturnsConstructorForObject() : void
		{
			var object : Object = {};
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Object);
		}

		[Test]
		public function getClassReturnsConstructorForArray() : void
		{
			var array : Array = [];
			var objectClass : Class = _reflector.getClass(array);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Array);
		}

		[Test]
		public function getClassReturnsConstructorForBoolean() : void
		{
			var object : Boolean = true;
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Boolean);
		}

		[Test]
		public function getClassReturnsConstructorForNumber() : void
		{
			var object : Number = 10.1;
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Number);
		}

		[Test]
		public function getClassReturnsConstructorForInt() : void
		{
			var object : int = 10;
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, int);
		}

		[Test]
		public function getClassReturnsConstructorForUint() : void
		{
			var object : uint = 10;
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, int);
		}

		[Test]
		public function getClassReturnsConstructorForString() : void
		{
			var object : String = 'string';
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, String);
		}

		[Test]
		public function getClassReturnsConstructorForXML() : void
		{
			var object : XML = new XML();
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, XML);
		}

		[Test]
		public function getClassReturnsConstructorForXMLList() : void
		{
			var object : XMLList = new XMLList();
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, XMLList);
		}

		[Test]
		public function getClassReturnsConstructorForFunction() : void
		{
			var object : Function = function() : void {};
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Function);
		}

		[Test]
		public function getClassReturnsConstructorForRegExp() : void
		{
			var object : RegExp = /./;
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, RegExp);
		}

		[Test]
		public function getClassReturnsConstructorForDate() : void
		{
			var object : Date = new Date();
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Date);
		}

		[Test]
		public function getClassReturnsConstructorForError() : void
		{
			var object : Error = new Error();
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Error);
		}

		[Test]
		public function getClassReturnsConstructorForQName() : void
		{
			var object : QName = new QName();
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, QName);
		}

		[Test]
		public function getClassReturnsConstructorForVector() : void
		{
			var object : Vector.<String> = new Vector.<String>();
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Vector.<String>);
		}

		[Test]
		public function getClassReturnsConstructorForVectorInt() : void
		{
			var object : Vector.<int> = new Vector.<int>();
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Vector.<int>);
		}

		[Test]
		public function getClassReturnsConstructorForVectorUint() : void
		{
			var object : Vector.<uint> = new Vector.<uint>();
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Vector.<uint>);
		}

		[Test]
		public function getClassReturnsConstructorForVectorNumber() : void
		{
			var object : Vector.<Number> = new Vector.<Number>();
			var objectClass : Class = _reflector.getClass(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Vector.<Number>);
		}
	}
}