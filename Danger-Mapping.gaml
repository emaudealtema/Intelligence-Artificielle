/***
* Name: ms_tp3_Azemena_Henri_Joel
* Author: azem
* Description: 
* Tags: Tag1, Tag2, TagN
***/

model ms_tp3_Azemena_Henri_Joel

/* Insert your model definition here */

global {
	float superficie <- 5#m;
	geometry shape <- square(superficie);
	int nbreRobot <-3;
	int nbreCentreControl <-3;
	int nbredangerPoint <-3;
	int nbrePanneau <- 9;
	
	init{
		create Robot number:nbreRobot;
		create Centre_Control number:nbreCentreControl;
		create DangerPoint number: nbredangerPoint;
		create Panneau number:nbrePanneau; 
	}
	
	// il pose le panneau si la zonne est est dangereuse avec une probabilitee de 0.5
	reflex SignalerDanger when:(flip(0.5)){
		create species: Panneau number:1;
	}
	
	//quand il aura pose 9 panneau, son trajet se termine
	reflex FinParcours when: nbrePanneau < 0 {
		do halt;
	}
	
}


// creation des species ou des agents

species Robot{
	float taille_robot <-0.3;
	rgb couleur_robot  ;
	
	aspect Robot_aspect{
		draw square(taille_robot) color: #green  ;
	}

	
}

species Centre_Control{
	
}

species DangerPoint{
	float taille_panneau <- 0.2;
	rgb couleur_danger ;
	
	aspect Point_Aspect{
		draw circle(0.08) color: #black;
	}
	
	
}

species Panneau{
	float taille_panneau <- 0.1;
	rgb couleur_panneau ;
	
	aspect Panneau_Aspect{
		draw circle(taille_panneau) color: #orange;
	}
	
}


experiment my_main_code {
	
	output{
		display Mon_Affichage{
			species Robot aspect:Robot_aspect;
			species Panneau aspect:Panneau_Aspect;
			species DangerPoint aspect:Point_Aspect;
			
		}
	}
}









