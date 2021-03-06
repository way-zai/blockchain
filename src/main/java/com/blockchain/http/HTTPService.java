package com.blockchain.http;

import java.io.BufferedReader;
import java.io.IOException;
import java.net.InetSocketAddress;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.servlet.ServletContextHandler;
import org.eclipse.jetty.servlet.ServletHolder;
import org.eclipse.jetty.webapp.WebAppContext;
import org.java_websocket.WebSocket;

import com.alibaba.fastjson.JSON;
import com.blockchain.block.BlockService;
import com.blockchain.model.Block;
import com.blockchain.model.Transaction;
import com.blockchain.model.TransactionParam;
import com.blockchain.model.Wallet;
import com.blockchain.p2p.Message;
import com.blockchain.p2p.P2PService;

/**
 * 区块链对外http服务
 * 
 *
 */
public class HTTPService {
	private BlockService blockService;
	private P2PService p2pService;

	public HTTPService(BlockService blockService, P2PService p2pService) {
		this.blockService = blockService;
		this.p2pService = p2pService;
	}

	public void initHTTPServer(int port) {
		try {
			Server server = new Server(port);
			System.out.println("listening http port on: " + port);
			//ServletContextHandler context = new ServletContextHandler(ServletContextHandler.SESSIONS);
			WebAppContext context = new WebAppContext();
	        // 设置描述符位置
	        context.setDescriptor("./src/main/webapp/WEB-INF/web.xml");
	        // 设置Web内容上下文路径
	        context.setResourceBase("./src/main/webapp");
			context.setContextPath("/");
			server.setHandler(context);

			// 查询区块链
			context.addServlet(new ServletHolder(new ChainServlet()), "/chain");
			// 创建钱包
			context.addServlet(new ServletHolder(new CreateWalletServlet()), "/createwallet");
			// 查询钱包
			context.addServlet(new ServletHolder(new GetWalletsServlet()), "/getwallet");
			// 挖矿
			context.addServlet(new ServletHolder(new MineServlet()), "/mine");
			// 转账交易
			context.addServlet(new ServletHolder(new NewTransactionServlet()), "/newtransactions");
			// 查询未打包交易
			context.addServlet(new ServletHolder(new GetUnpackedTransactionServlet()), "/unpackedtransactions");
			// 查询钱包余额
			context.addServlet(new ServletHolder(new GetWalletBalanceServlet()), "/walletbalance");
			// 查询所有socket节点
			context.addServlet(new ServletHolder(new PeersServlet()), "/peers");

			server.start();
			server.join();
		} catch (Exception e) {
			System.out.println("init http server is error:" + e.getMessage());
		}
	}

