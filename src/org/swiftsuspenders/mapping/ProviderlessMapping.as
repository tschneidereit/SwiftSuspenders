/*
 * Copyright (c) 2012 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders.mapping
{
	import org.swiftsuspenders.dependencyproviders.DependencyProvider;

	public interface ProviderlessMapping
	{
		/**
		 * @copy InjectionMapping#toType()
		 */
		function toType(type : Class) : UnsealedMapping;

		/**
		 * @copy InjectionMapping#toValue()
		 */
		function toValue(value : Object, autoInject : Boolean = false, destroyOnUnmap : Boolean = false) : UnsealedMapping;

		/**
		 * @copy InjectionMapping#toSingleton()
		 */
		function toSingleton(type : Class, initializeImmediately : Boolean = false) : UnsealedMapping;

		/**
		 * @copy InjectionMapping#asSingleton()
		 */
		function asSingleton(initializeImmediately : Boolean = false) : UnsealedMapping;

		/**
		 * @copy InjectionMapping#toProvider()
		 */
		function toProvider(provider : DependencyProvider) : UnsealedMapping;

		/**
		 * @copy InjectionMapping#seal()
		 */
		function seal() : Object;
	}
}
