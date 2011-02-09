/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.utils
{
	import org.swiftsuspenders.injectionpoints.InjectionPoint;
	public final class ClassDescription
	{
		//----------------------              Public Properties             ----------------------//
		public var type : Class;
		public var ctor : InjectionPoint;
		public var injectionPoints : Array;


		//----------------------               Public Methods               ----------------------//
		public function ClassDescription(
				type : Class, ctor : InjectionPoint, injectionPoints : Array)
		{
			this.type = type;
			this.ctor = ctor;
			this.injectionPoints = injectionPoints;
		}
	}
}