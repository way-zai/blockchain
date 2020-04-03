<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>

<html>
<head>
<meta charset="UTF-8">
<title>区块链</title>
</head>
<style>
body
{	color:white;
	background-image:url(/images/background.jpg);
	background-repeat:norepeat;
	background-size:100% 100%;
	background-attachment: fixed;
}
h1
{
	color:#FFD700;
	text-align:center;
}
input[type=text]{
	width:32%;
	border-radius: 4px;
}
input[type=submit] {
  width: 20%;
  background-color: #4CAF50;
  color: white;
  padding: 8px 10px;
  margin: 4px 0;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}
.center {
    margin: auto;
    width: 60%;
    padding: 10px;
}
.right {
   	float: right;
    width: 500px;
    height:550px;
    border: 2px solid #D3D3D3;
    padding: 10px;
    overflow: hidden;
    word-wrap:break-word;
    overflow-y:scroll;
}
</style>
<body>
	<h1>欢迎来到区块链的世界</h1>
<div class="right">
 <% String data = (String)request.getAttribute("data");
  if(data==null){
	  out.print("这是一个区块链的简易实现");
  }else{
	  out.print(data);
  }
  %>
</div>
<div class="center">
<form action="chain" method="get">
<input type="submit" value="查询区块链">
</form>
<form action="createwallet" method="post">
<input type="submit" value="创建钱包">
</form>
<form action="getwallet" method="get">
<input type="submit" value="查询钱包">
</form>
<form action="unpackedtransactions" method="get">
<input type="submit" value="查询未打包交易">
</form>
<form action="peers" method="get">
<input type="submit" value="查询所有socket节点">
</form>
<form action="mine" method="post">
请输入要挖矿的钱包地址：<br><input type="text" name="address"><br>
<input type="submit" value="挖矿">
</form>
<form action="newtransactions" method="post">
请输入转账的发送方钱包地址：<br><input type="text" name="sender"><br>
请输入转账的接收方钱包地址：<br><input type="text" name="recipient"><br>
请输入要转账的金额: <br><input type="text" name="amount"><br>
<input type="submit" value="转账">
</form>
<form action="unpackedtransactions" method="get">
<input type="submit" value="查询未打包交易">
</form>
<form action="walletbalance" method="get">
请输入要查询的钱包地址：<br><input type="text" name="address"><br>
<input type="submit" value="查询钱包余额">
</form>
<form action="peers" method="get">
<input type="submit" value="查询所有socket节点">
</form>
</div>
</body>
</html>