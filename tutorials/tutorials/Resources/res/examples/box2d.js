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

// when camera is changed we can get coordinates for screen bounds
// we also have information about screen width/height

// setup layout
function setuplayout()
{
    var x2 = Q.layout.hudxmax;    
    var y2 = Q.layout.hudymax;
	
	var areas = new Array();
	
	// add text labels
	var item = new LayoutArea();
	item.type = "text.button";
	item.background="FF331133";
	item.location= (x2- 1.2) +','+(y2-0.11);
	item.bounds="1.0,0.2";
	item.display = "hud";
	item.text = "Throw Cube";
	item.onclick = "js:menu_addObject(0);";
	item.onfocuslost = "js:menu_focuslost";
	item.onfocusgain = "js:menu_focusgain";	
	areas.push(item);
	
    
	var item = new LayoutArea();
	item.type = "text.button";
	item.background="FF331133";
	item.location= (x2- 2.2) +','+(y2-0.11);
	item.bounds="1.0,0.2";
	item.display = "hud";
	item.text = "Throw Sphere";
	item.onclick = "js:menu_addObject(1);";
	item.onfocuslost = "js:menu_focuslost";
	item.onfocusgain = "js:menu_focusgain";	
	areas.push(item);

	var item = new LayoutArea();
	item.type = "text.button";
	item.background="FF331133";
	item.location= (x2- 3.2) +','+(y2-0.11);
	item.bounds="1.0,0.2";
	item.display = "hud";
	item.text = "Throw Area";
	item.onclick = "js:menu_addObject(2);";
	item.onfocuslost = "js:menu_focuslost";
	item.onfocusgain = "js:menu_focusgain";	
	areas.push(item);
	
	
	// add exit area
	var areaExit = new LayoutArea();    
	areaExit.type = 'layout.back';
	// setbackground
	areaExit.background = 'FFFFFFFF,icons.2.8.8';
	areaExit.location= (x2- 0.11) +','+(y2-0.11);
	areaExit.bounds = '0.20,0.20';
	areaExit.display = 'hud';
	areaExit.onclick = 'js:box2d_exit';
    areas.push(areaExit);
    
	Q.layout.add("box2d", areas).now();
	// show page
	Q.layout.show("box2d").now();	
	
	
}



function box2d_exit(area,index)
{
	Q.startUpdate();
	Q.box2d.remove("world1");

	Q.objects.remove("plane1");
	Q.objects.remove("floor");
	Q.objects.remove("floor2");
	Q.objects.remove("modelsphere");
	Q.objects.remove("modelcube");
	Q.layout.clear("box2d");
	
	// go to default
	Q.camera.fit( "4.0,0");
	Q.camera.fitHud( "4.0,0");
	Q.layout.show('mainmenu');
	
	Q.sendUpdate();
}

function setupObjects()
{
	// setup world camera
	Q.camera.set(0,0,0, 0,-0.8,4 , "world").now();
	// create plane
	var objects = new Array();
	
	
	var object = new WorldObject();
	object.name = "plane1";
	object.template = "plane";
	object.location = "0.0,0.0,0.0";
	object.bounds = "5.5,5.5,1.0";
	object.texture = "back";
	object.state = "visible";		
	objects.push(object);
	
	// create floor
	var object = new WorldObject();
	object.name = "floor";
	object.template = "cube.4.1.1";
	object.location = "0.0,-1.0,0.2";
	object.bounds = "3.0,0.5,0.5";
	object.texture = "qtext";
	object.color = "55FFFFFF";
	object.state = "visible";	
	objects.push(object);
	
	var object = new WorldObject();
	object.name = "floor2";
	object.template = "cube.4.1.1";
	object.location = "0.0,-0.625,0.2";
	object.bounds = "1.0,0.25,0.5";
	object.texture = "qtext";
	object.color = "55FFFFFF";
	object.state = "visible";	
	objects.push(object);
	
	/*
	// create dyn box
	var object = new WorldObject();
	object.name = "model";
	object.template = "cube";
	object.location = "0.0,1.0,0.1";
	object.bounds = "0.2,0.2,0.2";
	object.texture = "qtext";
	object.state = "visible";	
	objects.push(object);
	*/
	
	Q.objects.add(objects).now();
	
	
}


var countcube = 0;
var countsphere = 0;
var countarea = 0;

function menu_addObject(type)
{
	if (type == 2)
	{
		var areas = new Array();
		
		var area = new LayoutArea();
		area.id = "boxarea" + countarea;
		area.type = "text.label";
		area.background = "AA44AB44";
		area.text = "TextArea";
		area.bounds = "0.8,0.2";
		area.location =((Math.random()-0.5) * 2) +",1.0,0.1";
		areas.push(area);
		Q.layout.add("box2d", areas).now();
		
		Q.layout.areaSetState("boxarea" + countarea , "visible" ).now();
		
		var models = new Array();
		var model = new Box2dModel();
		model.type = "area";
		model.refid = "boxarea" + countarea;
		model.name = "modelarea"+countarea;
		model.template = "box";
		
		model.groupIndex = 0; 
		model.friction = 0.3;
		model.density = 10;
		model.restitution = 0.1;
		countarea++;	
		models.push(model);
		Q.box2d.add("world1",models).now();		
		return;
	}
	
	var objects = new Array();
	
	// create dyn box
	var object = new WorldObject();
	
	
	if (type == 0)
	{
		if (countcube == 0)
		{
			object.name = "modelcube";
		}else
		{
			object.name = "modelcube."+ countcube;	
		}
		
		object.template = "cube";	
	}else if (type == 1)
	{
		if (countsphere == 0)
		{
			object.name = "modelsphere";
		}else
		{
			object.name = "modelsphere."+ countsphere;	
		}
		
		object.template = "sphere";
	}	
	object.location = ((Math.random()-0.5) * 2) +",1.0,0.1";
	object.bounds = "0.2,0.2,0.2";
	object.texture = "qtext";
	object.state = "visible";	
	objects.push(object);
	
	Q.objects.add(objects).now();
	
	
	var models = new Array();
	
	var model = new Box2dModel();
	model.type = "dynamic";
	if (type == 0)
	{	
		model.refid = "modelcube." + countcube;
		model.name = "modelcube"+countcube;
		model.template = "box";
		countcube++;
	}else
	{
		model.refid = "modelsphere." + countsphere;
		model.name = "modelsphere"+countsphere;
		model.template = "circle";
		countsphere++;
	}
	
	model.groupIndex = 0; 
	model.friction = 0.3;
	model.density = 10;
	model.restitution = 0.1;
		
	models.push(model);
	
	Q.box2d.add("world1",models).now();
	
}


function setupBox2d()
{
	// create world
	Q.box2d.create("world1","0,-1","xy").now();
	
	// create box model
	
	var models = new Array();
	
	// model is always binded to already created engine model
	var model = new Box2dModel();
	model.refid = "floor.0";
	model.type = "fixed";
	model.name = "modelbase";
	model.template = "box";
	models.push(model);

	var model = new Box2dModel();
	model.refid = "floor2.0";
	model.type = "fixed";
	model.name = "modelbase2";
	model.template = "box";
	models.push(model);
	
	/*
	var model = new Box2dModel();
	model.refid = "model.0";
	model.type = "dynamic";
	model.name = "model0";
	models.push(model);
	*/
	Q.box2d.add("world1",models).now();
	
}


setupObjects();
setupBox2d();
Q.startUpdate();
Q.evals(0,"setuplayout();");
Q.sendUpdate();


