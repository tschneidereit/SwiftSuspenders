/*
 * Copyright (c) 2010-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.InjectionMapping;
	import org.swiftsuspenders.Injector;

	public class OtherMappingProvider implements DependencyProvider
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _mapping : InjectionMapping;


		//----------------------               Public Methods               ----------------------//
		public function OtherMappingProvider(mapping : InjectionMapping)
		{
			_mapping = mapping;
		}

		/**
		 * @inheritDoc
		 *
		 * @return The result of invoking <code>apply</code> on the <code>InjectionMapping</code>
		 * provided to this provider's constructor
		 */
		public function apply(targetType : Class, activeInjector : Injector) : Object
		{
			return _mapping.apply(targetType, activeInjector);
		}

		override public function equals(otherResult : InjectionResult) : Boolean
		{
			if (otherResult == this)
			{
				return true;
			}
			if (!(otherResult is InjectOtherRuleResult))
			{
				return false;
			}
			var castedResult : InjectOtherRuleResult =  InjectOtherRuleResult(otherResult);
			return castedResult.m_rule == m_rule;
		}
	}
}