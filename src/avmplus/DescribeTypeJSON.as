/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package avmplus
{
	public class DescribeTypeJSON
	{
		//----------------------              Public Properties             ----------------------//
		public static const available : Boolean = describeTypeJSON != null;
		
		public static const INSTANCE_FLAGS:uint = INCLUDE_BASES | INCLUDE_INTERFACES
			| INCLUDE_VARIABLES | INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA
			| INCLUDE_CONSTRUCTOR | INCLUDE_TRAITS | USE_ITRAITS | HIDE_OBJECT;
		public static const CLASS_FLAGS:uint = INCLUDE_INTERFACES | INCLUDE_VARIABLES
			| INCLUDE_ACCESSORS | INCLUDE_METHODS | INCLUDE_METADATA | INCLUDE_TRAITS | HIDE_OBJECT;


		//----------------------               Public Methods               ----------------------//
		public function DescribeTypeJSON()
		{
		}
		public function describeType(target : Object, flags : uint) : Object
		{
			return describeTypeJSON(target, flags);
		}

		public function getInstanceDescription(type : Class) : Object
		{
			return describeTypeJSON(type, INSTANCE_FLAGS);
		}

		public function getClassDescription(type : Class) : Object
		{
			return describeTypeJSON(type, CLASS_FLAGS);
		}
	}
}