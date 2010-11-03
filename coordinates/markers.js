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
   	         	}

         		document.getElementById("results_title").innerHTML = txt;
   	         	for(var i = 0; i<Math.min(results.length,15); i++){  	  				
   					var loc = results[i];
   					if(loc != undefined && loc.word != undefined){
   						node = document.createElement('li');
	   					node.innerHTML = loc.word;
		   				document.getElementById("results_list").appendChild(node);		
		   				drawMarker(node,loc.x1,loc.y1,loc.x2,loc.y2);
	   				}
   				}
       	    } else {
	   	         document.getElementById('ajax').value="Error code " + http.status + " " +http.responseText;
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

/*
Cleaning up the canvas and results
*/
function cleanup(){

	var cell = document.getElementById("results_list");
	if ( cell.hasChildNodes()){
	    while ( cell.childNodes.length >= 1 ){
	        cell.removeChild( cell.firstChild );       
    	} 
	}
	document.getElementById("results_title").innerHTML="Fetching results...";
	var ctx = document.getElementById('canvas').getContext('2d');
	ctx.drawImage(document.prevessin,0,0);
	
}

function draw() {
	var ctx = document.getElementById('canvas').getContext('2d');
    document.prevessin = new Image();
    document.prevessin.onload = function(){
      ctx.drawImage(document.prevessin,0,0);
    }
    document.prevessin.src = 'prevessin.png';
}
 
function drawMarker(node,x1,y1,x2,y2){
	var bbox = node.getBoundingClientRect();

var xOffset=window.scrollX;//document.getElementById('canvas').parentNode.scrollLeft;
var yOffset=window.scrollY;//document.getElementById('canvas').parentNode.scrollTop;

    alert(xOffset+" "+yOffset);

  	var ctx = document.getElementById('canvas').getContext('2d');
    ctx.strokeStyle = 'darkorange';
    ctx.beginPath();
    ctx.lineWidth = 3;
    ctx.moveTo(0,0);
    ctx.font="bold 16px sans-serif";
    y1 = (1124 - y1*1.3333  );  
    x1 = x1 * 1.3333;
    y2 = (1124 - y2*1.3333  );
    x2 = x2 * 1.3333;
    //ctx.fillText(node.innerHTML, bbox.left,bbox.top+bbox.height); 
    if( xOffset==undefined){
    	xOffset=0;}
	if( yOffset==undefined){
    	yOffset=0;}
	ctx.moveTo(bbox.left-7+xOffset,bbox.top+9+yOffset);
	ctx.lineTo(x1,bbox.top+9+yOffset); 	
 	//ctx.moveTo(x1,0);
    ctx.lineTo(x1,y1);
    //ctx.lineTo(0,y1);
    ctx.stroke();
    
  }