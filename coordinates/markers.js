var colors = [
"Gray",
"Red",
"Maroon",
"Yellow",
"Olive",
"Lime",
"Green", 
"Aqua",
"Teal",
"Blue",
"Navy",
"Fuchsia",
"Purple"];

function getRequest(){
	var xhr; 
   	try {  
   		xhr = new ActiveXObject('Msxml2.XMLHTTP');
   	}catch (e) {
       	try {   
       		xhr = new ActiveXObject('Microsoft.XMLHTTP');
       	}catch (e2) {
			try {  
				xhr = new XMLHttpRequest();
       		}catch (e3) {  xhr = false;   }
       	}
   	}
   	return xhr;
}

function asyncBuilding(){
	var http = getRequest();
	//reseting the background.
	cleanup();
   	http.onreadystatechange  = function(){ 
		if(http.readyState  == 4){
       		if(http.status  == 200) {
   	         	results = eval('(' + http.responseText + ')');
   	         	var txt = "";
   	         	/*
   	         	if(results.length > 1){
   	         		txt = "Found "+results.length+" results : ";
   	         	}
   	         	if(results.length == 1 && results[0] != undefined && results[0].word != undefined){
   	         		txt = "Found one result : ";
   	         	}
   	         	if(results.length < 1){
   	         		txt = "No results found. <br/>Try with less letters or numbers.";
   	         	}
   	         	if(results.length >15){
   	         		txt = "Found "+results.length+" result. Please refine your search. <br/> Showing first 15 :";
   	         	}*/

         		var mey = 0;
         		var pre = 0;
         		var meyC = document.getElementById('canvas_meyrin').getContext('2d');
		   		var preC = document.getElementById('canvas_prevessin').getContext('2d');
					
   	         	for(var i = 0; i< results.length; i++){  	  				
   					var loc = results[i];
   					if(loc != undefined && loc.word != undefined){
   						node = document.createElement('li');
	   					node.innerHTML = loc.word;
	   					if(loc.filePrefix == "CERN_Prevessin_A3_Paysage"){
	   						if(pre < 31){
	   							document.getElementById("results_list_prevessin").appendChild(node);		
		   						drawMarker(node,preC,pre,loc.x1,loc.y1,loc.x2,loc.y2);
		   					}
		   					pre++;
		   				}else{
		   					if(mey < 31){
	   							document.getElementById("results_list_meyrin").appendChild(node);		
		   						drawMarker(node,meyC,mey,loc.x1,loc.y1,loc.x2,loc.y2);
		   					}
		   					mey++;
						}		   				
	   				}
   				}
   				if(pre>0){
   					showImage('CERN_Prevessin_A3_Paysage');
   				}
   				if(mey>0){
   					showImage('CERN_Meyrin_A3_Paysage');
   				}
   				txt = "More elements available, only showing first 30. Please refine your search.";
   				if(pre>30){
						node = document.createElement('li');
	   					node.innerHTML = txt;
						document.getElementById("results_list_prevessin").appendChild(node);		
   				}
   				if(mey>30){
					node = document.createElement('li');
	   				node.innerHTML = txt;
					document.getElementById("results_list_meyrin").appendChild(node);		
				}
	   			document.getElementById("title_div_meyrin").innerHTML = "Meyrin ("+mey+") :";
         		document.getElementById("title_div_prevessin").innerHTML = "Prevessin ("+pre+") :";
         		
       	    } else {
	   	         //document.getElementById('ajax').value="Error code " + http.status + " " +http.responseText;
        	    }
        	 }
    	};
		var test = document.getElementById("buildingName").value;
 		var url="buildingName="+test;
 		http.open("POST", "index.cgi",  true);
   		http.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
		http.setRequestHeader("Content-length", url.length);
		http.setRequestHeader("Connection", "close");
   		http.send(url);
}