	private class ChainServlet extends HttpServlet {
		@Override
		protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
			resp.setContentType("text/html;charset=UTF-8");
			req.setAttribute("data", "当前区块链：" + JSON.toJSONString(blockService.getBlockChain()));
			req.getRequestDispatcher("index.jsp").forward(req, resp); 
			//resp.getWriter().print("当前区块链：" + JSON.toJSONString(blockService.getBlockChain()));
		}
	}

	private class MineServlet extends HttpServlet {
		@Override
		protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
			resp.setContentType("text/html;charset=UTF-8");
			String address = req.getParameter("address");
			int score = Integer.parseInt(req.getParameter("score"));
			Wallet myWallet = blockService.getMyWalletMap().get(address);
			if (myWallet == null) {
				req.setAttribute("data", "挖矿指定的钱包不存在");
				req.getRequestDispatcher("index.jsp").forward(req, resp); 
				//resp.getWriter().print("挖矿指定的钱包不存在");
				return;
			}
			Block newBlock = blockService.mine(address,score);
			if (newBlock == null) {
				req.setAttribute("data","挖矿失败，可能有其他节点已挖出该区块");
				req.getRequestDispatcher("index.jsp").forward(req, resp); 
				//resp.getWriter().print("挖矿失败，可能有其他节点已挖出该区块");
				return;
			}
			Block[] blocks = {newBlock};
			String msg = JSON.toJSONString(new Message(P2PService.RESPONSE_BLOCKCHAIN, JSON.toJSONString(blocks)));
			p2pService.broatcast(msg);
			req.setAttribute("data","挖矿生成的新区块：" + JSON.toJSONString(newBlock));
			req.getRequestDispatcher("index.jsp").forward(req, resp); 
			//resp.getWriter().print("挖矿生成的新区块：" + JSON.toJSONString(newBlock));
		}
	}

	private class CreateWalletServlet extends HttpServlet {
		@Override
		protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
			resp.setContentType("text/html;charset=UTF-8");
			Wallet wallet = blockService.createWallet();
			Wallet[] wallets = {new Wallet(wallet.getPublicKey())}; 
			String msg = JSON.toJSONString(new Message(P2PService.RESPONSE_WALLET, JSON.toJSONString(wallets)));
			p2pService.broatcast(msg);
			req.setAttribute("data","创建钱包成功，钱包地址： " + wallet.getAddress());
			req.getRequestDispatcher("index.jsp").forward(req, resp); 
			//resp.getWriter().print("创建钱包成功，钱包地址： " + wallet.getAddress());
		}
	}

	private class GetWalletsServlet extends HttpServlet {
		@Override
		protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
			resp.setContentType("text/html;charset=UTF-8");
			req.setAttribute("data","当前节点钱包：" + JSON.toJSONString(blockService.getMyWalletMap().keySet()));
			req.getRequestDispatcher("index.jsp").forward(req, resp); 
			//resp.getWriter().print("当前节点钱包：" + JSON.toJSONString(blockService.getMyWalletMap().values()));
		}
	}

	private class NewTransactionServlet extends HttpServlet {
		@Override
		protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
			resp.setContentType("text/html;charset=UTF-8");
			//TransactionParam txParam = JSON.parseObject(getReqBody(req), TransactionParam.class);
			String sender = req.getParameter("sender");
			String recipient = req.getParameter("recipient");
			int amount = Integer.parseInt(req.getParameter("amount"));
			Wallet senderWallet = blockService.getMyWalletMap().get(sender);
			Wallet recipientWallet = blockService.getMyWalletMap().get(recipient);
			if (recipientWallet == null) {
				recipientWallet = blockService.getOtherWalletMap().get(recipient);
			}
			if (senderWallet == null || recipientWallet == null) {
				req.setAttribute("data","钱包不存在");
				req.getRequestDispatcher("index.jsp").forward(req, resp); 
				//resp.getWriter().print("钱包不存在");
				return;
			}

			Transaction newTransaction = blockService.createTransaction(senderWallet, recipientWallet,
			        amount);
			if (newTransaction == null) {
				req.setAttribute("data", "钱包" + sender + "余额不足或该钱包找不到一笔等于" + amount + "BTC的UTXO");
				req.getRequestDispatcher("index.jsp").forward(req, resp); 
				//resp.getWriter().print(
				 //       "钱包" + sender + "余额不足或该钱包找不到一笔等于" + amount + "BTC的UTXO");
			} else {
				req.setAttribute("data","新生成交易：" + JSON.toJSONString(newTransaction));
				req.getRequestDispatcher("index.jsp").forward(req, resp);
				//resp.getWriter().print("新生成交易：" + JSON.toJSONString(newTransaction));
				Transaction[] txs = {newTransaction}; 
				String msg = JSON.toJSONString(new Message(P2PService.RESPONSE_TRANSACTION, JSON
				        .toJSONString(txs)));
				p2pService.broatcast(msg);
			}
		}
	}

	private class GetWalletBalanceServlet extends HttpServlet {
		@Override
		protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
			resp.setContentType("text/html;charset=UTF-8");
			String address = req.getParameter("address");
			req.setAttribute("data","钱包余额为：" + blockService.getWalletBalance(address) + "BTC");
			req.getRequestDispatcher("index.jsp").forward(req, resp);
			//resp.getWriter().print("钱包余额为：" + blockService.getWalletBalance(address) + "BTC");
		}
	}

	private class GetUnpackedTransactionServlet extends HttpServlet {
		@Override
		protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
			resp.setContentType("text/html;charset=UTF-8");
			List<Transaction> transactions = new ArrayList<>(blockService.getAllTransactions());
			transactions.removeAll(blockService.getPackedTransactions());
			req.setAttribute("data","本节点未打包交易：" + JSON.toJSONString(transactions));
			req.getRequestDispatcher("index.jsp").forward(req, resp);
			//resp.getWriter().print("本节点未打包交易：" + JSON.toJSONString(transactions));
		}
	}
	
    private class PeersServlet extends HttpServlet {
        @Override
        protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        	resp.setContentType("text/html;charset=UTF-8");
        	String ports = "";
            for (WebSocket socket : p2pService.getSockets()) {
                InetSocketAddress remoteSocketAddress = socket.getRemoteSocketAddress();
                ports += remoteSocketAddress.getHostName() + ":" + remoteSocketAddress.getPort() + "  ";
                //resp.getWriter().print(remoteSocketAddress.getHostName() + ":" + remoteSocketAddress.getPort() + "  ");
            }
            if(ports=="") {
            	req.setAttribute("data","暂时没有其他节点");
            }else {
            	req.setAttribute("data",ports);
            }        
            req.getRequestDispatcher("index.jsp").forward(req, resp);
        }
    }
    
	private String getReqBody(HttpServletRequest req) throws IOException {
		BufferedReader br = req.getReader();
		String str, body = "";
		while ((str = br.readLine()) != null) {
			body += str;
		}
		return body;
	}
}
