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
	item.id = "menudomainshow";
	item.background="FF331133";
	item.location= (x2- 1.5) +','+(y2-0.11);
	item.bounds="2.0,0.2";
	item.display = "hud";
	item.text = "Show menu";
	item.onclick = "js:menu_showMenu";
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
	areaExit.onclick = 'js:dyndomains_exit';
    areas.push(areaExit);
    
	Q.layout.add("domains", areas).now();
	// show page
	Q.layout.show("domains").now();	
	
	
}



function dyndomains_exit(area,index)
{
	Q.startUpdate();
	Q.layout.clear("domains");
	Q.layout.clear("domainareas");
	Q.layout.clear("worldareas");
	Q.domains.remove("menudomain");
	
	
	Q.env.registerOnTouch("");
	Q.env.registerOnTouchStart("");
	Q.env.registerOnTouchEnd("");
	
	// go to default
	Q.camera.fit( 4.0,0);
	Q.camera.fitHud( 4.0,0);
	Q.layout.show('mainmenu');

	
	Q.sendUpdate();
}

function setupMenuDomain()
{
	Q.startUpdate();
	Q.domains.create("menudomain",1,"0.1,0.1,0.8,0.8");
	Q.camera.fit(4,0 , "menudomain");
	//Q.domains.show("menudomain");
	//Q.domains.hide("menudomain");
	Q.sendUpdate();
	
	var areas = new Array();
	
	var areaBack = new LayoutArea();
	areaBack.type = 'layout.back';
	areaBack.location= '0,0,'+14+','+14+',-0.0';
	areaBack.background = 'FFFFFFFF,back';
	areaBack.display ="menudomain";
	areas.push(areaBack);

	var item = new LayoutArea();
	item.type = "text.mlinew";   // multiline
	item.background="4411EE11";
	item.location= "0.0,0.0,0.1";
	item.display ="menudomain";
	item.size = "4,12";			// size 2 rows with 22 chars
	item.bounds="4.0,2.0";
	item.onfocusgain = "js:onTouchFocusGain";
	item.onfocuslost = "js:onTouchFocusLost";
	item.text = " Example menu, drag to move it on around domain ";
	areas.push(item);
	
	Q.layout.add("domainareas", areas).now();
	Q.layout.show("domainareas", areas).now();
	
	
}



function setupWorldDomain()
{
	Q.startUpdate();
	Q.camera.set(0,1,0, 0,-1,2 );
	//Q.domains.show("menudomain");
	//Q.domains.hide("menudomain");
	Q.sendUpdate();
	var areas = new Array();
	
	var areaBack = new LayoutArea();
	areaBack.type = 'layout.back';
	areaBack.location= '0,0,'+8+','+8+',-0.0';
	areaBack.background = 'FF888888,back';
	areaBack.display ="world";
	areas.push(areaBack);

	
	Q.layout.add("worldareas", areas).now();
	Q.layout.show("worldareas", areas).now();
	
	
}


var currentArea = undefined;
function onTouchFocusGain(area)
{
	lastx = undefined;
	lasty = undefined;	
	currentArea = area;
}



function onTouchFocusLost(area)
{
	lastx = undefined;
	lasty = undefined;	
	currentArea = undefined
}

var menushown = false;

function menu_showMenu()
{
	Q.startUpdate();
	if (menushown == false)
	{
		menushown = true;
		Q.layout.areaSetText("menudomainshow"," Hide menu ");
		Q.domains.show("menudomain");
	}else
	{
		menushown = false;
		Q.layout.areaSetText("menudomainshow"," Show menu ");
		Q.domains.hide("menudomain");
	}
	
	Q.sendUpdate();
	
}

var lastx = undefined;
var lasty = undefined;

function onTouch(x,y)
{
	var deltax = 0;
	var deltay = 0;
	if (lastx != undefined)
	{
		deltax = x - lastx;
		deltay = y - lasty;
	}
	lastx = x;	
	lasty = y;
	
	console.log( " touch on "+currentArea + " " + x + " "+ y +  " " + deltax + " " + (-deltay));
	if (currentArea != undefined)
	{
		Q.layout.areaMove(currentArea,8*deltax+","+4*(-deltay)+",0").now();
	}
	
}

function onTouchStart(x,y)
{
	console.log( " touchStart " + x + " "+ y );
}


function onTouchEnd(x,y,delay)
{
	console.log( " touchEnd " + x + " "+ y + " "+ delay);
}


// change camera to see difference
// put layout into queue to allow camera change to take effect

Q.startUpdate();
Q.evals(0,"setupMenuDomain();");
Q.evals(0,"setupWorldDomain();");
Q.evals(0,"setuplayout();");
Q.env.registerOnTouch("onTouch");
Q.env.registerOnTouchStart("onTouchStart");
Q.env.registerOnTouchEnd("onTouchEnd");
Q.sendUpdate();


// tests domains and mouse events
// hud displays status + exit
// world some 3d elements
// center display domain with menu - drag to move 
// 
