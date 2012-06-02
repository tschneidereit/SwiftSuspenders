/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.support.injectees
{
	import org.swiftsuspenders.support.types.Interface;

	public class OptionalOneRequiredParameterMethodInjectee
	{
		private var m_dependency : Interface;

		[Inject(optional=true)]
		public function setDependency(dependency:Interface):void
		{
			m_dependency = dependency;
		}
		public function getDependency() : Interface
		{
			return m_dependency;
		}
		
		public function OptionalOneRequiredParameterMethodInjectee()
		{
		}
	}
}