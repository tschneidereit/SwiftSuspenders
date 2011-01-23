/*
 * Copyright (c) 2011 the original author or authors
 *
 * Permission is hereby granted to use, modify, and distribute this file
 * in accordance with the terms of the license agreement accompanying it.
 */

package org.swiftsuspenders
{
	import org.hamcrest.assertThat;
	import org.hamcrest.core.isA;
	import org.hamcrest.object.hasProperty;
	import org.swiftsuspenders.support.injectmethodinjectees.ClassInjectee;
	import org.swiftsuspenders.support.types.Clazz;

	public class InjectMethodTests
	{
		//----------------------              Public Properties             ----------------------//


		//----------------------       Private / Protected Properties       ----------------------//
		protected var injector:Injector;


		//----------------------               Public Methods               ----------------------//
		[Before]
		public function runBeforeEachTest():void
		{
			injector = new Injector();
		}

		[Test] public function injectMethodAppliesMappingFromInjectorWhenUsingInstantiate() : void
		{
			injector.mapClass(Clazz, Clazz);
			var injectee : ClassInjectee = injector.instantiate(ClassInjectee);
			assertThat(injectee, hasProperty('property', isA(Clazz)));
		}

		[Test] public function injectMethodAppliesMappingFromInjectorWhenUsingInjectInto() : void
		{
			injector.mapClass(Clazz, Clazz);
			var injectee : ClassInjectee = new ClassInjectee;
			injector.injectInto(injectee);
			assertThat(injectee, hasProperty('property', isA(Clazz)));
		}

		//----------------------         Private / Protected Methods        ----------------------//
	}
}