function showImage(key){
	var mey = document.getElementById('canvas_meyrin');
   	var pre = document.getElementById('canvas_prevessin');
	
	var me = document.getElementById('title_div_meyrin');
	var pr = document.getElementById('title_div_prevessin');
	
	var m = document.getElementById('results_div_meyrin');
	var p = document.getElementById('results_div_prevessin');
	
	if(key == "CERN_Prevessin_A3_Paysage"){
		mey.style.visibility = 'hidden';
		pre.style.visibility = 'visible';
		pr.style.borderBottom= 'none';
		me.style.borderBottom= 'solid';
		p.style.visibility = 'visible';
		m.style.visibility = 'hidden';
	}else{
		pre.style.visibility = 'hidden';
		mey.style.visibility = 'visible';
		me.style.borderBottom= 'none';
		pr.style.borderBottom= 'solid';
		m.style.visibility = 'visible';
		p.style.visibility = 'hidden';
	}
}
/*
Cleaning up the canvas and results
*/
function cleanup(){

	var cell = document.getElementById("results_list_prevessin");
	if ( cell.hasChildNodes()){
	    while ( cell.childNodes.length >= 1 ){
	        cell.removeChild( cell.firstChild );       
    	} 
	}
	cell = document.getElementById("results_list_meyrin");
	if ( cell.hasChildNodes()){
	    while ( cell.childNodes.length >= 1 ){
	        cell.removeChild( cell.firstChild );       
    	} 
	}
	document.getElementById('canvas_meyrin').getContext('2d').clearRect(0,0,1600,1224);
   	document.getElementById('canvas_prevessin').getContext('2d').clearRect(0,0,1600,1224);
	document.getElementById("title_div_meyrin").innerHTML = "Meyrin :";
	document.getElementById("title_div_prevessin").innerHTML = "Prevessin :";

   	draw();
}

/*
load the images
*/
function draw() {
	var mey = document.getElementById('canvas_meyrin').getContext('2d');
   	var pre = document.getElementById('canvas_prevessin').getContext('2d');

	var m = document.getElementById('canvas_meyrin');
   	var p = document.getElementById('canvas_prevessin');
    
    document.prevessin = new Image();
    document.prevessin.onload = function(){
      pre.drawImage(document.prevessin,0,0);
      p.style.visibility = 'hidden';
    }
    document.prevessin.src = 'CERN_Prevessin_A3_Paysage.png';

    document.meyrin = new Image();
  	document.meyrin.onload = function(){
      mey.drawImage(document.meyrin,0,0);
      m.style.visibility = 'hidden';
    }
    document.meyrin.src = 'CERN_Meyrin_A3_Paysage.png';
	m.style.visibility = 'hidden';
	p.style.visibility = 'hidden';
}
 
function drawMarker(node,ctx,cnt,x1,y1,x2,y2){
	var bbox = node.getBoundingClientRect();

	var xOffset=window.scrollX;
	var yOffset=window.scrollY;

    ctx.strokeStyle = colors[cnt % colors.length];//'darkorange';
    ctx.beginPath();
    ctx.lineWidth = 3;
    ctx.moveTo(0,0);
    y1 = (1124 - y1*1.3333333  );  
    x1 = x1 * 1.3333;
    y2 = (1124 - y2*1.3333333  );
    x2 = x2 * 1.3333;
    if( xOffset==undefined){
    	xOffset=0;}
	if( yOffset==undefined){
    	yOffset=0;}
	ctx.moveTo(bbox.left+xOffset,bbox.top+bbox.height+yOffset);
	ctx.lineTo(x1,bbox.top+bbox.height+yOffset);    
 	//ctx.moveTo(x1,0);
    ctx.lineTo(x1,y1);
    //ctx.lineTo(0,y1);
    ctx.stroke();
   	//ctx.font="bold 16px sans-serif";
    //ctx.fillText(node.innerHTML, x1,bbox.top+bbox.height+yOffset); 

    
  }