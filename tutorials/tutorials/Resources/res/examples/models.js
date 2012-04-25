/*
   Copyright 2012, Telum Slavonski Brod, Croatia.

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
   
   This file is part of QFramework project, and can be used only as part of project.
   Should be used for peace, not war :)   
*/

// simple models 

// setup layout
function setuplayout()
{
	// round to fixed for better display, but use full float in calculations
    var x1 = Q.layout.hudxmin.toFixed(1);
    var x2 = Q.layout.hudxmax.toFixed(1);    
    var y1 = Q.layout.hudymin.toFixed(1);
    var y2 = Q.layout.hudymax.toFixed(1);
    
    var wx1 = Q.layout.worldxmin.toFixed(1);
    var wx2 = Q.layout.worldxmax.toFixed(1);    
    var wy1 = Q.layout.worldymin.toFixed(1);
    var wy2 = Q.layout.worldymax.toFixed(1);

    var areas = new Array();
    
	// add exit area
	var areaExit = new LayoutArea();    
	areaExit.type = 'layout.back';
	areaExit.background = 'FFFFFFFF,icons.2.8.8';
	areaExit.location= (x2- 0.11) +','+(y2-0.11);
	areaExit.bounds = '0.20,0.20';
	areaExit.display = 'hud';
	areaExit.onclick = 'js:test_exit';
    areas.push(areaExit);
    
	Q.layout.add("models", areas).now();
	// show page
	Q.layout.show("models").now();	

	Q.startUpdate();
	Q.models.newEmpty("m1");
	Q.models.addShape("m1", "plane");
	Q.models.addShape("m1", "plane" ,"1.0,1.0,0.0","FFFFFFFF,66FFFFFF","0.5,0.0,1.0,0.5");
	Q.models.addShape("m1", "plane" ,"-1.0,1.0,0.0","66FFFFFF,FFFFFFFF","0.0,0.0,0.5,0.5");
	Q.models.addShape("m1", "plane" ,"1.0,-1.0,0.0","FFFFFFFF,66FFFFFF","0.5,0.5,1.0,1.0");
	Q.models.addShape("m1", "plane" ,"-1.0,-1.0,0.0","66FFFFFF,FFFFFFFF","0.0,0.5,0.5,1.0");
	//Q.models.setTexture("m1" , "icons;8,8");
	Q.models.setTexture("m1" , "icons;8,8");
	Q.models.create("m1");
	Q.sendUpdate();

	// zero object - define object from model
	var object = new WorldObject();
	object.name = "plane1";
	object.template = "m1";
	object.location = "0.0,-0.0,0.0";
	object.bounds = "0.4,0.4,0.4";
	object.state = "visible";

	var objects = new Array();
	objects.push(object);
	Q.objects.add(objects).now();
	

	// use batch rendering
	Q.startUpdate();
	Q.objects.place("plane1.1", "0.0,1.0,0.1");
	Q.objects.scale("plane1.1", "0.2,0.2");
	Q.objects.state("plane1.1", "visible");
	Q.objects.texture("plane1.1","","17,64");
	
	Q.objects.place("plane1.2", "0.0,-1.0,0.1");
	Q.objects.scale("plane1.2", "0.2,0.2");
	Q.objects.state("plane1.2", "visible");
	Q.objects.texture("plane1.2","","18,64");

	Q.objects.place("plane1.3", "1.0,0.0,0.1");
	Q.objects.scale("plane1.3", "0.2,0.2");
	Q.objects.state("plane1.3", "visible");
	Q.objects.texture("plane1.3","","19,64");
	
	Q.objects.place("plane1.4", "-1.0,0.0,0.1");
	Q.objects.scale("plane1.4", "0.2,0.2");
	Q.objects.state("plane1.4", "visible");
	Q.objects.texture("plane1.4","","20,64");
	
	Q.sendUpdate();
}


function test_exit(area,index)
{
	Q.startUpdate();
	Q.layout.clear("models");
	
	Q.objects.remove("plane1");
	
	// go to default
	Q.camera.fit( "4.0,0");
	Q.camera.fitHud( "4.0,0");
	Q.layout.show('mainmenu');
	Q.sendUpdate();
	
	
}

function animobjects()
{
	Q.startUpdate();
	Q.anim.rotate("cube1","360,0,0","1000,10","");
	Q.anim.move("plane1","0.3,-0.5,0.2","1000,3","");
	Q.anim.move("sphere1","-0.3,-1.1,0.2","1000,-3","");
	Q.sendUpdate();
}


// change camera to see difference
Q.camera.set(0,0,0, 0,-2,2).now();
// put layout into queue to allow camera change to take effect
Q.evals(0,"setuplayout();").now();


Q.evals(2000,"startRotate();").now();

function startRotate()
{
	Q.startUpdate();
	Q.anim.rotate("plane1.1","0,0,360","1000,10","");
	Q.anim.rotate("plane1.2","0,0,360","2000,10","");
	Q.anim.rotate("plane1.3","0,0,360","4000,10","");
	Q.anim.rotate("plane1.4","0,0,-360","8000,10","");
	Q.sendUpdate();
}


