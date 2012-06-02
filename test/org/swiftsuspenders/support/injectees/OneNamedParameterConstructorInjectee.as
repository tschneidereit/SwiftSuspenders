/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Clazz;

	[Inject(name='namedDependency')]
	public class OneNamedParameterConstructorInjectee
	{
		private var m_dependency : Clazz;
		
		public function getDependency() : Clazz
		{
			return m_dependency;
		}
		
		public function OneNamedParameterConstructorInjectee(dependency:Clazz)
		{
			m_dependency = dependency;
		}
	}
}