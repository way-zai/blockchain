<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>区块链</title>
</head>
<body>
<p><form action="chain" method="get">
<input type="submit" value="查询区块链">
</form>
<p><form action="createwallet" method="post">
<input type="submit" value="创建钱包">
</form>
<p><form action="getwallet" method="get">
<input type="submit" value="查询钱包">
</form>
<p><form action="mine" method="post">
请输入要挖矿的钱包地址：<input type="text" name="address">
<input type="submit" value="挖矿">
</form>
<p><form action="newtransactions" method="post">
请输入转账的发送方钱包地址：<input type="text" name="sender"><br>
请输入转账的接收方钱包地址：<input type="text" name="recipient"><br>
请输入要转账的金额： <input type="text" name="amount">
<input type="submit" value="转账">
</form>
<p><form action="unpackedtransactions" method="get">
<input type="submit" value="查询未打包交易">
</form>
<p><form action="walletbalance" method="get">
请输入要查询的钱包地址：<input type="text" name="address">
<input type="submit" value="查询钱包余额">
</form>
<p><form action="peers" method="get">
<input type="submit" value="查询所有socket节点">
</form>
</body>
</html>