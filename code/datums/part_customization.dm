ABSTRACT_TYPE(/datum/part_customization)
///These are SINGLETONS
/datum/part_customization
	var/id = "INVALID"
	var/slot = "INVALID"
	///Can be a type or a list of types to randomly pick from
	var/part_type = null
	var/base_64_cache = null
	/// Associated trait ID, if one is needed
	var/associated_trait_id = null
	var/trait_cost = 0 //idk let's keep using trait points for now
	///Cannot be added alongside these part IDs
	var/incompatible_parts = list()
	///Custom icon overrides, otherwise just uses the part icon
	var/custom_icon = null
	var/custom_icon_state = null

	///Check if we can, then apply the part
	proc/try_apply(mob/M, list/custom_parts = null)
		if (src.can_apply(M, custom_parts))
			src.apply_to(M)
			return TRUE
		return FALSE

	///Actually add the part
	proc/apply_to(mob/M)
		PROTECTED_PROC(TRUE)
		SHOULD_CALL_PARENT(TRUE)
		if (src.associated_trait_id && M.traitHolder)
			M.traitHolder.addTrait(associated_trait_id)
		return

	///Can we add the part, `custom_parts` is an associative list of slot IDs to part IDs
	proc/can_apply(mob/M, list/custom_parts = null)
		SHOULD_CALL_PARENT(TRUE)
		for (var/slot_id in custom_parts)
			if (custom_parts[slot_id] in src.incompatible_parts)
				return FALSE
		return TRUE

	///UI helper proc so we don't have to manage static data caches
	proc/get_base64_icon()
		if (!src.base_64_cache)
			if (!src.custom_icon)
				var/obj/item/part_type = pick(src.part_type) //funny initial abuse
				src.base_64_cache = icon2base64(icon(initial(part_type.icon), initial(part_type.icon_state), dir=SOUTH, frame=1, moving=0))
			else
				src.base_64_cache = icon2base64(icon(src.custom_icon, src.custom_icon_state))
		return src.base_64_cache

	///Defaults to just the name of the part type, can be overridden
	proc/get_name()
		var/obj/item/part_type = pick(src.part_type)
		return initial(part_type.name)

ABSTRACT_TYPE(/datum/part_customization/human)
/datum/part_customization/human
	can_apply(mob/M)
		return ..() && ishuman(M)

ABSTRACT_TYPE(/datum/part_customization/human/limb)
/datum/part_customization/human/limb

	default
		arm
			left
				id = "arm_default_left"
				slot = "l_arm"
				part_type = /obj/item/parts/human_parts/arm/left

				apply_to(mob/living/carbon/human/human)
					. = ..()
					var/limb_type = human.mutantrace.l_limb_arm_type_mutantrace
					if (human.gender == FEMALE) //gendered limbs???
						limb_type = human.mutantrace.l_limb_arm_type_mutantrace_f || limb_type
					if (!limb_type)
						limb_type = src.part_type
					if(human.limbs.l_arm?.type != limb_type)
						human.limbs.replace_with(src.slot, limb_type, null, FALSE, TRUE)

			right
				id = "arm_default_right"
				slot = "r_arm"
				part_type = /obj/item/parts/human_parts/arm/right

				apply_to(mob/living/carbon/human/human)
					. = ..()
					var/limb_type = human.mutantrace.r_limb_arm_type_mutantrace
					if (human.gender == FEMALE) //gendered limbs???
						limb_type = human.mutantrace.r_limb_arm_type_mutantrace_f || limb_type
					if (!limb_type)
						limb_type = src.part_type
					if(!human.limbs.r_arm?.type == limb_type)
						human.limbs.replace_with(src.slot, limb_type, null, FALSE, TRUE)

		leg
			left
				id = "leg_default_left"
				slot = "l_leg"
				part_type = /obj/item/parts/human_parts/leg/left

				apply_to(mob/living/carbon/human/human)
					. = ..()
					var/limb_type = human.mutantrace.l_limb_leg_type_mutantrace
					if (human.gender == FEMALE)
						limb_type = human.mutantrace.l_limb_leg_type_mutantrace_f || limb_type
					if (!limb_type)
						limb_type = src.part_type
					if(human.limbs.l_leg?.type != limb_type)
						human.limbs.replace_with(src.slot, limb_type, null, FALSE, TRUE)

			right
				id = "leg_default_right"
				slot = "r_leg"
				part_type = /obj/item/parts/human_parts/leg/right

				apply_to(mob/living/carbon/human/human)
					. = ..()
					var/limb_type = human.mutantrace.r_limb_leg_type_mutantrace
					if (human.gender == FEMALE)
						limb_type = human.mutantrace.r_limb_leg_type_mutantrace_f || limb_type
					if (!limb_type)
						limb_type = src.part_type
					if(human.limbs.r_leg?.type != limb_type)
						human.limbs.replace_with(src.slot, limb_type, null, FALSE, TRUE)

	replacement

		apply_to(mob/living/carbon/human/human)
			. = ..()
			var/chosen_part_type = pick(src.part_type)
			if(human.limbs.get_limb(slot)?.type != chosen_part_type)
				human.limbs.replace_with(src.slot, chosen_part_type, null, FALSE, TRUE)

		arm

			robo_left
				id = "arm_robo_left"
				slot = "l_arm"
				part_type = /obj/item/parts/robot_parts/arm/left/light

			robo_right
				id = "arm_robo_right"
				slot = "r_arm"
				part_type = /obj/item/parts/robot_parts/arm/right/light

			robo_standard_left
				id = "arm_robo_standard_left"
				slot = "l_arm"
				part_type = /obj/item/parts/robot_parts/arm/left/standard
				trait_cost = 1
				incompatible_parts = list("arm_robo_standard_right")

			robo_standard_right
				id = "arm_robo_standard_right"
				slot = "r_arm"
				part_type = /obj/item/parts/robot_parts/arm/right/standard
				trait_cost = 1
				incompatible_parts = list("arm_robo_standard_left")

			plant_left
				id = "arm_plant_left"
				slot = "l_arm"
				trait_cost = 1
				part_type = list(/obj/item/parts/human_parts/arm/left/synth/bloom, /obj/item/parts/human_parts/arm/left/synth)

			plant_right
				id = "arm_plant_right"
				slot = "r_arm"
				trait_cost = 1
				part_type = list(/obj/item/parts/human_parts/arm/right/synth/bloom, /obj/item/parts/human_parts/arm/right/synth)

		leg
			plant_left
				id = "leg_plant_left"
				slot = "l_leg"
				trait_cost = 1
				part_type = list(/obj/item/parts/human_parts/leg/left/synth/bloom, /obj/item/parts/human_parts/leg/left/synth)

			plant_right
				id = "leg_plant_right"
				slot = "r_leg"
				trait_cost = 1
				part_type = list(/obj/item/parts/human_parts/leg/right/synth/bloom, /obj/item/parts/human_parts/leg/right/synth)

			robo_left
				id = "leg_robo_left"
				slot = "l_leg"
				trait_cost = 1
				part_type = /obj/item/parts/robot_parts/leg/left/light

			robo_right
				id = "leg_robo_right"
				slot = "r_leg"
				trait_cost = 1
				part_type = /obj/item/parts/robot_parts/leg/right/light

			robo_standard_left
				id = "leg_robo_standard_left"
				slot = "l_leg"
				part_type = /obj/item/parts/robot_parts/leg/left/standard
				trait_cost = 2
				incompatible_parts = list("leg_robo_standard_right")

			robo_standard_right
				id = "leg_robo_standard_right"
				slot = "r_leg"
				part_type = /obj/item/parts/robot_parts/leg/right/standard
				trait_cost = 2
				incompatible_parts = list("leg_robo_standard_left")

	missing
		custom_icon = 'icons/ui/character_editor.dmi'
		custom_icon_state = "missing"

		apply_to(mob/living/carbon/human/human)
			. = ..()
			var/obj/item/parts/limb = human.limbs.get_limb(src.slot)
			limb?.remove(show_message=FALSE)
			qdel(limb)

		arm
			left
				id = "arm_missing_left"
				slot = "l_arm"
				incompatible_parts = list("arm_missing_right")

				get_name()
					return "missing left arm"

			right
				id = "arm_missing_right"
				slot = "r_arm"
				incompatible_parts = list("arm_missing_left")

				get_name()
					return "missing right arm"
		leg

			left
				id = "leg_missing_left"
				slot = "l_leg"

				get_name()
					return "missing left leg"

			right
				id = "leg_missing_right"
				slot = "r_leg"

				get_name()
					return "missing right leg"


