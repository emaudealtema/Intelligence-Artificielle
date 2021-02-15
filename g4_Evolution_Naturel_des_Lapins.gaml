/***
* Name: NaturalEvolutionRabbitsMOdel1
* Author: azem
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model NaturalEvolutionRabbitsMOdel1

global {
	
	int INITIAL_NUMBER_RABBIT <- 50;
	int INITIAL_NUMBER_WOLF <- 10;
	int INITIAL_NUMBER_OF_GRASS <- 50;
	string saison <- "sec";
	bool long_teeth_global <- false;
	bool brown_fur_global <- false;
	bool mass_fur_global <- true;
	int nb_rabbits -> {length (Rabbit)};
	int nb_wolfs -> {length (Wolf)};
	int nb_grass -> {length (Grass)};	
	
	// DEfinition des genes des lapins a etidier
	int nb_rabbit_brown -> {length(list(Rabbit) where(each.color = #brown ))};
	int nb_rabbit_red -> {length(list(Rabbit) where(each.color = #red ))};
	
	int nb_rabbit_mass -> {length(list(Rabbit) where(each.mass_fur = true ))};
	int nb_rabbit_thin -> {length(list(Rabbit) where(each.mass_fur = false ))};
	
	init {
		create Rabbit number: INITIAL_NUMBER_RABBIT {
			if(brown_fur) {
				color <- #brown;
			}
		}
		create Wolf number: INITIAL_NUMBER_WOLF;
		create Grass number: INITIAL_NUMBER_OF_GRASS {
			if(saison = "pluvieuse") {
				grow_speed <- 1.5;
				reprod_speed <- 6;
			} else if ( saison  = "neige") {
				grow_speed <- 0.4;
				reprod_speed <- 8;
			}
		}
	}
	
	reflex updateChart {
		
	}
	
	//  Stop simulation when the number of the rabit = 0
	reflex stop_simulation when: (nb_rabbits = 0 or nb_rabbits > 1000) {
		do pause ;
	} 
}

species Rabbit skills:[moving] {
	rgb color <- #red;
	int size <- rnd(2,3);
	int observation_range <- 5;
	int reprod_range <- 2;
	int alert_range <- 15;
	int alert_duration <- 10;
	int alert_count <- 0;
	int age <- 0;
	int reprod_age <- 10;
	int reprod_speed <- 15;
	int reprod_count <- 0;
	int max_age <- 40;
	
	// =========== EAT CAPACITY ============
	int eat_capacity <- 1;
	int current_hungry_time <- 0;
	int max_hungry_time <- 15;
	float consomation_speed <- 0.5;
	float hungry_state <- 10.0;
	
	int count_hungry <- 0;
	
	bool long_teeth <- flip(0.5);
	bool brown_fur <- flip(0.5);
	bool mass_fur <- flip(0.5);
	reflex live {
		do wander;
		
		// Each circle increase age
		age <- age + 1;
		reprod_count <- reprod_count + 1;
		if(age >= max_age) {
			do die;
		}
		hungry_state <- hungry_state - consomation_speed;
		
		if(count_hungry > max_hungry_time) {
			do die;
		}
		if(hungry_state <= 0) {
			count_hungry <- count_hungry + 1;
		}
		
	}
	
	reflex seek_and_eat when:(hungry_state < max_hungry_time){
		hungry_state <- 0.0;
		list<Grass> foods <- list(Grass) where(each distance_to self < observation_range and size >= min_size);
		if(length(foods) > 0) {
			Grass vict <- one_of(foods);
			hungry_state <- hungry_state + vict.size;
			ask vict {
				size <- self.min_size;
			}
			if(count_hungry > 0 ) {
				count_hungry <- 0;
			}
		}
		
	
	}
	
	reflex reproduce when:(age >= reprod_age and reprod_count > reprod_speed){
		
		// find peeps in observation_range
		list<Rabbit> peeps <- list(Rabbit) where(each distance_to self < reprod_range);
		if(length(peeps) > 0) {
			Rabbit partner <- one_of(peeps);
			create Rabbit number: 1 {
				
				// If both have the same genes for teeth
				if(partner.long_teeth = self.long_teeth){
					long_teeth <- partner.long_teeth;
				}else {
					if(!long_teeth_global){
						long_teeth <- false;
					}else{
						long_teeth <- true;
					}
				}
				
				// If brown fur is dominant or recessif
				if(partner.brown_fur = self.brown_fur){
					brown_fur <- partner.brown_fur;
				}else {
					if(!brown_fur_global){
						brown_fur <- false;
					}else{
						brown_fur <- true;
						color <- #brown;
					}
				}
				
				// if mass fure is dominant or recess
				if(partner.mass_fur = self.mass_fur){
					mass_fur <- partner.mass_fur;
				}else {
					if(!mass_fur_global){
						mass_fur <- false;
					}else{
						mass_fur <- true;
						size <- 3;
					}
				}
				
				if(saison = "pluvieuse") {
					if (mass_fur){
						max_age <- 60;
					}else {
						max_age <- 30;
					}
				}else if (saison = "neige") {
					
					// Si c'est la saison des neige celui avec la plus grande fourur aura une duree de vie plus long
					if (mass_fur){
						max_age <- 50;
					}else {
						max_age <- 30;
					}
				}
			}
			reprod_count <- 0;
		}
		
	}
	reflex detect_danger {
		list<Wolf> dangers  <- list(Wolf) where(each distance_to self < observation_range);
		
		// Alert other if there's a wolf near
		if(length(dangers) > 0 ) {
			do alerter;
		}
	}
	reflex alert when: (alert_count > 0){
		alert_count <- alert_count + 1;
		
		// Check if alert duration already done
		// If alert mode increase speed
		speed <- 6.0;
		if(alert_count >= 10 ){
			alert_count <- 0;
			speed <- 2.0;
		}
		
		// Find all rabit within alert_range
		list<Rabbit> congeneres  <- list(Rabbit) where(each distance_to self < alert_range);
		
		// Ask all rabit to alert
		loop c over: congeneres {
			
			// If the rabbit is not already in alert mod
			if(c.alert_count = 0) {
				ask c {
					do alerter;
				}
			}
		}
		
	}
	
	action alerter {
		alert_count <- alert_count + 1;
	}
	aspect base {
		if(brown_fur){
			draw circle(size) color: #brown;
		}else {
			draw circle(size) color:color;
		}
		
	}
}

species Wolf skills:[moving]{
	rgb color <- #black;
	int size <- 4;
	
	int observation_range <- 8;
	reflex seek_and_eat {
		do wander;
		
		list<Rabbit> foods <- list(Rabbit) where(each distance_to self < observation_range);
		if(length(foods) > 0 ) {
			Rabbit victime <- one_of(foods);
			ask victime {
				do die;
			}
		}
		
	}
	aspect base {
		draw circle(size) color:color;
	}
	
	
}

species Grass {
	float size <- 1.0;
	float min_size <- 0.5;
	float max_size <- 3.0;
	float grow_speed <- 0.5;
	int reprod_speed <- 8;
	int reprod_count <- 0;
	rgb color <- #green;
	
	reflex live {
		if(size < max_size) {
			size <- size + grow_speed;
		}
		if(size > min_size) {
			reprod_count <- reprod_count + 1;
		}
	}
	
	reflex reproduce when:(size > min_size and reprod_count > reprod_speed) {
		point current_loc <- location;
			if(length(agents_inside(circle(size, {current_loc.x+3.0, current_loc.y})))	= 0){
				current_loc <-  {current_loc.x + 3.0, current_loc.y};
			}else if (length(agents_inside(circle(size, {current_loc.x, current_loc.y + 5.0})))	= 0){
				current_loc <-  {current_loc.x, current_loc.y + 3.0};
			} else if (length(agents_inside(circle(size, {current_loc.x - 3.0, current_loc.y})))	= 0){
				current_loc <-  {current_loc.x - 3.0, current_loc.y };
			}else if (length(agents_inside(circle(size, {current_loc.x - 3.0, current_loc.y})))	= 0){
				current_loc <-  {current_loc.x , current_loc.y - 3.0};
			}
			if(current_loc != location) {
				create Grass number: 1 {
					location <- current_loc;	
				}
			}
	}
	
	
	aspect base {
		draw square(size) color:color;
	}
}

experiment FirstStage type: gui {
	
	// Define parameters here if necessary
	parameter "RABBITS" category: "AGENTS" var: INITIAL_NUMBER_RABBIT min: 1 max:1000;
	parameter "WOLF" category: "AGENTS" var: INITIAL_NUMBER_WOLF;
	parameter "Saison" category:"ENVI" var: saison <- "sec" among: ["sec","pluvieuse","neige"];
	
	parameter "Fur" category: "GENETICS" var: mass_fur_global;
	parameter "Skin" category: "GENETICS" var: brown_fur_global;
	parameter "Teeth" category: "GENETICS" var: long_teeth_global;
	
	output {
	// Define inspectors, browsers and displays here

	 display "Basic Env" { 
			species Rabbit aspect: base;
			species Wolf aspect: base;
			species Grass aspect: base;
//	 		grid a_grid;
	 }
	 
	 display "Population" {
	 	chart "Species evolution" type: series size: {1,0.5} position: {0, 0} {
				data "number_of_rabbit" value: nb_rabbits color: #red ;
				data "number_of_wolf" value: nb_wolfs color: #black ;
				data "number_of_grass" value: nb_grass color: #green;
			}
			chart "Genetics mutation skin" type: series  size: {0.5,0.5} position: {0, 0.5} {
				data "White fur" value: nb_rabbit_red color: #blue ;
				data "Brown fur" value: nb_rabbit_brown color: #brown ;
			}
			
			chart "Genetics mutation fur" type: series  size: {0.5,0.5} position: {0.5, 0.5} {
				data "Mass fur" value: nb_rabbit_mass color: #orange ;
				data "Thin fur" value: nb_rabbit_thin color: #violet ;
			}
	 }
	 	monitor "Number of rabbit" value: nb_rabbits;
		monitor "Number of wolf" value: nb_wolfs;

	}
}