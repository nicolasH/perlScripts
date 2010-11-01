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

	http.onreadystatechange  = function(){ 
		if(http.readyState  == 4){
       		if(http.status  == 200) {
   	         	results = eval('(' + http.responseText + ')');
   	         	var ctx = document.getElementById('canvas').getContext('2d');
	   			ctx.drawImage(document.prevessin,0,0);
   	         	for(var i = 0; i<results.length; i++){
   	  				
   					var loc = results[i];
   					if(loc != undefined && loc.word != undefined){
	   					drawMarker(loc.word,loc.x1,loc.y1,loc.x2,loc.y2);
	   				}

   				}
   	         	node = document.createElement('li');
   				//node.innerHTML = li.content;
   				//node.id = li.id;
   				//document.getElementById("list_enlever").appendChild(node);
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



function draw() {
	var ctx = document.getElementById('canvas').getContext('2d');
    document.prevessin = new Image();
    document.prevessin.onload = function(){
      ctx.drawImage(document.prevessin,0,0);
    }
    document.prevessin.src = 'prevessin.png';
}
 
function drawMarker(word,x1,y1,x2,y2){
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
    ctx.fillText(word, x1+3,12);
    ctx.moveTo(x1,0);
    ctx.lineTo(x1,y1);
    //ctx.lineTo(0,y1);
    ctx.stroke();
    
  }