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
		
		override public function applyInjection(target : Object, injector : Injector) : Object
		{
			var ctor : Class = Class(target);
			var p : Array = gatherParameterValues(target, injector);
			//the only way to implement ctor injections, really!
			switch (p.length)
			{
				case 0 : return (new ctor());
				case 1 : return (new ctor(p[0]));
				case 2 : return (new ctor(p[0], p[1]));
				case 3 : return (new ctor(p[0], p[1], p[2]));
				case 4 : return (new ctor(p[0], p[1], p[2], p[3]));
				case 5 : return (new ctor(p[0], p[1], p[2], p[3], p[4]));
				case 6 : return (new ctor(p[0], p[1], p[2], p[3], p[4], p[5]));
				case 7 : return (new ctor(p[0], p[1], p[2], p[3], p[4], p[5], p[6]));
				case 8 : return (new ctor(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7]));
				case 9 : return (new ctor(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8]));
				case 10 : return (new ctor(p[0], p[1], p[2], p[3], p[4], p[5], p[6], p[7], p[8], p[9]));
			}
			return null;
		}
	}
}