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
    var x1 = Q.layout.hudxmin;
    var x2 = Q.layout.hudxmax;    
    var y1 = Q.layout.hudymin;
    var y2 = Q.layout.hudymax;
    
    var wx1 = Q.layout.worldxmin;
    var wx2 = Q.layout.worldxmax;    
    var wy1 = Q.layout.worldymin;
    var wy2 = Q.layout.worldymax;

    var areas = new Array();
	var areas = new Array();
	
	// add text labels
	var item = new LayoutArea();
	item.type = "text.button";
	item.background="FF331133";
	item.location= (x1+0.4)+","+(y2-0.1);
	item.bounds="0.8,0.1";
	item.display = "hud";
	item.text = "bridge";
	item.onclick = "js:load_object('bridge1');";
	item.onfocuslost = "js:menu_focuslost";
	item.onfocusgain = "js:menu_focusgain";	
	areas.push(item);
	
	var item = new LayoutArea();
	item.type = "text.button";
	item.background="FF331133";
	item.location= (x1+0.4)+","+(y2-0.2);
	item.bounds="0.8,0.1";
	item.display = "hud";
	item.text = "temple";
	item.onclick = "js:load_object('temple1');";
	item.onfocuslost = "js:menu_focuslost";
	item.onfocusgain = "js:menu_focusgain";	
	areas.push(item);

	var item = new LayoutArea();
	item.type = "text.button";
	item.background="FF331133";
	item.location= (x1+0.4)+","+(y2-0.3);
	item.bounds="0.8,0.1";
	item.display = "hud";
	item.text = "castle";
	item.onclick = "js:load_object('castle1');";
	item.onfocuslost = "js:menu_focuslost";
	item.onfocusgain = "js:menu_focusgain";	
	areas.push(item);

	var item = new LayoutArea();
	item.type = "text.button";
	item.background="FF331133";
	item.location= (x1+0.4)+","+(y2-0.4);
	item.bounds="0.8,0.1";
	item.display = "hud";
	item.text = " hut ";
	item.onclick = "js:load_object('hut1');";
	item.onfocuslost = "js:menu_focuslost";
	item.onfocusgain = "js:menu_focusgain";	
	areas.push(item);

	
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
	Q.models.newFromFile("bridge","models/bridge2.obj");
	//Q.models.newFromFile("bridge","models/box.obj");
	Q.models.newFromFile("temple","models/temple.obj");
	Q.models.newFromFile("castle","models/castle.obj");
	Q.models.newFromFile("hut","models/hut.obj");
	Q.models.newFromFile("b2","models/b2.obj");
	Q.models.create("bridge");
	Q.models.create("temple");
	Q.models.create("castle");
	Q.models.create("hut");
	Q.models.create("b2");
	Q.sendUpdate();

	
	// zero object - define object from model

}

function load_object(name)
{
	
	// use batch rendering
	Q.objects.remove(currentmodel).now();
	var objects = new Array();	
	if (name == "temple1")
	{
		var object = new WorldObject();
		object.name = "temple1";
		object.template = "temple";
		object.location = "0.0,-0.0,0.0";
		object.bounds = "0.5,0.5,0.5";
		object.state = "visible";
		objects.push(object);
		
	}else
	if (name == "bridge1")
	{
		var object = new WorldObject();
		object.name = "bridge1";
		object.template = "bridge";
		object.location = "0.0,-0.0,0.0";
		object.bounds = "0.5,1.0,0.5";
		object.state = "visible";
		objects.push(object);		
	}else
	if (name == "castle1")
	{
		var object = new WorldObject();
		object.name = "castle1";
		object.template = "castle";
		object.location = "0.0,-0.0,0.0";
		object.bounds = "0.5,0.5,0.5";
		object.state = "visible";
		objects.push(object);		
	}else
	if (name == "hut1")
	{
		var object = new WorldObject();
		object.name = "hut1";
		object.template = "hut";
		object.location = "0.0,-0.0,0.0";
		object.bounds = "0.5,0.5,0.5";
		object.state = "visible";
		objects.push(object);		
	}
	Q.objects.add(objects).now();

	
	Q.startUpdate();

	Q.objects.state(name+".0", "visible");
	Q.objects.place(name+".1", "0.0,1.0,0.1");
	Q.objects.scale(name+".1", "0.5,0.5,0.5");
	Q.objects.state(name+".1", "visible");
	
	Q.objects.place(name+".2", "0.0,-1.0,0.1");
	Q.objects.scale(name+".2", "0.5,0.5,0.5");
	Q.objects.state(name+".2", "visible");

	Q.objects.place(name+".3", "1.0,0.0,0.1");
	Q.objects.scale(name+".3", "0.5,0.5,0.5");
	Q.objects.state(name+".3", "visible");
	
	Q.objects.place(name+".4", "-1.0,0.0,0.1");
	Q.objects.scale(name+".4", "0.5,0.5,0.5");
	Q.objects.state(name+".4", "visible");
	
	Q.sendUpdate();
	currentmodel = name;
	startRotate(name);
}


function test_exit(area,index)
{
	Q.startUpdate();
	Q.layout.clear("models");	
	Q.objects.remove("bridge1");
	Q.objects.remove("template1");
	Q.objects.remove("castle1");
	Q.objects.remove("hut1");
	
	// go to default
	Q.camera.fit( "4.0,0");
	Q.camera.fitHud( "4.0,0");
	Q.layout.show('mainmenu');
	Q.sendUpdate();
	
	
}



// change camera to see difference
Q.camera.set(0,0,0, 0,-2,2).now();
// put layout into queue to allow camera change to take effect
Q.evals(0,"setuplayout();").now();
Q.evals(0,"load_object('bridge1');").now();

//Q.evals(2000,"startRotate();").now();

var currentmodel = "";

function startRotate(name)
{
	Q.startUpdate();
	Q.anim.rotate(name+".1","0,0,360","1000,10","");
	Q.anim.rotate(name+".2","0,0,360","2000,10","");
	Q.anim.rotate(name+".3","0,0,360","4000,10","");
	Q.anim.rotate(name+".4","0,0,-360","8000,10","");
	Q.sendUpdate();
}
