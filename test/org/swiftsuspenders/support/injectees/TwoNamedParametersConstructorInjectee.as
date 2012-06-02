/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Clazz;

	[Inject(name='namedDependency', name='namedDependency2')]
	public class TwoNamedParametersConstructorInjectee
	{
		private var m_dependency : Clazz;
		private var m_dependency2 : String;
		
		public function getDependency() : Clazz
		{
			return m_dependency;
		}
		public function getDependency2() : String
		{
			return m_dependency2;
		}
		
		public function TwoNamedParametersConstructorInjectee(dependency:Clazz, dependency2:String)
		{
			m_dependency = dependency;
			m_dependency2 = dependency2;
		}
	}
}