ABSTRACT_TYPE(/datum/part_customization/human/organ)
/datum/part_customization/human/organ

	default

		apply_to(mob/living/carbon/human/human)
			. = ..()
			var/obj/item/organ/chosen_part_type = human.mutantrace.mutant_organs[src.slot]
			if (!chosen_part_type) // fall back to default organs if we don't get any special ones
				chosen_part_type = pick(src.part_type)
			if(!istype(human.organHolder?.get_organ(src.slot), chosen_part_type))
				var/obj/item/organ/new_organ = new chosen_part_type()
				human.organHolder.receive_organ(new_organ, src.slot, force = TRUE)

		eye_left
			id = "eye_default_left"
			slot = "left_eye"
			part_type = /obj/item/organ/eye/left

		eye_right
			id = "eye_default_right"
			slot = "right_eye"
			part_type = /obj/item/organ/eye/right

	replacement
		apply_to(mob/living/carbon/human/human)
			. = ..()
			var/chosen_part_type = pick(src.part_type)
			if(!istype(human.organHolder?.get_organ(src.slot), chosen_part_type))
				var/obj/item/organ/new_organ = new chosen_part_type()
				human.organHolder.receive_organ(new_organ, src.slot, force = TRUE)

		eye_plant_left
			id = "eye_plant_left"
			slot = "left_eye"
			part_type = /obj/item/organ/eye/synth

		eye_plant_right
			id = "eye_plant_right"
			slot = "right_eye"
			part_type = /obj/item/organ/eye/synth

		eye_robot_left
			id = "eye_robot_left"
			slot = "left_eye"
			part_type = /obj/item/organ/eye/cyber/configurable

		eye_robot_right
			id = "eye_robot_right"
			slot = "right_eye"
			part_type = /obj/item/organ/eye/cyber/configurable

		eye_missing_left
			id = "eye_missing_left"
			slot = "left_eye"
			associated_trait_id = "eye_missing_left"
			part_type = /obj/item/organ/eye/glass

		eye_missing_right
			id = "eye_missing_right"
			slot = "right_eye"
			associated_trait_id = "eye_missing_right"
			part_type = /obj/item/organ/eye/glass

///Lazy init singleton list
var/list/datum/part_customization/part_customizations = null

proc/get_part_customization(id)
	if (!part_customizations)
		part_customizations = list()
		for (var/datum/part_customization/type as anything in concrete_typesof(/datum/part_customization))
			part_customizations[initial(type.id)] = new type
	return part_customizations[id]

//TODO: extend this to work with borgs too

// /datum/part_customization/cyborg
// 	var/complexity_cost = 1 //idk

// 	screen_head
// 		slot = "head"
// 		part_type =
