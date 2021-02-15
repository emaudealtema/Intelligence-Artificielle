/***
* Name: epidemie
* Author: azem
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model epidemie

/* Insert your model definition here */

global{
	int number_of_people<-50;
	int number_of_rat<-20;
	
	init{
		create People number: number_of_people;
		create Rat number: number_of_rat;
	}
}

species People skills:[moving]{
	
	bool is_infected<-false;
	
	reflex moving{
		do wander;
	}
	
	aspect base {
		draw square(3) color:(is_infected)?#red:#green;
	}
	
}

species Rat skills:[moving]{
	
	bool is_infected<-flip(0.2);
	int attack_range<-5;	
	reflex moving{
		do wander;
	}
	
	reflex attack when:!empty(People at_distance attack_range){
		ask People at_distance attack_range{
			if(self.is_infected){
				myself.is_infected<-true;
			}
			else if(myself.is_infected){
				self.is_infected<-true;
			}
		}
	}
	
	aspect base {
		draw circle(1) color:(is_infected)?#red:#black;
	}
	
}



experiment RatContamination type: gui{
	
	parameter "number of peoples:" var: number_of_people;
	parameter "number of rat:" var: number_of_rat;
	
	output{
	
	display my_display{
		
		species People aspect:base;
		species Rat aspect:base;
	}
	
	display my_chart{
		chart "number of infected people"{
			data "infected people" value:length(People where(each.is_infected = true));
		}
	}
  }
	
}
