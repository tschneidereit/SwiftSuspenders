/*
 * Copyright (c) 2010-2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.dependencyproviders
{
	import org.swiftsuspenders.InjectionRule;
	import org.swiftsuspenders.Injector;

	public class OtherRuleProvider implements DependencyProvider
	{
		//----------------------       Private / Protected Properties       ----------------------//
		private var _rule : InjectionRule;


		//----------------------               Public Methods               ----------------------//
		public function OtherRuleProvider(rule : InjectionRule)
		{
			_rule = rule;
		}

		/**
		 * @inheritDoc
		 *
		 * @return The result of invoking <code>apply</code> on the <code>InjectionRule</code>
		 * provided to this provider's constructor
		 */
		public function apply(creatingInjector : Injector, usingInjector : Injector) : Object
		{
			return _rule.apply(usingInjector);
		}
	}
}