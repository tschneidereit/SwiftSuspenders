/*
 * Copyright (c) 2010 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import flexunit.framework.Assert;

	public class GetConstructorTests
	{
		[Test]
		public function getConstructorReturnsConstructorForObject() : void
		{
			var object : Object = {};
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Object);
		}

		[Test]
		public function getConstructorReturnsConstructorForArray() : void
		{
			var array : Array = [];
			var objectClass : Class = getConstructor(array);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Array);
		}

		[Test]
		public function getConstructorReturnsConstructorForBoolean() : void
		{
			var object : Boolean = true;
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Boolean);
		}

		[Test]
		public function getConstructorReturnsConstructorForNumber() : void
		{
			var object : Number = 10.1;
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Number);
		}

		[Test]
		public function getConstructorReturnsConstructorForInt() : void
		{
			var object : int = 10;
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, int);
		}

		[Test]
		public function getConstructorReturnsConstructorForUint() : void
		{
			var object : uint = 10;
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, int);
		}

		[Test]
		public function getConstructorReturnsConstructorForString() : void
		{
			var object : String = 'string';
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, String);
		}

		[Test]
		public function getConstructorReturnsConstructorForXML() : void
		{
			var object : XML = new XML();
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, XML);
		}

		[Test]
		public function getConstructorReturnsConstructorForXMLList() : void
		{
			var object : XMLList = new XMLList();
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, XMLList);
		}

		[Test]
		public function getConstructorReturnsConstructorForFunction() : void
		{
			var object : Function = function() : void {};
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Function);
		}

		[Test]
		public function getConstructorReturnsConstructorForRegExp() : void
		{
			var object : RegExp = /./;
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, RegExp);
		}

		[Test]
		public function getConstructorReturnsConstructorForDate() : void
		{
			var object : Date = new Date();
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Date);
		}

		[Test]
		public function getConstructorReturnsConstructorForError() : void
		{
			var object : Error = new Error();
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, Error);
		}

		[Test]
		public function getConstructorReturnsConstructorForQName() : void
		{
			var object : QName = new QName();
			var objectClass : Class = getConstructor(object);
			Assert.assertEquals('object\'s constructor is Object', objectClass, QName);
		}

		[Test]
		public function getConstructorReturnsConstructorForVector() : void
		{
			var object : Vector.<String> = new Vector.<String>();
			var objectClass : Class = getConstructor(object);
			//See comment in getConstructor for why Vector.<*> is expected.
			Assert.assertEquals('object\'s constructor is Object', objectClass, Vector.<*>);
		}
	}
}