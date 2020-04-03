<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8" />
		<title>挖矿小游戏</title>
		<link rel="stylesheet" type="text/css" href="css/game.css"/>
	</head>
	<body>
		<div id="wrapBg">  <!--游戏背景-->
			<div id="headTitle"> <!--开始标题-->
				<img id="headBird" src="img/bird0.png" alt="小鸟" /> <!--标题中的小鸟-->
			</div>
			<button id="startBtn" ></button> <!--开始按钮-->
			<div id="grassLand1"></div> <!--草地1-->
			<div id="grassLand2"></div> <!--草地2-->
			<div id="score">
				<div id="num1"></div>
				<div id="num2"></div>
				<div id="num3"></div>
			</div>
			<div id="gameOver">
				<img src="img/game_over.jpg" alt="game over" />
				<img src="img/message.jpg" alt="message" />
				<img id="ok" src="img/ok.jpg" alt="ok" />
			</div>
		</div>
		<input type="hidden" value="<%=request.getParameter("address")%>" id="address">
	</body>
	<script src="js/block.js" type="text/javascript" charset="utf-8"></script>
	<script src="js/baseObj.js" type="text/javascript" charset="utf-8"></script>
	<script src="js/bird.js" type="text/javascript" charset="utf-8"></script>
	<script type="text/javascript">
		var jsWrapBg = document.getElementById("wrapBg");
		var jsHeadTitle = document.getElementById("headTitle");// 获取标题
		var jsHeadBird = document.getElementById("headBird"); // 获取标题中小鸟
		var blocksArr = [];  //用来储存block的数组
		var blockDistance = baseObj.randomNum(120,350);
		
		var jsScore = document.getElementById("score");
		var jsNum1 = document.getElementById("num1");
		var jsNum2 = document.getElementById("num2");
		var jsNum3 = document.getElementById("num3");
		var score = 0;
		
		var jsGameOver = document.getElementById("gameOver");
		var jsOkBtn = document.getElementById("ok");
		
		var Y = 3;//标题的摆动幅度
		var index = 0;
		var imgArr = ["img/bird0.png","img/bird1.png"] 
		//将小鸟图片路径放入一个数组，利用帧动画的原理做出小鸟翅膀摆动的样子
		var headWaveTimer = setInterval(headWave,200); //设置标题上下摆动的定时器
		function headWave() {
			Y *= -1;
			jsHeadTitle.style.top = jsHeadTitle.offsetTop + Y + "px";
			jsHeadBird.src = imgArr[index++];
			if (index == 2) {
				index = 0;
			}
		}
		
		var jsGrassLand1 = document.getElementById("grassLand1"); //获取草地1
		var jsGrassLand2 = document.getElementById("grassLand2"); //获取草地2
		
		var landTimer = setInterval(landRun,30); //让草地动起来的定时器
		function landRun() {
			if (jsGrassLand1.offsetLeft <= -343) {
				jsGrassLand1.style.left = "343px";
			}
			if (jsGrassLand2.offsetLeft <= -343) {
				jsGrassLand2.style.left = "343px";
			}
			jsGrassLand1.style.left = jsGrassLand1.offsetLeft - 3 + "px";
			jsGrassLand2.style.left = jsGrassLand2.offsetLeft - 3 + "px";
			
			if (blocksArr.length) {
				for (var i = 0; i < blocksArr.length; i++) {
					blocksArr[i].moveBlock();
					var x =baseObj.rectangleCrashExamine(blocksArr[i].downDivWrap, bird.div);
					var y = baseObj.rectangleCrashExamine(blocksArr[i].upDivWrap, bird.div);
					var z = bird.div.offsetTop >= 390;
					if (x || y || z) {
						window.clearInterval(landTimer);//清除landTimer定时器
						bird.fallSpeed = 0; //小鸟下落
						jsWrapBg.onclick = null; //消除点击事件
						//jsScore.style.display = "none"; //隐藏计分器
						jsGameOver.style.display = "block"; // 显示gameover面板
					}
				}
				if (blocksArr[blocksArr.length - 1].downDivWrap.offsetLeft < (450 - blockDistance)) {
						blockDistance = baseObj.randomNum(130,250);
						var newBlock = new Block();
						newBlock.createBlock();
						blocksArr.push(newBlock);
				}
				
				if (blocksArr[0].downDivWrap.offsetLeft == -12) {
						score++;//积分面板
						if (score < 10) {
							jsNum1.style.backgroundImage = "url(img/" + score + ".jpg)";
						} else if (score < 100) {
							jsNum2.style.display = "block";
							jsNum1.style.backgroundImage = "url(img/" + parseInt(score/10) + ".jpg)";
							jsNum2.style.backgroundImage = "url(img/" + score%10 + ".jpg)";
						} else if (score < 1000) {
							jsNum3.style.display = "block";
							jsNum1.style.backgroundImage = "url(img/" + parseInt(score/100) + ".jpg)";
							jsNum2.style.backgroundImage = "url(img/" + parseInt(score/10)%10 + ".jpg)";
							jsNum3.style.backgroundImage = "url(img/" + score%10 + ".jpg)";
						}
						console.log(score);
				}
				
				if (blocksArr[0].downDivWrap.offsetLeft < -50) {
						jsWrapBg.removeChild(blocksArr[0].downDivWrap);
						jsWrapBg.removeChild(blocksArr[0].upDivWrap);
						blocksArr.shift(blocksArr[0]);
				}
			}
		}
		
		var jsStartBtn = document.getElementById("startBtn");
		jsStartBtn.onclick = function() { //为start按键添加点击事件处理程序
			jsHeadTitle.style.display = "none"; //隐藏标题
			clearInterval(headWaveTimer); //关闭让标题摆动的定时器
			jsStartBtn.style.display = "none"; //隐藏按键
			bird.showBird(jsWrapBg); //插入小鸟到界面中
			bird.flyBird(); //控制小鸟飞翔下落
			bird.wingWave(); //逐帧动画，小鸟煽动翅膀
			jsWrapBg.onclick = function(){
				bird.fallSpeed = -8;
			};
			var b = new Block();
			b.createBlock();		
			blocksArr.push(b);
			jsNum1.style.display = "block";
			//待添加功能
			//点击开始按键进入游戏界面
		}
		
		jsOkBtn.onclick = function() {
			window.location.href = "mine?address="+document.getElementById("address").value;//刷新页面
		}
		
	</script>
</html>
