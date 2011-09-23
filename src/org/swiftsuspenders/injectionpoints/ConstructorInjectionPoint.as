/*
 * Copyright (c) 2009-2011 the original author or authors
 * 
 * Permission is hereby granted to use, modify, and distribute this file 
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.injectionpoints
{
	import org.swiftsuspenders.Injector;

	public class ConstructorInjectionPoint extends MethodInjectionPoint
	{
		//----------------------               Public Methods               ----------------------//
		public function ConstructorInjectionPoint(parameters : Array)
		{
			super('ctor', parameters, false);
		}

		public function createInstance(type : Class, injector : Injector) : *
		{
			var p : Array = gatherParameterValues(type, injector);
			var result : Object;
			//the only way to implement ctor injections, really!
			switch (p.length)
			{
				case 1 : result = new type(p[0]); break;
				case 2 : result = new type(p[0], p[1]); break;
				case 3 : result = new type(p[0], p[1], p[2]); break;
				case 4 : result = new type(p[0], p[1], p[2], p[3]); break;
				case 5 : result = new type(p[0], p[1], p[2], p[3], p[4]); break;
				case 6 : result = new type(p[0], p[1], p[2], p[3], p[4], p[5]); break;
				case 7 : result = new type(p[0], p[1], p[2], p[3], p[4], p[5], p[6]); break;
				case 8 : result = new type(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]); break;
				case 9 : result = new type(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]); break;
				case 10 : result = new type(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9]); break;
			}
			p.length = 0;
			return result;
		}
	}
}