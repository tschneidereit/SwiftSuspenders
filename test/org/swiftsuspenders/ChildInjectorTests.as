/*
* Copyright (c) 2009 the original author or authors
* 
* Permission is hereby granted to use, modify, and distribute this file 
* in accordance with the terms of the license agreement accompanying it.
*/

package org.swiftsuspenders
{
	import flexunit.framework.Assert;
	
	import org.swiftsuspenders.support.injectees.ClassInjectee;
	import org.swiftsuspenders.support.injectees.childinjectors.InjectorCopyRule;
	import org.swiftsuspenders.support.injectees.childinjectors.InjectorInjectee;
	import org.swiftsuspenders.support.injectees.childinjectors.LeftRobotFoot;
	import org.swiftsuspenders.support.injectees.childinjectors.RightRobotFoot;
	import org.swiftsuspenders.support.injectees.childinjectors.RobotAnkle;
	import org.swiftsuspenders.support.injectees.childinjectors.RobotBody;
	import org.swiftsuspenders.support.injectees.childinjectors.RobotFoot;
	import org.swiftsuspenders.support.injectees.childinjectors.RobotLeg;
	import org.swiftsuspenders.support.injectees.childinjectors.RobotToes;
	import org.swiftsuspenders.support.types.Clazz;

	public class ChildInjectorTests
	{
		protected var injector:Injector;
		
		[Before]
		public function runBeforeEachTest():void
		{
			injector = new Injector();
		}

		[After]
		public function teardown():void
		{
			Injector.purgeInjectionPointsCache();
			injector = null;
		}
		
		[Test]
		public function injectorCreatesChildInjector() : void
		{
			Assert.assertTrue(true);
			var childInjector : Injector = injector.createChildInjector();
			Assert.assertTrue('injector.createChildInjector should return an injector', 
				childInjector is Injector);
		}
		
		[Test]
		public function injectorUsesChildInjectorForSpecifiedRule() : void
		{
			injector.map(RobotFoot).toType(RobotFoot);

			var leftFootRule : InjectionRule = injector.mapNamed(RobotLeg, 'leftLeg');
			leftFootRule.toType(RobotLeg);
			var leftChildInjector : Injector = injector.createChildInjector();
			leftChildInjector.map(RobotAnkle).toType(RobotAnkle);
			leftChildInjector.map(RobotFoot).toType(LeftRobotFoot);

			leftFootRule.setInjector(leftChildInjector);
			var rightFootRule : InjectionRule = injector.mapNamed(RobotLeg, 'rightLeg');
			rightFootRule.toType(RobotLeg);
			var rightChildInjector : Injector = injector.createChildInjector();
			rightChildInjector.map(RobotAnkle).toType(RobotAnkle);
			rightChildInjector.map(RobotFoot).toType(RightRobotFoot);
			rightFootRule.setInjector(rightChildInjector);
			
			var robotBody : RobotBody = injector.instantiate(RobotBody);
			
			Assert.assertTrue('Right RobotLeg should have a RightRobotFoot', 
				robotBody.rightLeg.ankle.foot is RightRobotFoot);
			Assert.assertTrue('Left RobotLeg should have a LeftRobotFoot', 
				robotBody.leftLeg.ankle.foot is LeftRobotFoot);
		}

		[Test]
		public function childInjectorUsesParentInjectorForMissingRules() : void
		{
			injector.map(RobotFoot).toType(RobotFoot);
			injector.map(RobotToes).toType(RobotToes);

			var leftFootRule : InjectionRule = injector.mapNamed(RobotLeg, 'leftLeg');
			leftFootRule.toType(RobotLeg);
			var leftChildInjector : Injector = injector.createChildInjector();
			leftChildInjector.map(RobotAnkle).toType(RobotAnkle);
			leftChildInjector.map(RobotFoot).toType(LeftRobotFoot);
			leftFootRule.setInjector(leftChildInjector);

			var rightFootRule : InjectionRule = injector.mapNamed(RobotLeg, 'rightLeg');
			rightFootRule.toType(RobotLeg);
			var rightChildInjector : Injector = injector.createChildInjector();
			rightChildInjector.map(RobotAnkle).toType(RobotAnkle);
			rightChildInjector.map(RobotFoot).toType(RightRobotFoot);
			rightFootRule.setInjector(rightChildInjector);

			var robotBody : RobotBody = injector.instantiate(RobotBody);

			Assert.assertTrue('Right RobotFoot should have toes',
				robotBody.rightLeg.ankle.foot.toes is RobotToes);
			Assert.assertTrue('Left Robotfoot should have a toes',
				robotBody.leftLeg.ankle.foot.toes is RobotToes);
		}

		[Test]
		public function childInjectorDoesntReturnToParentAfterUsingParentInjectorForMissingRules() : void
		{
			injector.map(RobotAnkle).toType(RobotAnkle);
			injector.map(RobotFoot).toType(RobotFoot);
			injector.map(RobotToes).toType(RobotToes);

			var leftFootRule : InjectionRule = injector.mapNamed(RobotLeg, 'leftLeg');
			leftFootRule.toType(RobotLeg);
			var leftChildInjector : Injector = injector.createChildInjector();
			leftChildInjector.map(RobotFoot).toType(LeftRobotFoot);
			leftFootRule.setInjector(leftChildInjector);

			var rightFootRule : InjectionRule = injector.mapNamed(RobotLeg, 'rightLeg');
			rightFootRule.toType(RobotLeg);
			var rightChildInjector : Injector = injector.createChildInjector();
			rightChildInjector.map(RobotFoot).toType(RightRobotFoot);
			rightFootRule.setInjector(rightChildInjector);

			var robotBody : RobotBody = injector.instantiate(RobotBody);

			Assert.assertTrue('Right RobotFoot should have RightRobotFoot',
				robotBody.rightLeg.ankle.foot is RightRobotFoot);
			Assert.assertTrue('Left RobotFoot should have LeftRobotFoot',
				robotBody.leftLeg.ankle.foot is LeftRobotFoot);
		}

		[Test]
		public function childInjectorUsesParentsMapOfWorkedInjectees() : void
		{
			var childInjector : Injector = injector.createChildInjector();
			var class1 : Clazz = new Clazz();
			var class2 : Clazz = new Clazz();
			injector.mapValue(Clazz, class1);
			childInjector.mapValue(Clazz, class2);

			var injectee : ClassInjectee = injector.instantiate(ClassInjectee);
			childInjector.injectInto(injectee);
			Assert.assertEquals(
				'injectee.property isn\' overwritten by second injection through child injector',
				injectee.property, class1);
		}
        
        [Test]
        public function childInjectorHasMappingWhenExistsOnParentInjector():void
        {
            var childInjector : Injector = injector.createChildInjector();
            var class1 : Clazz = new Clazz();
            injector.mapValue(Clazz, class1);  
            
            Assert.assertTrue('Child injector should return true for hasMapping that exists on parent injector',
                childInjector.hasMapping(Clazz));
        }
        
        [Test]
        public function childInjectorDoesNotHaveMappingWhenDoesNotExistOnParentInjector():void
        {
            var childInjector : Injector = injector.createChildInjector();
            
            Assert.assertFalse('Child injector should not return true for hasMapping that does not exists on parent injector',
                childInjector.hasMapping(Clazz));
        }  
        
        [Test]
        public function grandChildInjectorSuppliesInjectionFromAncestor():void
        {
            var childInjector:Injector;
            var grandChildInjector:Injector;
            var injectee:ClassInjectee = new ClassInjectee();
            injector.mapSingleton(Clazz);
            childInjector = injector.createChildInjector();
            grandChildInjector = childInjector.createChildInjector();
            
            grandChildInjector.injectInto(injectee);
            
            Assert.assertTrue("injectee has been injected with Clazz instance from grandChildInjector", 
                injectee.property is Clazz); 
        }

		[Test]
		public function injectorCanCreateChildInjectorDuringInjection():void
		{
			injector.mapRule(Injector, new InjectorCopyRule());
			injector.map(InjectorInjectee).toType(InjectorInjectee);
			var injectee : InjectorInjectee = injector.getInstance(InjectorInjectee);
			Assert.assertNotNull('Injection has been applied to injectorInjectee', injectee.injector);
			Assert.assertTrue('injectorInjectee.injector is child of main injector',
					injectee.injector.getParentInjector() == injector);
			Assert.assertTrue('injectorInjectee.nestedInjectee is grandchild of main injector',
					injectee.nestedInjectee.nestedInjectee.injector.getParentInjector().getParentInjector().getParentInjector() == injector);
		}
	}
}